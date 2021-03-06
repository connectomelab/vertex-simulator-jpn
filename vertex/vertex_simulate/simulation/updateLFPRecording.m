function [RecVar] = ...
  updateLFPRecording(RS,NeuronModel,RecVar,lineSourceModCell,iGroup,recTimeCounter)

if isfield(RS, 'LFPoffline') && RS.LFPoffline
  RecVar.LFPRecording{iGroup}(:,:,recTimeCounter) = -NeuronModel{iGroup}.I_ax;
else
  for iElectrode = 1:RS.numElectrodes
    RecVar.LFPRecording{iGroup}(iElectrode,recTimeCounter) = ...
      sum(sum( (-NeuronModel{iGroup}.I_ax) .* ...
      lineSourceModCell{iGroup, iElectrode} ));
  end
end