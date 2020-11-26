function [TissueProperties] = setupStripBounds(TissueProperties)
%%
% Get the boundary IDs for each strip by interpolating group boundaries
% with the number of strips and rounding
TissueProperties.stripBoundaryIDArr = round(interp1( ...
  (0:TissueProperties.numGroups)', ...
  TissueProperties.groupBoundaryIDArr, ...
  (0:(1/TissueProperties.numStrips):TissueProperties.numGroups)', ...
  'linear' ));