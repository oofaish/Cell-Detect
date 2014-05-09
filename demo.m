%                   CellDetect v1.0 - Demo
%
%Learning to Detect Cells Using Non-overlapping Extremal Regions
%
%

clc;
disp(' ')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('===================================================================');
disp('--Learning to Detect Cells Using Non-overlapping Extremal Regions--');
disp('===================================================================');
disp(' ')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------------------------------------------Check

if exist('vl_setup','file') == 0
    error('Vl_feat required');
end
if exist('pylonSetup','file') == 0
    error('Pylon Inference code required');
end

%---------------------------------------------------------------------Setup
%Choose parameters for the training/testing
%datasetTrain = 1;%Identifier of the training data as set in loadDatasetInfo
%datasetTest = 2;%Identifier of the testing data as set in loadDatasetInfo
datasetTrain = 3;%ISBI training dataset
datasetTest  = 4;%FOR NOW


train = 0;%---->Do train
test  = 1;%---->Do test

inspectResults = 0; %1: Shows detected cells. 
%2:A view on the results: MSERs found and selected

%-Features and control parameters-%
[parameters,ctrl] = setFeatures(); %Modify to select features and other parameters

if ctrl.runPar && isempty( gcp( 'nocreate' ) )
        parpool( 'local', ctrl.workers );
end

%---------------------------------------------------------------------Train
if train
    w = trainCellDetect(datasetTrain,ctrl,parameters);
else
    [~, ~, ~, outFolder] = loadDatasetInfo(datasetTrain);
    model = load([outFolder '/wStruct_alpha_' num2str(ctrl.alpha) '.mat']);
    w = model.w;
    disp('Model Loaded');
end

%----------------------------------------------------------------------Test
if test
    ctrlCopy = ctrl;
    biases = [ 0.9, 0.8, 0.7, 0.6, 0.4, 0.3, 0.2, 0.1, 0.5 ];
    allPrecisions = zeros( size( biases ) );
    allRecalls    = zeros( size( biases ) );
    parfor i = 1:length( biases )
        
        
        disp( [ 'Bias = ', num2str( biases( i ) ) ] );
        ctrlCopy = ctrl;
        ctrlCopy.bias = biases( i );
        [files, imExt, dataFolder, outFolder,~,tol] = loadDatasetInfo(datasetTest);
        for imNum = 1:numel(files)
            if imNum == 1
                prec = zeros(numel(files),1);
                rec = zeros(numel(files),1);
            end
            %disp(['Testing on Image ' num2str(imNum) '/' num2str(numel(files))]);
            [centers, mask, dots, prediction, img, sizeMSER, r, gt, nFeatures] =...
                testCellDetect(w,datasetTest,imNum,parameters,ctrlCopy,inspectResults);
            
            %imwrite(mask, [outFolder '/mask_' files{imNum} '.tif'],'tif');
            %save([outFolder '/' files{imNum} '.mat'],'dots');

            if ~isempty(gt)
                %if imNum == 1
                %    prec = zeros(numel(files),1);
                %    rec = zeros(numel(files),1);
                %end
                [prec(imNum), rec(imNum)] = evalDetect(dots(:,2),dots(:,1),...
                    gt(:,2), gt(:,1), ones(size(img)),tol);
                disp('Matching result: '); 
                disp(['Precision: ' num2str(prec(imNum)) ' Recall: ' num2str(rec(imNum))]);
                disp(' ');
            end

            if inspectResults > 0
                disp('Press any key to continue');
                pause;
            end
        end
        
        disp(['Mean Precision: ' num2str(mean(prec)) ]);
        disp(['Mean Recall: ' num2str(mean(rec)) ]);
        allPrecisions( i ) = mean( prec );
        allRecalls(    i ) = mean( rec );
        disp(' ');
    end
    
end

%Print simple evaluation results if available
% if exist('prec','var')
%     disp('--Evaluation results (Matching)--');
%     disp(['Mean Precision: ' num2str(mean(prec)) ]);
%     disp(['Mean Recall: ' num2str(mean(rec)) ]);
%     allPrecisions( i ) = mean( prec );
%     allRecalls(    i ) = mean( rec );
%     disp(' ');
% end

%--------------------------------------------------------------------Finish
if ctrl.runPar
    delete(gcp('nocreate'));
end
%clear;