function [roiVoxelParams, percentNaN,percent0] = readROIFeatures(imgPath,XYZ_ROI,V_ROIs,noROIs);
% extracts the parameter estiamtes of all images in imgPath (cell) from voxels  indicated by
% voxel coordinates in XYZ_ROI (as extracted by spm_ROI)
% roiVoxelParams is a cell with each cell contraining a matrix with imgs
% (rows) x voxel (columns) parameter estimates

noImgs = size(imgPath,1);

for iROI = 1:noROIs;
    noVoxROIs(iROI) = size(XYZ_ROI{iROI},2);
    roiVoxelParams{iROI} = zeros(noImgs,noVoxROIs(iROI));
end;
percentNaN = zeros(noImgs,noROIs);
percent0 = zeros(noImgs,noROIs);
% read header information for img 
V_img = spm_vol(imgPath);

% check whether img in same space
sts = spm_check_orientations([V_img;V_ROIs]);
if sts ~= 1;
    error('Images not in same space!');
end;



% masking each img by each ROI
for iROI = 1:noROIs;
    % extract image data 
    [Y] = spm_get_data(V_img,XYZ_ROI{iROI});
    roiVoxelParams{iROI}(1:noImgs,1:noVoxROIs(iROI)) = Y;
    percentNaN(1:noImgs,iROI) = sum(isnan(Y),2) ./ (ones(noImgs,1)*noVoxROIs(iROI));
    percent0(1:noImgs,iROI) = sum(Y == 0,2) ./ (ones(noImgs,1)*noVoxROIs(iROI));  
    
%     %--- verify the combination of extracting ROI xyz coordinates with spm_roi and
%     % extracting data at these coordinates with:
%     testY = NaN(78,78,42);
%     for iVox = 1:1400;
%         testY(subjectData(iSubj).XYZ_ROI{1}(1,iVox),subjectData(iSubj).XYZ_ROI{1}(2,iVox)...
%             ,subjectData(iSubj).XYZ_ROI{1}(3,iVox))= roiVoxelParamsSubj{1,1}(iVox) ;
%     end;
%     hROIs(1).fname = ['D:\USERS\trohe\Exp1_VE_fMRI\Data\subjectROIData\test_spm_ROI_S1_Se1_R1_beta0001_inV1_e.img'];
%     spm_write_vol(hROIs(1),testY)
%     % and compare the ROI and the written data volume with check
%     % realignment!
end;



