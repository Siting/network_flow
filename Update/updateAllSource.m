function[sourceFeed] = updateAllSource(SOURCE_LINK,page,nT, LINK, deltaTinSecond)

% linkIds = SOURCE_LINK.keys;
global sensorMode
for i = 1 : length(SOURCE_LINK)
    link = SOURCE_LINK(i);
    outgoingLinkID = link.outgoingLinkID;
    outgoingLink = LINK(outgoingLinkID);
    if sensorMode == 2
        flowDataSum = link.densityResult(ceil((page-1)/nT)) * 60 * (60/deltaTinSecond);
        flowDataSum(find(flowDataSum>link.vmax*link.dc))= link.vmax*link.dc;
        if flowDataSum == receiving(outgoingLink.densityResult(1,1,end),link.vmax,link.dmax,link.dc)
            densityDataSum = flowDataSum/link.vmax;
%             densityDataSum = link.dmax - flowDataSum(j)./(link.vmax*link.dc)*(link.dmax-link.dc);
        else
            densityDataSum = flowDataSum/link.vmax;
        end
        sourceFeed(outgoingLinkID) = densityDataSum;
    elseif sensorMode == 1
        sourceFeed(outgoingLinkID) = link.densityResult(ceil((page-1)/nT));
    else
        disp('there is error assigning sensorMode');
    end
end