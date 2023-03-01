function efc1_RTvsRun(data,plotfcn)

figure;
for i = 1:size(data,1)  
    tmpData = data{i,1};             % first column of 'data' is the data for each subject
    idx = tmpData.trialPoint~=-1;    % trials without planning error
    subplot(3,2,i)
    lineplot(tmpData.BN(idx),tmpData.RT(idx)-600,'plotfcn',plotfcn);
    xlabel("Run Number")
    ylabel(sprintf("%s RT(ms)",plotfcn))
    title(sprintf("%s",data{i,2}))
end

% lineplot with one plot
figure
colors = [[0 0.4470 0.7410];[0.8500 0.3250 0.0980];[0.9290 0.6940 0.1250];[0.4940 0.1840 0.5560];...
    [0.4660 0.6740 0.1880];[0.3010 0.7450 0.9330];[0.6350 0.0780 0.1840]];
legNames = {};
for i = 1:size(data,1)
    tmpData = data{i,1};
    idx = tmpData.trialPoint~=-1;
    lineplot(tmpData.BN(idx),tmpData.RT(idx)-600,'plotfcn',plotfcn,...
        'markercolor',colors(i,:),'linecolor',colors(i,:),'errorbars',{''});
    xlabel("Run Number")
    ylabel(sprintf("%s RT(ms)",plotfcn))
    title("all subjects")
    hold on
    legNames{i} = data{i,2};
end
legend(legNames)