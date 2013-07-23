function[SOURCE_LINK, SINK_LINK] = setSourceSinkSample(SOURCE_LINK, SINK_LINK, LINK, deltaTinSecond)

global sensorMode

% linkIDs = SOURCE_LINK.keys;
for i = 1 : length(SOURCE_LINK)
    link = SOURCE_LINK(i);    
    
    outgoingLink = LINK(link.outgoingLinkID);
    link.vmax = outgoingLink.vmax;
    link.dmax = outgoingLink.dmax;
    link.dc =  outgoingLink.dc;
    
    if sensorMode == 2
        flowDataSum = link.densityResult * 60 * (60/deltaTinSecond);
        for j = 1 : length(flowDataSum)
            if flowDataSum(j) == receiving(outgoingLink.densityResult(1,1,1),link.vmax,link.dmax,link.dc)
                densityDataSum(j) = link.dmax - flowDataSum(j)./(link.vmax*link.dc)*(link.dmax-link.dc);
            else
                densityDataSum(j) = min(link.dc, flowDataSum(j)/link.vmax);
            end
        end
        link.densityResult = densityDataSum;
    else
        disp('there is error in setting sensorMode');
    end
       
    SOURCE_LINK(i) = link;
end

% linkIDs = SINK_LINK.keys;
for i = 1 : length(SINK_LINK)
    link = SINK_LINK(i);
    
    incomingLink = LINK(link.incomingLinkID);
    link.vmax = incomingLink.vmax;
    link.dmax = incomingLink.dmax;
    link.dc =  incomingLink.dc;
    
    if sensorMode == 2
        flowDataSum = link.densityResult * 60 * (60/deltaTinSecond);
        densityDataSum = min(link.dc, flowDataSum ./ link.vmax);
        link.densityResult = densityDataSum;
        
        for j = 1 : length(flowDataSum)
            if flowDataSum(j) == sending(outgoingLink.densityResult(1,1,1),link.vmax,link.dmax,link.dc)
                densityDataSum(j) = max(link.dmax - flowDataSum(j)./(link.vmax*link.dc)*(link.dmax-link.dc), 0);
            else
                densityDataSum(j) = link.dmax - flowDataSum(j)./(link.vmax*link.dc)*(link.dmax-link.dc);
            end
        end
            
        
    else
        disp('there is error in setting sensorMode');
    end
    
    SINK_LINK(i) = link;
end