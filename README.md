# Vertex 2.1
A version of VERTEX that removes unnecessary (and in places out of date) example
scripts.
This version includes synaptic plasticity, multiple region and electric field stimulation options. 
The basic ferret model scripts with background noise are included in the folder
'ModelBuildScripts\_ferret'. 

Modifying the ferret model

|        Parameter         |             Where to find it                                    |         Sources for alternative        |
| :----------------------- | :-------------------------------------------------------------: | :------------------------------------- | 
|Slice dimensions          |   cvc_tissue.m > TP.X, TP.Y, TP.Z                               | Depends on your experimental approach. |
|Neuron Density            |   cvc_tissue.m > TP.neuronDensity                               | e.g. https://onlinelibrary.wiley.com/doi/abs/10.1002/cne.902860404, https://www.frontiersin.org/articles/10.3389/fnana.2018.00083/full |
|Layer depths              |   cvc_tissue.m > TP.layerBoundaryArr                            | e.g https://www.researchgate.net/publication/282769529_Grey_Matter_Sublayer_Thickness_Estimation_in_the_Mouse_Cerebellum, http://map.loni.usc.edu/data/brain-architecture-management-system-bams/ |
|Number of layers          |   cvc_tissue.m > TP.numLayers                                    | http://mouse.brain-map.org/           |
|Tissue conductivity       |   cvc_tissue.m > TP.tissueConductivity                           | e.g. https://iopscience.iop.org/article/10.1088/0031-9155/58/11/3599/pdf, https://core.ac.uk/display/29202573 |
|Number of neuron types    |   cvc_tissue.m > TP.numGroups                                    | Database of cell types: http://celltypes.brain-map.org/data?donor__species=Mus%20musculus&nr__reconstruction_type=[full,dendrite-only] Probably don't want to use them all though! Selecting the most important/ combining similar types would be good ways to simplify this model.|
|Proportion of neuron type |  cvc_neurons_noisy.m > NP(i).modelProportion                      | https://www.frontiersin.org/articles/10.3389/fnana.2018.00083/full |
|Neuron capcitance         |  cvc_neuronsNoisy.m > NP(i).C                                    | detailed parameter info at the allen brain atlas, e.g. http://celltypes.brain-map.org/experiment/electrophysiology/623185845 |
|Neuron reset potential    |  cvc_neuronsNoisy.m > NP(i).v_reset                              | detailed parameter info at the allen brain atlas, e.g. http://celltypes.brain-map.org/experiment/electrophysiology/623185845 |
|Neuron layer              |  cvc_neuronsNoisy.m > NP(i).somaLayer                            | Determine which layer the neuron population somas exist in.  |
|Num. incoming synapses    |  cvc_connectivity_noisy.m > ConnectivityData(i).incomingSynapses | http://connectivity.brain-map.org/    |
|Recording sample rate     |  cvc_recording.m > RS.sampleRate                                 | Set the sample rate in Hz to match that of recording electrodes for LFP. |
|Neuron IDs to record from |  cvc_recording.m > RS.v_m                                        | Pass an array of values representing neuron IDs to record the soma membrane voltage from. |
|Simulation time           |  cvc_simulation.m > SS.simulationTime                            | This is the time the simulation will run for (ms), needs to be >150 to avoid initial artefacts.  |
|Parallel pool size        |  cvc_simulation.m > SS.poolSize	                              | This can be set according to the host computer's CPU availability.  |


There are further parameters that can be customised, including neuron shape and compartment dimensions, the simulation model used (currently AdEx) etc., but these seem like the main ones that can be quickly changed.
The Allen brain atlas has neuron morphology details for mice: http://celltypes.brain-map.org/data?donor__species=Mus%20musculus&nr__reconstruction_type=[full,dendrite-only] Also neuromorpho: Neuromorpho.org

