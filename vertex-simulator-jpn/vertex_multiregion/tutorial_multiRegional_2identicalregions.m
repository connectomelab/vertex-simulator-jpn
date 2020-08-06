
% set up identical layers by calling setup_multilayer and cloning
% the parameters for the additional regions.

 setup_multiregion_allstdp; % Loads parameters for a single region.

% Initial simulation and recording settings that are the same for all
% regions:
RecordingSettings.saveDir = '~/VERTEX_results_2regionconnected/stim1000R1toR2'; % Save directory
RecordingSettings.weights_arr = 1:5000:100000; % Time snapshots (in time steps) for capturing network weights
SimulationSettings.simulationTime = 500; % How long to run for! First 100 ms or so are full of artefact
SimulationSettings.timeStep = 0.03125;
SimulationSettings.parallelSim = true;


%% Stimulation applied here. Comment out (or set amplitude to zero) for no stimulation 
% Electric field stimulation:
[TissueParams.StimulationField,model] = invitroSliceStim('tutorial2_3.stl',100);
TissueParams.StimulationOn = 300;
TissueParams.StimulationOff = 350;%SimulationSettings.simulationTime;

% optional - step current stimulation to neurons to see spread of activity
% through region to region connections
% 
%  NeuronParams(1).Input(2).inputType = 'i_step';
%  NeuronParams(1).Input(2).timeOn = 300;
%  NeuronParams(1).Input(2).timeOff = 350;
%  NeuronParams(1).Input(2).amplitude = 1000; 

%% Main setup

[params, connections, electrodes] = ...
  initNetwork(TissueParams, NeuronParams, ConnectionParams, ...
              RecordingSettings, SimulationSettings);

 % clone the slice to create an identical second region.\
 % (if wanting two differing regions you will need to call a second version
 % of setup_multilayer with mofified parameters and then initialise this
 % new network with another call of initNetwork. As commented out below:
 
 % Clone the other regions from the first!
params2 = params;
connections2 = connections;
electrodes2 = electrodes;
 
params3 = params;
connections3 = connections;
electrodes3 = electrodes;

 

%%  
 % defining the between region connectivity here. If you have connection (fibre) lengths
 % in mm then a matrix of fibre lengths can also be passed here, and delays will
 % be calculated automatically, assuming a transmission speed of 120mm/ms
 
 regionConnect.map = [0,1,0; 0,0,1; 0,0,0];
 
 % for example [1,1;0,1] there are two regions and there is only an
 % external connection from region 1 to region 2, it is not returned, and
 % while they do connect to themselves internally for the sake of incoming external
 % connections the diagonals are set to 0.
 
 % Identify the neuron types (e.g. NP(1) in this instance are the
 % excitatory PY cells) which will export signals. Use [] if not exporting.
 regionConnect.exportingNeuronPops{1} = 1; 
 regionConnect.exportingNeuronPops{2} = 1;
 regionConnect.exportingNeuronPops{3} = 1;
 % identify which neuron pops are designated as dummy neurons to just
 % recieve external signals. (May need to change this if having a different
 % implementation of the dummy neurons.) Use [] if no dummy neurons are
 % present.
 regionConnect.dummyNeuronPops{1} = [];
 regionConnect.dummyNeuronPops{2} = 3;
 regionConnect.dummyNeuronPops{3} = 3;

 %% Stack parameters and run multiregion simulation
 %stack the parameters for params, connections and electrodes into cell
 %arrrays which can then be fed into runSimulationMultiregional
 paramStacked = {params, params2, params3};
 connectionStacked = {connections,connections2, params3};
 electrodeStacked = {electrodes,electrodes2, electrodes3};
 
runSimulationMultiregional(paramStacked,connectionStacked,electrodeStacked,regionConnect);

%% Load and plot results

% need to use a Multiregions variant of loadResults to load the results for
% every region in one structure. 
Results = loadResultsMultiregions(RecordingSettings.saveDir);
% 
 
[TissueParams.StimulationField,model] = invitroSliceStim('tutorial2_3.stl',100);
figure; 
pdeplot3D(model,'ColorMapData', TissueParams.StimulationField.NodalSolution, 'FaceAlpha', 0.2);
hold on
plotSomaPositions(Results(1).params.TissueParams)
hold on
scatter3(RecordingSettings.meaXpositions(:),RecordingSettings.meaYpositions(:),RecordingSettings.meaZpositions(:),'*')

 
plotSpikeRaster(Results(1))
title('Region 1')
plotSpikeRaster(Results(2))
title('Region 2')
figure
plot(mean(Results(1).LFP,2))
hold on
plot(mean(Results(2).LFP,2))

