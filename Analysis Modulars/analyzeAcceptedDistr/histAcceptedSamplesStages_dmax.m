clear all
clc

series = 20;
studyStages = [1;2;4;5];
studyLinks = [1;3;5;7];
xlimLow = 100;
xlimHigh = 250;

for j = 1 : length(studyLinks)
    link = studyLinks(j);
    for i = 1 : length(studyStages)
        stage = studyStages(i);
        load(['.\ResultCollection\series' num2str(series) '\-acceptedPop-stage-' num2str(stage) '.mat']);
        figure(j)
        subplot(ceil(length(studyStages))/2,2,i)
        hist(ACCEPTED_POP(link).samples(2,:));
        xlim([xlimLow xlimHigh]);
        xlabel('\rho_{max}');
        title(['stage ' num2str(stage) ' of link ' num2str(link)]);
        hold on
    end   
    hold off
    
    saveas(gcf, ['../Plots\series' num2str(series) '\acceptedSamplesHist_link_' num2str(link) '_dmax.pdf']);
    saveas(gcf, ['../Plots\series' num2str(series) '\acceptedSamplesHist_link_' num2str(link) '_dmax.fig']);
    saveas(gcf, ['../Plots\series' num2str(series) '\acceptedSamplesHist_link_' num2str(link) '_dmax.eps'], 'epsc');
end


