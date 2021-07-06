
cvc_tissue;
cvc_neurons_withdummy;
cvc_connectivity_withdummy;
cvc_recording;
cvc_simulation;
%cvc_field_stimulation;

SS.simulationTime = 500; % change back to 500 
SS.parallelSim = false;


% Change this directory to where you would like to save the results of the
% simulation
RS.saveDir = '~/Documents/MATLAB/Vertex_Results/cvc_multiregion';

%% Initialise the network
[params, connections, electrodes] = initNetwork(TP, NP, CP, RS, SS);

% Clone the other regions from the first!
params2 = params;
connections2 = connections;
electrodes2 = electrodes;
 
%% Region connectivity
 % defining the between region connectivity here. If you have connection (fibre) lengths
 % in mm then a matrix of fibre lengths can also be passed here, and delays will
 % be calculated automatically, assuming a transmission speed of 120mm/ms
 
 regionConnect.map = [1,1; 1,1];
 
 % for example [1,1;0,1] there are two regions and there is only an
 % external connection from region 1 to region 2, it is not returned, and
 % while they do connect to themselves internally for the sake of incoming external
 % connections the diagonals are set to 0.
 
 % Identify the neuron types (e.g. NP(1) in this instance are the
 % excitatory PY cells) which will export signals. Use [] if not exporting.
 regionConnect.exportingNeuronPops{1} = 1; 
 regionConnect.exportingNeuronPops{2} = 1;
 % identify which neuron pops are designated as dummy neurons to just
 % recieve external signals. (May need to change this if having a different
 % implementation of the dummy neurons.) Use [] if no dummy neurons are
 % present.
 regionConnect.dummyNeuronPops{1} = 16;
 regionConnect.dummyNeuronPops{2} = 16;
%% Stack parameters and run multiregion simulation
%stack the parameters for params, connections and electrodes into cell
%arrrays which can then be fed into runSimulationMultiregional
paramStacked = {params, params2};
connectionStacked = {connections,connections2};
electrodeStacked = {electrodes,electrodes2};

tic
runSimulationMultiregional(paramStacked,connectionStacked,electrodeStacked,regionConnect);
toc
%% Load the simulation results
Results = loadResultsMultiregions(RS.saveDir);

%% Plotting
% 
% Slice schematic:
%rasterParams.colors = {'k','c','g','y','m','r','b','c','k','m','b','g','r','k','c','w'};
rasterParams.colors = {'k','m','m','m','m','k','m','m','k','k','m','m','k','k','m','w'};
pars.colors = rasterParams.colors;
pars.opacity=0.6;
pars.markers =        {'^','p','h','*','x','^','p','h','d','v','p','h','d','v','p','.'};
N = Results(1).params.TissueParams.N;
pars.toPlot = 1:3:N;
plotSomaPositions(Results(1).params.TissueParams,pars);
title('Region 1 soma positions')
plotSomaPositions(Results(2).params.TissueParams,pars);
title('Region 2 soma positons')
% % LFP 
% figure
% plot(mean(Results.LFP))
% xlabel('time steps')
% ylabel('LFP mV')
% title('Mean LFP')
% % Might be good to plot for each layer?
% 
% % Spike Raster:
plotSpikeRaster(Results(1),pars)
xlabel('time steps')
ylabel('Neuron ID')
title('Spike Raster, Region 1')

plotSpikeRaster(Results(2),pars)
xlabel('time steps')
ylabel('Neuron ID')
title('Spike Raster, Region 2')

%% Find firing rates to compare with Japan data:

for kk = 1:Results(1).params.TissueParams.N 
    spkInds = find(Results(1).spikes(:,1)==kk); % find all spikes for a given neuron
    FireRate(kk)=1000*length(spkInds)./Results(1).params.TissueParams.N; % Find the Firing Rate, as it is the ratio of spikes over max possible spikes
end

% find the different populations for each neuron:
neuronInGroup = createGroupsFromBoundaries( ...
Results(1).params.TissueParams.groupBoundaryIDArr);

% now make a new vector the same length, default value of zero = inhibitory
neuronType = zeros(length(neuronInGroup),1);

% make 1 if the group is an excitatory one:
neuronType(neuronInGroup==1) = 1;
neuronType(neuronInGroup==6) = 1;
neuronType(neuronInGroup==9) = 1;
neuronType(neuronInGroup==10) = 1;
neuronType(neuronInGroup==13) = 1;
neuronType(neuronInGroup==14) = 1;
neuronType(neuronInGroup==16) = 1;

% now make a new vector the same length, this one will hold layer info.
neuronInLayer = 2*ones(length(neuronInGroup),1); % default is 2 for L2-3

neuronInLayer(neuronInGroup==4) = 3; % 3 is L4
neuronInLayer(neuronInGroup==5) = 3;
neuronInLayer(neuronInGroup==6) = 3;
neuronInLayer(neuronInGroup==7) = 3;
neuronInLayer(neuronInGroup==8) = 3;
neuronInLayer(neuronInGroup==9) = 4; % 4 is L5
neuronInLayer(neuronInGroup==10) = 4;
neuronInLayer(neuronInGroup==11) = 4;
neuronInLayer(neuronInGroup==12) = 4;
neuronInLayer(neuronInGroup==13) = 5; % 5 is L6
neuronInLayer(neuronInGroup==14) = 5;
neuronInLayer(neuronInGroup==15) = 5;
neuronInLayer(neuronInGroup==16) = 5;

figure
title('example1: excitatory neurons in layer23')
hist(log10(FireRate(((neuronType==1).*(neuronInLayer==2))==1)),10)
median(FireRate(((neuronType==1).*(neuronInLayer==2))==1))

 
figure
title('example2: inhibitory neurons in layer5')
hist(log10(FireRate(((neuronType==0).*(neuronInLayer==4))==1)),10)
median(FireRate(((neuronType==0).*(neuronInLayer==4))==1))


for mm = 0:1
    for kk = 1:5
      FR_med(mm+1,kk)=median(FireRate(((neuronType==mm).*(neuronInLayer==kk))==1));
    end
end

