# Vertex 2.1
A version of VERTEX that removes unnecessary (and in places out of date) example
scripts.
This version includes synaptic plasticity, multiple region and electric field stimulation options. 
The basic ferret model scripts with background noise are included in the folder
'ModelBuildScripts\_ferret'. 

Modifying the ferret model:

Parameter                Where to find it                     Sources for alternative

Slice dimensions            cvc_tissue.m > TP.X, TP.Y, TP.Z      Depends on your experimental approach.
Neuron Density              cvc_tissue.m > TP.neuronDensity
Layer depths                cvc_tissue.m > TP.layerBoundaryArr 
Number of layers            cvc_tissue.m > TP.numLayers
Tissue conductivity         cvc_tissue.m > TP.tissueConductivity
Number of neuron types      cvc_tissue.m > TP.numGroups
Proportion of neuron type   cvc_neuronsNoisy.m > NP(i).modelProportion
Neuron capcitance           cvc_neuronsNoisy.m > NP(i).C
Neuron reset potential      cvc_neuronsNoisy.m > NP(i).v_reset
Neuron layer                cvc_neuronsNoisy.m > NP(i).somaLayer
Number of incoming synapses cvc_connectivity_noisy.m > ConnectivityData(i).incomingSynapses 
Recording sample rate       cvc_recording.m > RS.sampleRate
Neuron IDs to record from   cvc_recording.m > RS.v_m
Simulation time             cvc_simulation.m > SS.simulationTime
Parallel pool size          cvc_simulation.m > SS.poolSize

