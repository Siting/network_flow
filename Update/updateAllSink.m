function[sinkFeed] = updateAllSink(SINK_LINK,page,nT, LINK, deltaTinSecond)

global sensorMode

for i = 1 : length(SINK_LINK)
    link = SINK_LINK(i);
    incomingLinkID = link.incomingLinkID;
    incomingLink = LINK(incomingLinkID);
    
    if sensorMode == 2
        flowDataSum = link.densityResult(ceil((page-1)/nT)) * 60 * (60/deltaTinSecond);
        flowDataSum(find(flowDataSum>link.vmax*link.dc))= link.vmax*link.dc;
        if flowDataSum == receiving(incomingLink.densityResult(1,1,end),link.vmax,link.dmax,link.dc)
%             densityDataSum = link.dmax - flowDataSum./(link.vmax*link.dc)*(link.dmax-link.dc);
            densityDataSum = flowDataSum/link.vmax;
        else
%             densityDataSum = link.dmax - flowDataSum./(link.vmax*link.dc)*(link.dmax-link.dc);
            densityDataSum = flowDataSum/link.vmax;
        end
        sinkFeed(incomingLinkID) = densityDataSum;
    elseif sensorMode == 1
        
        sinkFeed(incomingLinkID) = link.densityResult(ceil((page-1)/nT));
    else
        disp('there is error assigning sensorMode');
    end
end