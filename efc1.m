%% Loading and initialization
clear;
close all;
clc;

% iMac
cd('/Users/aghavampour/Desktop/Projects/ExtFlexChord/EFC1');
addpath('/Users/aghavampour/Desktop/Projects/ExtFlexChord/EFC1/functions');
addpath('/Users/aghavampour/Desktop/Projects/ExtFlexChord/EFC1')
addpath(genpath('/Users/aghavampour/Documents/MATLAB/dataframe-2016.1'),'-begin');

% macbook
% cd('/Users/alighavam/Desktop/Projects/ExtFlexChord/efc1');
% addpath('/Users/alighavam/Desktop/Projects/ExtFlexChord/efc1/functions');
% addpath('/Users/alighavam/Desktop/Projects/ExtFlexChord/efc1')
% addpath(genpath('/Users/alighavam/Documents/MATLAB/dataframe-2016.1'),'-begin')

% temporary fix:
% loading data
% analysisDir = '/Users/alighavam/Desktop/Projects/ExtFlexChord/efc1/analysis';
analysisDir = '/Users/aghavampour/Desktop/Projects/ExtFlexChord/EFC1/analysis';  % iMac
cd(analysisDir)
matFiles = dir("*.mat");
data = {};
cnt = 1;
for i = 1:length(matFiles)
    tmp = load(matFiles(i).name);
    if (length(tmp.BN) >= 2420 && ~strcmp(matFiles(i).name(6:11),'subj03'))         % more than or equal to 24 runs
        data{cnt,1} = tmp;
        data{cnt,2} = matFiles(i).name(6:11);
        cnt = cnt + 1;
    end
end

% temporary fix for the ongoing data recording
dataTmp = [];
for i = 1:size(data,1)
    if (length(unique(data{i,1}.BN)) >= 37 && length(unique(data{i,1}.BN)) <= 47)   % if data was not complete
        for j = 1:length(data{i,1}.BN)
            if (data{i,1}.BN(j) <= 36)
                dataTmp = addstruct(dataTmp,getrow(data{i,1},j),'row','force');
            end
        end
        data{i,1} = dataTmp;
    end
end

% temporary RT correction:
for i = 1:size(data,1)  % loop on subjects
    for i_t = 1:length(data{i,1}.BN)  % loop on trials
        if (data{i,1}.trialErrorType(i_t) == 1)     % errorType: '1'->planning error , '2'->exec error
            data{i,1}.RT(i_t) = 0;
        end
    end
end

% setting the RT type before any analysis:
RTtype = 'full'; % RT type

if (strcmp(RTtype,'full'))
    disp('RT type = full')
end
if (strcmp(RTtype,'firstRT'))
    disp('RT type = firstRT')
    for i = 1:size(data,1)  % loop on subjects
        disp(i)
        for i_t = 1:length(data{i,1}.BN)  % loop on trials
            [firstRT,~] = getSeparateRT(getrow(data{i,1},i_t));
            data{i,1}.RT(i_t) = firstRT+600;
        end
    end
end
if (strcmp(RTtype,'execRT'))
    disp('RT type = execRT')
    for i = 1:size(data,1)  % loop on subjects
        disp(i)
        for i_t = 1:length(data{i,1}.BN)  % loop on trials
            [~,execRT] = getSeparateRT(getrow(data{i,1},i_t));
            data{i,1}.RT(i_t) = execRT+600;
        end
    end
end


%% analysis
clc;
clearvars -except data
close all;

% global params:
corrMethod = 'pearson';
includeSubjAvgModel = 0;

% theta calc params:
onlyActiveFing = 0;
firstTrial = 2;
selectRun = -2;
durAfterActive = 200;
clim = [0,1];

% medRT params:
excludeChord = [];

% ====DATA PREP====
% efc1_analyze('all_subj'); % makes the .mat files from .dat and .mov of each subject

% ====ANALISYS====
% efc1_analyze('RT_vs_run',data,'plotfcn','median');

rho_medRT_WithinSubject = efc1_analyze('corr_within_subj_runs',data,'corrMethod',corrMethod,'excludeChord',excludeChord);

rho_medRT_acrossSubj = efc1_analyze('corr_across_subj',data,'plotfcn',1,'clim',clim,'corrMethod',corrMethod,'excludeChord',excludeChord);

rho_medRT_AvgModel = efc1_analyze('corr_medRT_avg_model',data,'corrMethod',corrMethod,'excludeChord',excludeChord,'includeSubj',includeSubjAvgModel);

thetaCell = efc1_analyze('thetaExp_vs_thetaStd',data,'durAfterActive',durAfterActive,'plotfcn',0,...
                        'firstTrial',firstTrial,'onlyActiveFing',onlyActiveFing,'selectRun',selectRun);

rho_theta_acrossSubj = efc1_analyze('corr_mean_theta_across_subj',data,'thetaCell',thetaCell,'onlyActiveFing',onlyActiveFing, ...
                                    'firstTrial',firstTrial,'corrMethod',corrMethod,'plotfcn',1,'clim',clim);

rho_theta_avgModel = efc1_analyze('corr_mean_theta_avg_model',data,'thetaCell',thetaCell,'onlyActiveFing',onlyActiveFing, ...
                                    'firstTrial',firstTrial,'corrMethod',corrMethod,'includeSubj',includeSubjAvgModel);

biasVarCell = efc1_analyze('theta_bias',data,'durAfterActive',durAfterActive,'selectRun',selectRun,...
                            'firstTrial',firstTrial,'plotfcn',0);

[meanDevCell,rho_meanDev_acrossSubj] = efc1_analyze('meanDev',data,'selectRun',selectRun,...
                                                    'corrMethod',corrMethod,'plotfcn',0,'clim',clim);

rho_meanDev_avgModel = efc1_analyze('corr_meanDev_avg_model',data,'selectRun',selectRun,'corrMethod',corrMethod,...
                                    'includeSubj',includeSubjAvgModel);

% [rho_OLS_medRT, crossValModels_medRT, singleSubjModel_medRT] = efc1_analyze('reg_OLS_medRT',data,...
%     'regSubjNum',0,'excludeChord',excludeChord,'corrMethod',corrMethod);

% [rho_OLS_meanTheta, crossValModels_meanTheta, singleSubjModel_meanTheta] = efc1_analyze('reg_OLS_meanTheta',data,...
%     thetaCell,'regSubjNum',0,'corrMethod',corrMethod,'onlyActiveFing',onlyActiveFing,'firstTrial',firstTrial);

% efc1_analyze('plot_scatter_within_subj',data,'transform_type','ranked')

% efc1_analyze('plot_scatter_across_subj',data,'transform_type','no_transform')

% efc1_analyze('meanTheta_scatter_across_subj',data,thetaCell,'onlyActiveFing',onlyActiveFing,'firstTrial',firstTrial




%% ========================================================================
%% TEMPORARY CODES AND ANALYSIS FROM HERE !<UNDER CONSTRUCTION>!
%% ========================================================================

%% pie chart
clc;
close all;
clearvars -except data

selectRun = -2;
holdTime = 600;
baseLineForceOption = 0;    % if '0', then the baseline force will be considerred [0,0,0,0,0]. If not,
                            % baseline force will be considerred the avg
                            % force during baseline duration.
durAfterActive = 200;

forceData = cell(size(data));   % extracting the force signals for each subj
for i = 1:size(data,1)
    forceData{i,1} = extractDiffForce(data{i,1});
    forceData{i,2} = data{i,2};
end

outCell = cell(size(data));
for subj = 1:size(data,1)
    outCell{subj,2} = data{subj,2};
    chordVec = generateAllChords();  % all chords
    subjData = data{subj,1};
    subjForceData = forceData{subj,1};
    outCellSubj = cell(length(chordVec),2);
    vecBN = unique(subjData.BN);
    for i = 1:length(chordVec)
        outCellSubj{i,2} = chordVec(i);
        outCellSubj{i,1} = cell(1,3);

        if (selectRun == -1)        % selecting the last 12 runs
            trialIdx = find(subjData.chordID == chordVec(i) & subjData.trialErrorType ~= 1 & subjData.BN > vecBN(end-12));
        elseif (selectRun == -2)    % selectign the last 24 runs
            trialIdx = find(subjData.chordID == chordVec(i) & subjData.trialErrorType ~= 1 & subjData.BN > vecBN(end-24));
        elseif (selectRun == 1)     % selecting the first 12 runs
            trialIdx = find(subjData.chordID == chordVec(i) & subjData.trialErrorType ~= 1 & subjData.BN < 13);
        elseif (selectRun == 2)
            trialIdx = find(subjData.chordID == chordVec(i) & subjData.trialErrorType ~= 1 & subjData.BN > 12 & subjData.BN < 25);
        elseif (selectRun == 3)
            trialIdx = find(subjData.chordID == chordVec(i) & subjData.trialErrorType ~= 1 & subjData.BN > 24 & subjData.BN < 37);
            iTmp = find(subjData.BN > 24 & subjData.BN < 37,1);
            if (isempty(iTmp))
                error("Error with <selectRun> option , " + data{subj,2} + " does not have block number " + num2str(selectRun))
            end
        else
            error("selectRun " + num2str(selectRun) + "does not exist. Possible choices are 1,2,3,-1 and -2.")
        end

        
        if (~isempty(trialIdx))
            chordTmp = num2str(chordVec(i));
            forceVec_i_holder = [];
            idealVec = zeros(1,5);
            for trial_i = 1:length(trialIdx)
                forceTrial = subjForceData{trialIdx(trial_i)};
                baselineIdx = forceTrial(:,1) == 2;
                execIdx = find(forceTrial(:,1) == 3);
                execIdx = execIdx(end-holdTime/2:end); % 2ms is sampling frequency hence the holdTime/2
                
                avgBaselineForce = mean(forceTrial(baselineIdx,3:7),1);
                if (baseLineForceOption == 0)
                    avgBaselineForce = zeros(1,5);
                end
                avgExecForce = mean(forceTrial(execIdx,3:7),1);
                idealVec = idealVec + (avgExecForce - avgBaselineForce)/length(trialIdx);

                forceTmp = [];
                tVec = subjForceData{trialIdx(trial_i)}(:,2); % time vector in trial
                tGoCue = subjData.planTime(trialIdx(trial_i));
                for j = 1:5     % thresholded force of the fingers after "Go Cue"
                    if (chordTmp(j) == '1') % extension
                        forceTmp = [forceTmp (subjForceData{trialIdx(trial_i)}(tVec>=tGoCue,2+j) > subjData.baselineTopThresh(trialIdx(trial_i)))]; 
                        if (isempty(find(forceTmp(:,end),1)))
                            forceTmp(:,end) = [];
                        end
                    elseif (chordTmp(j) == '2') % flexion
                        forceTmp = [forceTmp (subjForceData{trialIdx(trial_i)}(tVec>=tGoCue,2+j) < -subjData.baselineTopThresh(trialIdx(trial_i)))]; 
                        if (isempty(find(forceTmp(:,end),1)))
                            forceTmp(:,end) = [];
                        end
                    elseif (chordTmp(j) == '9') % finger should be relaxed
                        forceTmp = [forceTmp (subjForceData{trialIdx(trial_i)}(tVec>=tGoCue,2+j) < -subjData.baselineTopThresh(trialIdx(trial_i)) ...
                            | subjForceData{trialIdx(trial_i)}(tVec>=tGoCue,2+j) > subjData.baselineTopThresh(trialIdx(trial_i)))]; 
                        if (isempty(find(forceTmp(:,end),1)))
                            forceTmp(:,end) = [];
                        end
                    end
                end
                if (isempty(find(forceTmp,1)))  % if no fingers moved out of threshold, go to next trial
                    disp("empty trial")
                    continue
                end
    
                tmpIdx = [];
                for k = 1:size(forceTmp,2)
                    tmpIdx(k) = find(forceTmp(:,k),1);
                end
                [sortIdx,~] = sort(tmpIdx); % sortIdx(1) is the first index after "Go Cue" that the first finger crossed the baseline thresh
                idxStart = find(tVec==tGoCue)+sortIdx(1)-1; % index that the first finger passes the baseline threhold after "Go Cue"
                
                forceSelceted = [];
                for j = 1:5     % getting the force from idxStart to idxStart+durAfterActive
                    forceSelceted = [forceSelceted subjForceData{trialIdx(trial_i)}(idxStart:idxStart+round(durAfterActive/2),2+j)];
                end
                forceVec_i = mean(forceSelceted,1);  % average of finger forces in the first {durAfterActive} ms
                forceVec_i_holder = [forceVec_i_holder ; forceVec_i/norm(forceVec_i)];
            end

            outCellSubj{i,1}{1} = forceVec_i_holder;
            outCellSubj{i,1}{2} = repmat(idealVec/norm(idealVec),size(forceVec_i_holder,1),1);
            outCellSubj{i,1}{3} = [ones(size(forceVec_i_holder,1),1)*i (1:size(forceVec_i_holder,1))'];
        else
            outCellSubj{i,1} = [];
        end 
    end
    outCell{subj,1} = outCellSubj;
end

% Making regressors:
y = [];     % dependent variable -> N by 5 matrix
X1 = [];    % chord -> N by 242 matrix
X2 = [];    % chord and subj -> N by 242*6 matrix
labels = [];
chordIDVec = [];
for subj = 1:size(outCell,1)
    tmp = outCell{subj,1};
    forceVec = [tmp{:,1}]';
    idealVec = forceVec(2:3:end);
    tmpChord = forceVec(3:3:end);
    forceVec = forceVec(1:3:end);
    idealVec = vertcat(idealVec{:});
    forceVec = vertcat(forceVec{:});
    tmpChord = vertcat(tmpChord{:});
    labels = [labels ; [subj*ones(size(tmpChord,1),1),tmpChord]];
    tmpChord = tmpChord(:,1);
    X1_tmp = zeros(size(tmpChord,1),242);
    X2_tmp = zeros(size(tmpChord,1),242*6);
    val = unique(tmpChord);
    
    for i = 1:length(val)
        X1_tmp(tmpChord==val(i),val(i)) = 1;
        X2_tmp(tmpChord==val(i),(subj-1)*242+val(i)) = 1;
    end
    chordIDVec = [chordIDVec ; tmpChord];
    X1 = [X1 ; X1_tmp];
    X2 = [X2 ; X2_tmp];
    y = [y;idealVec-forceVec];
    
end

% mean cetnering the dependent variable (for simpler matrix calculations):
y = y - repmat(mean(y,1),size(y,1),1);

% Least squared estimation:
[beta1,SSR_X1,SST] = myOLS(y,X1);
[beta2,SSR_X2,SST] = myOLS(y,X2);

% var explained by each model:
chordVar = SSR_X1/SST*100;
subjVar = SSR_X2/SST*100;
fprintf("whole var explained by single models:\nChord = %.4f , Chord-Subj = %.4f\n\n\n",chordVar,subjVar);

% ====== Residual regresison:
[beta1,SSR_X1,SST_y] = myOLS(y,X1);
y_res = y - X1 * beta1;
[beta2,SSR_X2,SST_y_res] = myOLS(y_res,X2);

% var explained:
chordVar = SSR_X1/SST_y * 100;
subjVar = SSR_X2/SST_y * 100;
trialVar = 100 - (chordVar + subjVar);
%fprintf("var explained:\nChord = %.4f , Chord-Subj = %.4f , Trial = %.4f\n\n\n",chordVar,subjVar,trialVar);


%%
clc;
% Simulations ===============================================
% random noise simulation
y = makeSimData(size(y,1),5,'random',[0,1]);

% ====== Regresison:
[beta,SSR,SST] = myOLS(y,[X1,X2],labels,'subj_crossVal');

% var explained:
chordVar = mean(SSR(:,1)./SST) * 100;
subjVar = mean((SSR(:,2) - SSR(:,1))./SST) * 100;
trialVar = 100 - (chordVar + subjVar);
fprintf("Sim Noisy data:\nChord = %.4f , Chord-Subj = %.4f , Trial = %.4f\n\n\n",chordVar,subjVar,trialVar);

% Model simulation
varChord = 1;
varSubj = 1;
varEps = 0;
y = makeSimData(size(y,1),5,'model',{{X1,X2},[varChord,varSubj,varEps]});
y = y - repmat(mean(y,1),size(y,1),1);

%%
% ====== Residual regresison:
[beta,SSR,SST] = myOLS(y,[X1,X2],labels,'shuffle_trial_crossVal');

% var explained:
chordVar = mean(SSR(:,1)./SST) * 100;
subjVar = mean((SSR(:,2) - SSR(:,1))./SST) * 100;
trialVar = 100 - (chordVar + subjVar);

fprintf("Sim Model data:\nChord = %.4f , Chord-Subj = %.4f , Trial = %.4f\n",chordVar,subjVar,trialVar);
total = varChord+varSubj+varEps;
fprintf("Theoretical:\nChord = %.4f , Chord-Subj = %.4f , Trial = %.4f\n\n\n",varChord/total*100,varSubj/total*100,varEps/total*100);


%% Model Testing
clc;
close all;
clearvars -except data

% global params:
dataName = "meanDev";
corrMethod = 'pearson';

% theta calc params:
onlyActiveFing = 0;
firstTrial = 2;
selectRun = -2;
durAfterActive = 200;

% medRT params:
excludeChord = [];


featureCell = {"singleFingExt","numActiveFing-oneHot","singleFinger",...
    "neighbourFingers+singleFinger","singleFinger+2FingerCombinations","all"};

efc1_analyze('modelTesting',data,'dataName',dataName,'featureCell',featureCell,'corrMethod',corrMethod,'onlyActiveFing',onlyActiveFing,...
            'firstTrial',firstTrial,'selectRun',selectRun,'durAfterActive',durAfterActive,'excludeChord',excludeChord);


%% variability of finger forces 
% meand and var of finger forces during baseline interval, inactive and
% active for each subject.
clc;
clearvars -except data
close all;

holdTime = 600; % chord hold time = 600ms

baselineForceCell = cell(size(data,1),3);
execForceCell = cell(size(data,1),3);
for subj = 1:size(data,1)
    dataTmp = data{subj,1};
    forces = extractDiffForce(dataTmp); % force signals
    correctTrialIdx = find(dataTmp.trialErrorType == 0);   % correct trials
    subj_baselineForceMat = zeros(length(correctTrialIdx),5);
    subj_execForceMat = zeros(length(correctTrialIdx),5);
    for j = 1:length(correctTrialIdx)
        forceTmp = forces{correctTrialIdx(j)};
        baselineIdx = find(forceTmp(:,1) == 2);
        execIdx = find(forceTmp(:,1) == 3);
        execIdx = execIdx(end-holdTime/2:end);
        
        baselineForce = forceTmp(baselineIdx,3:end);
        execForce = forceTmp(execIdx,3:end);

        subj_baselineForceMat(j,:) = mean(baselineForce,1);
        subj_execForceMat(j,:) = mean(execForce,1);
        
    end
    baselineForceCell{subj,1} = subj_baselineForceMat;
    execForceCell{subj,1} = subj_execForceMat;
    baselineForceCell{subj,2} = data{subj,2};
    execForceCell{subj,2} = data{subj,2};
    baselineForceCell{subj,3} = correctTrialIdx;
    execForceCell{subj,3} = correctTrialIdx;
end

% baseline force plot
figure;
for subj = 1:size(baselineForceCell,1)
    tmpForceMat = baselineForceCell{subj,1};
    avgFingForce = mean(tmpForceMat,1);
    stdFingForce = std(tmpForceMat,[],1);
    baselineTopThreshold = data{subj,1}.baselineTopThresh(1);
    subplot(2,3,subj);
    scatter([1,2,3,4,5],avgFingForce,60,'k','filled')
    hold on
    errorbar([1,2,3,4,5],avgFingForce,stdFingForce,'LineStyle','none','Color','k')
    hold on
    line([0,6],[-baselineTopThreshold -baselineTopThreshold],'Color','r','LineStyle','--')
    hold on
    line([0,6],[baselineTopThreshold baselineTopThreshold],'Color','r','LineStyle','--')
    ylim([-6,6])
    xlim([0,6])
    xticks(1:5)
    xticklabels({'finger 1', 'finger 2', 'finger 3', 'finger 4', 'finger 5'})
    ylabel('avg force (N)')
    title(sprintf("baseline , %s",baselineForceCell{subj,2}))
end

% exec inactive force plot
figure;
for subj = 1:size(baselineForceCell,1)
    baselineTopThreshold = data{subj,1}.baselineTopThresh(1);
    tmpForceMat = execForceCell{subj,1};
    tmpForceMat(tmpForceMat > baselineTopThreshold | tmpForceMat < -baselineTopThreshold) = 0;
    avgFingForce = zeros(1,5);
    stdFingForce = zeros(1,5);
    for j = 1:5 % loop over fingers
        tmp = tmpForceMat(:,j);
        tmp(tmp==0) = [];
        avgFingForce(j) = mean(tmp);
        stdFingForce(j) = std(tmp);
    end
    subplot(2,3,subj);
    hold all
    scatter([1,2,3,4,5],avgFingForce,60,'k','filled')
    errorbar([1,2,3,4,5],avgFingForce,stdFingForce,'LineStyle','none','Color','k')
    line([0,6],[-baselineTopThreshold -baselineTopThreshold],'Color','r','LineStyle','--')
    line([0,6],[baselineTopThreshold baselineTopThreshold],'Color','r','LineStyle','--')
    ylim([-6,6])
    xlim([0,6])
    xticks(1:5)
    xticklabels({'finger 1', 'finger 2', 'finger 3', 'finger 4', 'finger 5'})
    ylabel('avg force (N)')
    title(sprintf("execution inactive, %s",baselineForceCell{subj,2}))
end


% exec extension force plot
figure;
for subj = 1:size(baselineForceCell,1)
    baselineTopThreshold = data{subj,1}.baselineTopThresh(1);
    extBotThresh = data{subj,1}.extBotThresh(1);
    extTopThresh = data{subj,1}.extTopThresh(1);
    tmpForceMat = execForceCell{subj,1};
    tmpForceMat(tmpForceMat < baselineTopThreshold) = 0;
    avgFingForce = zeros(1,5);
    stdFingForce = zeros(1,5);
    for j = 1:5 % loop over fingers
        tmp = tmpForceMat(:,j);
        tmp(tmp==0) = [];
        avgFingForce(j) = mean(tmp);
        stdFingForce(j) = std(tmp);
    end
    subplot(2,3,subj);
    hold all
    scatter([1,2,3,4,5],avgFingForce,60,'k','filled')
    errorbar([1,2,3,4,5],avgFingForce,stdFingForce,'LineStyle','none','Color','k')
    line([0,6],[-baselineTopThreshold -baselineTopThreshold],'Color','r','LineStyle','--')
    line([0,6],[baselineTopThreshold baselineTopThreshold],'Color','r','LineStyle','--')
    line([0,6],[extBotThresh extBotThresh],'Color','k')
    line([0,6],[extTopThresh extTopThresh],'Color','k')
    line([0,6],[-extTopThresh -extTopThresh],'Color','k')
    line([0,6],[-extBotThresh -extBotThresh],'Color','k')
    ylim([-6,6])
    xlim([0,6])
    xticks(1:5)
    xticklabels({'finger 1', 'finger 2', 'finger 3', 'finger 4', 'finger 5'})
    ylabel('avg force (N)')
    title(sprintf("extension, %s",baselineForceCell{subj,2}))
end



% exec flexion force plot
figure;
for subj = 1:size(baselineForceCell,1)
    baselineTopThreshold = data{subj,1}.baselineTopThresh(1);
    extBotThresh = data{subj,1}.extBotThresh(1);
    extTopThresh = data{subj,1}.extTopThresh(1);
    tmpForceMat = execForceCell{subj,1};
    tmpForceMat(tmpForceMat > -baselineTopThreshold) = 0;
    avgFingForce = zeros(1,5);
    stdFingForce = zeros(1,5);
    for j = 1:5 % loop over fingers
        tmp = tmpForceMat(:,j);
        tmp(tmp==0) = [];
        avgFingForce(j) = mean(tmp);
        stdFingForce(j) = std(tmp);
    end
    subplot(2,3,subj);
    hold all
    scatter([1,2,3,4,5],avgFingForce,60,'k','filled')
    errorbar([1,2,3,4,5],avgFingForce,stdFingForce,'LineStyle','none','Color','k')
    line([0,6],[-baselineTopThreshold -baselineTopThreshold],'Color','r','LineStyle','--')
    line([0,6],[baselineTopThreshold baselineTopThreshold],'Color','r','LineStyle','--')
    line([0,6],[extBotThresh extBotThresh],'Color','k')
    line([0,6],[extTopThresh extTopThresh],'Color','k')
    line([0,6],[-extTopThresh -extTopThresh],'Color','k')
    line([0,6],[-extBotThresh -extBotThresh],'Color','k')
    ylim([-6,6])
    xlim([0,6])
    xticks(1:5)
    xticklabels({'finger 1', 'finger 2', 'finger 3', 'finger 4', 'finger 5'})
    ylabel('avg force (N)')
    title(sprintf("flexion, %s",baselineForceCell{subj,2}))
end



%% thetaMean avg vs numFingerActive

runVec = [1,2,3,-1];
colors = [[0 0.4470 0.7410];[0.8500 0.3250 0.0980];[0.9290 0.6940 0.1250];[0.4940 0.1840 0.5560];...
    [0.4660 0.6740 0.1880];[0.3010 0.7450 0.9330];[0.6350 0.0780 0.1840]];
figure;
for j = 1:4
    thetaCell = efc1_analyze('thetaExp_vs_thetaStd',data,'durAfterActive',durAfterActive,'plotfcn',0,...
    'firstTrial',firstTrial,'onlyActiveFing',onlyActiveFing,'selectRun',runVec(j));
    [thetaMean,~] = meanTheta(thetaCell,firstTrial);
    chordVec = generateAllChords();
    chordVecSep = sepChordVec(chordVec);
    xVec = [];
    yVec = [];
    for i = 1:size(chordVecSep,1)
        xTmp = repmat(i,size(thetaMean,2)*length(chordVecSep{i,2}),1);
        yTmp = thetaMean(chordVecSep{i,2},:);
        yTmp = yTmp(:);
        xVec = [xVec;xTmp];
        yVec = [yVec;yTmp];
    end
    xVec(isnan(yVec)) = [];
    yVec(isnan(yVec)) = [];
    lineplot(xVec,yVec,'linecolor',colors(j,:));
    title("meanTheta across subjects")
    xlabel("num Finger Active")
    ylabel("meanTheta (degree)")
    hold on
end


%% bias vs numFingerActive

runVec = [1,2,3,-1];
colors = [[0 0.4470 0.7410];[0.8500 0.3250 0.0980];[0.9290 0.6940 0.1250];[0.4940 0.1840 0.5560];...
    [0.4660 0.6740 0.1880];[0.3010 0.7450 0.9330];[0.6350 0.0780 0.1840]];
figure;
for j = 1:4
    biasVarCell = efc1_analyze('theta_bias',data,'durAfterActive',durAfterActive,'selectRun',runVec(j),...
                            'firstTrial',firstTrial);
    biasMat = [biasVarCell{:,1}];
    biasMat(:,1:2:end)=[];
    % in some runs, for some of the chords we get [] for biasVar. 
    % Fixing for that here:
    emptyCells = cellfun(@isempty,biasMat);
    [row,col] = find(emptyCells);
    biasMat(row,:) = [];
    biasMat = cell2mat(biasMat);
    biasMat(:,2:2:end)=[];

    chordVec = generateAllChords();
    chordVec(row,:) = [];
    chordVecSep = sepChordVec(chordVec);

    xVec = [];
    yVec = [];
    for i = 1:size(chordVecSep,1)
        xTmp = repmat(i,size(biasMat,2)*length(chordVecSep{i,2}),1);
        yTmp = biasMat(chordVecSep{i,2},:);
        yTmp = yTmp(:);
        xVec = [xVec;xTmp];
        yVec = [yVec;yTmp];
    end
    xVec(isnan(yVec)) = [];
    yVec(isnan(yVec)) = [];
    lineplot(xVec,yVec,'linecolor',colors(j,:));
    title("biasTheta")
    xlabel("num Finger Active")
    ylabel("biasTheta (degree)")
    hold on
end

%% MeanDev vs numFingerActive

runVec = [1,2,3,-1];
colors = [[0 0.4470 0.7410];[0.8500 0.3250 0.0980];[0.9290 0.6940 0.1250];[0.4940 0.1840 0.5560];...
    [0.4660 0.6740 0.1880];[0.3010 0.7450 0.9330];[0.6350 0.0780 0.1840]];


figure;
for j = 1:4
    meanDev = regressionDataset(data,'meanDev','selectRun',runVec(j),'plotfcn',0);

    chordVec = generateAllChords();
    chordVecSep = sepChordVec(chordVec);

    xVec = [];
    yVec = [];
    for i = 1:size(chordVecSep,1)
        xTmp = repmat(i,size(meanDev,2)*length(chordVecSep{i,2}),1);
        yTmp = meanDev(chordVecSep{i,2},:);
        yTmp = yTmp(:);
        xVec = [xVec;xTmp];
        yVec = [yVec;yTmp];
    end
    xVec(isnan(yVec)) = [];
    yVec(isnan(yVec)) = [];
    lineplot(xVec,yVec,'linecolor',colors(j,:));
    title("MeanDev")
    xlabel("num Finger Active")
    ylabel("Avg MeanDev")
    hold on
end



%% median RT over numActiveFinger + mean theta over numActiveFinger
close all;
clc;

chordVec = generateAllChords();
chordVecSep = sepChordVec(chordVec);
colors = [[0 0.4470 0.7410];[0.8500 0.3250 0.0980];[0.9290 0.6940 0.1250];[0.4940 0.1840 0.5560];...
    [0.4660 0.6740 0.1880];[0.3010 0.7450 0.9330];[0.6350 0.0780 0.1840]];

activeVec = zeros(length(chordVec),1);
for i = 1:size(chordVecSep,1)
    activeVec(chordVecSep{i,2}) = i;
end

for i = 1:size(data,1)
    if (length(data{i,1}.BN) >= 2420)
        medRT = cell2mat(calcMedRT(data{i,1},[]));
        lineplot(activeVec,medRT(:,end),'linecolor',colors(i,:),'errorbars',{''});
        legNames{i} = data{i,2};
        hold on
    end
end
legend(legNames,'Location','northwest')
xlabel("num active fingers")
ylabel("average medRT")

% mean theta over numActiveFinger:
chordVec = generateAllChords();
chordVecSep = sepChordVec(chordVec);
colors = [[0 0.4470 0.7410];[0.8500 0.3250 0.0980];[0.9290 0.6940 0.1250];[0.4940 0.1840 0.5560];...
    [0.4660 0.6740 0.1880];[0.3010 0.7450 0.9330];[0.6350 0.0780 0.1840]];
firstTrial = 2;

activeVec = zeros(length(chordVec),1);
for i = 1:size(chordVecSep,1)
    activeVec(chordVecSep{i,2}) = i;
end

thetaMean = zeros(242,size(thetaCell,1));
thetaStd = zeros(242,size(thetaCell,1));
for subj = 1:size(thetaCell,1)
    for j = 11:size(thetaMean,1)
        thetaMean(j,subj) = mean(thetaCell{subj,1}{j,2}(firstTrial:end));
        thetaStd(j,subj) = std(thetaCell{subj,1}{j,2}(firstTrial:end));
    end
end

figure;
for i = 1:size(thetaMean,2)
    lineplot(activeVec,thetaMean(:,i),'linecolor',colors(i,:),'errorbars',{''});
    legNames{i} = data{i,2};
    hold on
end
legend(legNames,'Location','northwest')
xlabel("num active fingers")
ylabel("mean theta")



%% Linear Regression (OLS) - Mean Theta 
clc;
close all;

chordVec = generateAllChords();
chordVecSep = sepChordVec(chordVec);

% features
% num active fingers - continuous:
f1 = zeros(size(chordVec));
for i = 1:size(chordVecSep,1)
    f1(chordVecSep{i,2}) = i;
end
% num active fingers - one hot:
% f1 = zeros(size(chordVec,1),5);
% for i = 1:size(chordVecSep,1)
%     f1(chordVecSep{i,2},i) = 1;
% end

% each finger flexed or not:
f2 = zeros(size(chordVec,1),5);
for i = 1:size(chordVec,1)
    chord = num2str(chordVec(i));
    f2(i,:) = (chord == '2');
end

% each finger extended or not:
f3 = zeros(size(chordVec,1),5);
for i = 1:size(chordVec,1)
    chord = num2str(chordVec(i));
    f3(i,:) = (chord == '1');
end

% second level interactions of finger combinations:
f4Base = [f2,f3];
f4 = [];
for i = 1:size(f4Base,2)-1
    for j = i+1:size(f4Base,2)
        f4 = [f4, f4Base(:,i) .* f4Base(:,j)];
    end
end

firstTrial = 2;

activeVec = zeros(length(chordVec),1);
for i = 1:size(chordVecSep,1)
    activeVec(chordVecSep{i,2}) = i;
end

thetaMean = zeros(242,size(thetaCell,1));
thetaStd = zeros(242,size(thetaCell,1));
for subj = 1:size(thetaCell,1)
    for j = 11:size(thetaMean,1)
        thetaMean(j,subj) = mean(thetaCell{subj,1}{j,2}(firstTrial:end));
        thetaStd(j,subj) = std(thetaCell{subj,1}{j,2}(firstTrial:end));
    end
end

% linear regression for one subj:
features = [f1,f2,f3,f4];
if (onlyActiveFing)
    thetaMean(1:10,:) = [];
    features(1:10,:) = [];
end
[i,~] = find(isnan(thetaMean));
thetaMean(i,:) = [];
features(i,:) = [];

subj = 1;
estimated = thetaMean(:,subj);  
mdl = fitlm(features,estimated)

% cross validated linear regression:
fullFeatures = repmat(features,size(data,1)-1,1);
rho_OLS_meanTheta = cell(1,2);
for i = 1:size(data,1)
    fprintf("\n")
    idx = setdiff(1:size(data,1),i);
    estimated = []; 
    for j = idx
        estimated = [estimated ; thetaMean(:,j)];
    end
    fprintf('%s out:\n',data{i,2})
    mdl = fitlm(fullFeatures,estimated)

    % testing model:
    pred = predict(mdl,features);
    meanThetaOut = thetaMean(:,i);
    
    corrTmp = corr(meanThetaOut,pred,'type',corrMethod);
    rho_OLS_meanTheta{2}(1,i) = convertCharsToStrings(data{i,2});
    rho_OLS_meanTheta{1}(1,i) = corrTmp;
end




%% analysis tmp
clc;
clearvars -except data
close all;

forceData = cell(size(data));
for i = 1:size(data,1)
    forceData{i,1} = extractDiffForce(data{i,1});
    forceData{i,2} = data{i,2};
end


%% visualize force data - examples
clc;
close all;
clearvars -except data forceData

subj = 1;
trial = 3977;
sigTmp = forceData{subj,1}{trial};
fGain4 = data{subj,1}.fGain4(trial);
fGain5 = data{subj,1}.fGain5(trial);
plot(sigTmp(:,2),[sigTmp(:,3:5),fGain4*sigTmp(:,6),fGain5*sigTmp(:,7)])
xline(500,'r','LineWidth',1.5)
hold on
plot([sigTmp(1,2) sigTmp(end,2)],[data{subj,1}.baselineTopThresh data{subj,1}.baselineTopThresh],'k')
hold on
plot([sigTmp(1,2) sigTmp(end,2)],-[data{subj,1}.baselineTopThresh data{subj,1}.baselineTopThresh],'k')
legend({"1","2","3","4","5"})


















%% Correlations of measures
clc;
close all;
clearvars -except data

% global params:
corrMethod = 'pearson';
includeSubjAvgModel = 0;

% theta calc params:
onlyActiveFing = 0;
firstTrial = 2;
selectRun = -2;
durAfterActive = 200;

% medRT params:
excludeChord = [];


medRT = regressionDataset(data,"medRT",'onlyActiveFing',onlyActiveFing,...
            'firstTrial',firstTrial,'selectRun',selectRun,'durAfterActive',durAfterActive);


meanTheta = regressionDataset(data,"meanTheta",'onlyActiveFing',onlyActiveFing,...
            'firstTrial',firstTrial,'selectRun',selectRun,'durAfterActive',durAfterActive);

thetaBias = regressionDataset(data,"thetaBias",'onlyActiveFing',onlyActiveFing,...
            'firstTrial',firstTrial,'selectRun',selectRun,'durAfterActive',durAfterActive);

meanDev = regressionDataset(data,"meanDev",'onlyActiveFing',onlyActiveFing,...
            'firstTrial',firstTrial,'selectRun',selectRun,'durAfterActive',durAfterActive);


mat = [medRT,meanTheta,thetaBias,meanDev];
rho = corr(mat,'type',corrMethod);

figure;
imagesc(rho)
hold on
line([0.50,24.5], [6.50,6.50], 'Color', 'k','LineWidth',2);
line([0.50,24.5], [12.5,12.5], 'Color', 'k','LineWidth',2);
line([0.50,24.5], [18.5,18.5], 'Color', 'k','LineWidth',2);
line([6.50,6.50], [0.50,24.5], 'Color', 'k','LineWidth',2);
line([12.5,12.5], [0.50,24.5], 'Color', 'k','LineWidth',2);
line([18.5,18.5], [0.50,24.5], 'Color', 'k','LineWidth',2);
xticks([1:24])
yticks([1:24])
xticklabels([1:6,1:6,1:6,1:6])
yticklabels([1:6,1:6,1:6,1:6])
colorbar
title(sprintf("measures correlations (left to right: medRT , meanTheta , theta bias , meanDev)"))
xlabel("subject num")
ylabel("subject num")

















