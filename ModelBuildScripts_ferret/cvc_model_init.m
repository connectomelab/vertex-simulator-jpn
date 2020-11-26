% Neocortical slice model from Tomsett et al. 2014

cvc_tissue;
%cvc_neurons_nonoise;
%cvc_connectivity_none;
cvc_neurons_noisy;
cvc_connectivity_noisy;
%cvc_neurons_beta;
%cvc_connectivity_beta;
%cvc_neurons;
%cvc_connectivity_alpha;
%cvc_neurons_gamma;
%cvc_connectivity_gamma_update;
%cvc_step_current;
cvc_recording;
cvc_simulation;

% Change this directory to where you would like to save the results of the
% simulation
RS.saveDir = '~/Documents/MATLAB/Vertex_Results/';%AC30hz_long';


%% Initialise the network
[params, connections, electrodes] = initNetwork(TP, NP, CP, RS, SS);




