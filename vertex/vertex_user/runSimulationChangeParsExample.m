function [] = runSimulationChangeParsExample(params, connections, electrodes)
%RUNSIMULATIONCHANGEPARSEXAMPLE Run the simulation given the model generated by initNetwork().
%   RUNSIMULATION(PARAMS, CONNECTIONS, ELECTRODES) runs the simulation
%   given the model generated by INITNETWORK. PARAMS, CONNECTIONS and
%   ELECTRODES are the PARAMS, CONNECTIONS and ELECTRODES outputs from the
%   initNetwork() function. runSimulation() automatically saves the simulation
%   results in the directory specified by the user in the recording
%   settings structure given to initNetwork().

% Create shorthand names for the parameter structures in params
TP = params.TissueParams;
NP = params.NeuronParams;
CP = params.ConnectionParams;
RS = params.RecordingSettings;
SS = params.SimulationSettings;

% Get the directory to save files to (and create it if necessary)
outputDirectory = RS.saveDir;
if ~strcmpi(outputDirectory(end), '/')
  outputDirectory = [outputDirectory '/'];
end
if exist(outputDirectory, 'dir') ~= 7
  mkdir(outputDirectory);
end
RS.saveDir = outputDirectory;

% If loading spikes from a previous simulation, and spikeLoadDir is not
% specified in params.SimulationSettings, assume that we are loading spikes
% from the output directory
if isfield(SS,'spikeLoad') 
  if SS.spikeLoad
    if ~isfield(SS, 'spikeLoadDir')
      inputDirectory = outputDirectory;
      SS.spikeLoadDir = inputDirectory;
    end
  end
end

% Calculate passive neuron properties in correct units
NP = calculatePassiveProperties(NP, TP);

% If using pre-calculated spike times with the loadspiketimes neuron model,
% check the stored spike times can be found, then load them and convert
% into units of timeStep
loadedSpikeTimeCell = cell(TP.numGroups, 1);
for iGroup = 1:TP.numGroups
  if strcmpi(NP(iGroup).neuronModel, 'loadspiketimes')
    spkfile = NP(iGroup).spikeTimeFile; % check spikeTimeDir is a field
    if exist(spkfile,'file') ~= 2
      errMsg = ['The specified spike time file for neuron group ' ...
                 num2str(iGroup) ' does not exist.'];
      error('vertex:runSimulation:spikeTimeDirError', errMsg);
    else
      loadedSpikeTimes = load(spkfile);
      fName = fields(loadedSpikeTimes);
      loadedSpikeTimeCell{iGroup} = loadedSpikeTimes.(fName{1});
      for ii = 1:length(loadedSpikeTimeCell{iGroup})
        loadedSpikeTimeCell{iGroup}{ii} = ...
          sort(round(loadedSpikeTimeCell{iGroup}{ii} ./ SS.timeStep));
      end
    end
  end
end

% Setup the neuron ID mapping for routing spikes, saving variables etc.
[NeuronIDMap] = setupNeuronIDMapping(TP, SS);

% Initialise the neuron models
[NeuronModelArr] = ...
  setupNeuronDynamicVars(TP, NP, SS, NeuronIDMap, loadedSpikeTimeCell);

% Initialise the synapse models
[SynapseModelArr, synMapCell] = setupSynapseDynamicVars(TP, NP, CP, SS);

% Initialise the input models (if any)
if isfield(NP, 'Input')
  [InputModelArr] = setupInputDynamicVars(TP, NP, SS);
else
  InputModelArr = [];
end

% Initialise the recording variables
[RS, RecordingVars, lineSourceModCell] = ...
  setupRecordingVars(TP, NP, SS, RS, NeuronIDMap, electrodes);

% Prepare synapses and synaptic weights. 
[synapsesArrSim, weightArr] = prepareSynapsesAndWeights(TP,CP,SS,connections);

% Run the simulation. This stores the results in the specified folder at
% the specified time intervals.
if SS.parallelSim
  % IF IN PARALLEL MODE:
  % If you want to run several simulations within runSimulation(), for
  % example, changing parameters between runs (see tutorials at
  % www.vertexsimulator.org), then uncomment the next line to get the
  % dynamic variables at the end of simulateParallel()
  %[NeuronModelArr, SynapseModelArr, InputModelArr, numSaves] = ...
    simulateParallel(TP, NP, SS, RS, NeuronIDMap, NeuronModelArr, ...
    SynapseModelArr, InputModelArr, RecordingVars, lineSourceModCell, ...
    synapsesArrSim, weightArr, synMapCell);
  
  % You can now alter the parameters in NP to change neuron or input
  % properties, then rerun simulateParallel() to run the next stage of the
  % simulation for another SS.simulationTime milliseconds. Passing numSaves
  % back into simulateParallel() ensures that the save files carry on from the
  % correct save number.
  %
  % REMEMBER: if you change the neurons' passive properties, you need to run:
  %   NP = calculatePassiveProperties(NP, TP);
  % REMEMBER: if you are using Ornstein-Uhlenbeck process type inputs and
  % change the Inputs' parameters, you need to run:
  %   InputsModelArr = recalculateInputObjectPars(InputModelArr, TP, NP, SS);
  %
  % ... ... do parameter modification here ... ...
  %[NeuronModelArr, SynapseModelArr, InputModelArr, numSaves] = ...
    %simulateParallel(TP, NP, SS, RS, NeuronIDMap, NeuronModelArr, ...
    %SynapseModelArr, InputModelArr, RecordingVars, lineSourceModCell, ...
    %synapsesArrSim, weightArr, synMapCell, numSaves);
    
  % ... and so on as many times as you like.
else
  % IF IN SERIAL MODE:

  [NeuronModelArr, SynapseModelArr, InputModelArr, numSaves] = ...
    simulate(TP, NP, SS, RS, NeuronIDMap, NeuronModelArr, ...
    SynapseModelArr, InputModelArr, RecordingVars, lineSourceModCell, ...
    synapsesArrSim, weightArr, synMapCell);
  
  NP(1).Input.meanInput = NP(1).Input.meanInput + 150;
     InputModelArr = recalculateInputObjectPars(InputModelArr, TP, NP, SS);
  
  simulate(TP, NP, SS, RS, NeuronIDMap, NeuronModelArr, ...
    SynapseModelArr, InputModelArr, RecordingVars, lineSourceModCell, ...
    synapsesArrSim, weightArr, synMapCell, numSaves);
    
end

% Store the parameters in the same folder, so we can reference them later
% during analysis (used by loadResults, as well as useful for tracking
% simulations). You may want to copy these lines to store each parameter
% set after every time you call simulate()/simulateParallel().
parameterCell = {TP, NP, CP, RS, SS};
fname = [outputDirectory 'parameters.mat'];
save(fname, 'parameterCell');