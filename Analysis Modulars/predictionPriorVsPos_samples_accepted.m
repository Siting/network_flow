clear all
clc

global boundarySourceSensorIDs
global boundarySinkSensorIDs
global testingSensorIDs
global sensorDataSource
global samplingModeVmax
global samplingModeDmax
global samplingModeDc
global sensorMode

series = 22;
stage = 10;
numSamplesStudied = 5;
startTimeStamp = 5;
studyLinks = [1; 3; 5; 7];
cali_configID = 42;
cali_paraID = 42;
simu_configID = series + 100;
boundarySourceSensorIDs = [400468; 402955; 402954; 402950];
boundarySinkSensorIDs = [402953; 400698];
testingSensorIDs = [400739; 400363];
sensorDataSource = 2;
samplingModeVmax = 1;
samplingModeDmax = 2;
samplingModeDc = 2;
sensorMode = 2;

% load prior and posterior
fileName = (['.\Configurations\fundamental_setting\FUN_CONFIG-' num2str(cali_configID) '.csv']);
fid=fopen(fileName);
funForLinks=textscan(fid,'%d %f %f %f %f %f %f','delimiter',',','headerlines',1);
vmax_mean = funForLinks{2};
dmax_mean = funForLinks{3};
dc_mean = funForLinks{4};
vmax_var = funForLinks{5};
dmax_var = funForLinks{6};
dc_var = funForLinks{7};
fclose(fid);
load(['.\ResultCollection\series' num2str(series) '\-calibrationResult.mat']);

% load CONFIG & PARA &...
load(['.\Configurations\configs\CONFIG-' num2str(cali_paraID) '.mat']);
load(['.\Configurations\parameters\PARAMETER-' num2str(cali_paraID) '.mat']);
load([CONFIG.caliNetworkID, '-graph.mat']);

% directories
simu_sensorEvolutionDataFolder = ['.\Result\testingData\config-' num2str(simu_configID)];
simu_linkEvolutionDataFolder = ['.\Result\evolutionData\config-' num2str(simu_configID)];
mkdir(simu_sensorEvolutionDataFolder);
mkdir(simu_linkEvolutionDataFolder);

% load noisy sensor data
[sensorDataMatrix] = getNoisySensorData_network(testingSensorIDs, PARAMETER.T,...
    PARAMETER.startTime, PARAMETER.endTime);

ROUND_SAMPLES = initializeAllSamples(linkMap);
% SIMULATION
for sample = 1 : (2 * numSamplesStudied)
    [LINK, JUNCTION, SOURCE_LINK, SINK_LINK] = preloadAndCompute(linkMap, nodeMap, PARAMETER.T, PARAMETER.startTime, PARAMETER.endTime);
    
    load('C:\Users\Siting\Desktop\network_flow\ResultCollection\series22\-acceptedPop-stage-10.mat');
    for i = 1 : size(meanForRounds,2)
        FUNDAMENTAL(i).vmax = ACCEPTED_POP(i).samples(1,sample);
        FUNDAMENTAL(i).dmax = ACCEPTED_POP(i).samples(2,sample);
        FUNDAMENTAL(i).dc = ACCEPTED_POP(i).samples(3,sample);
    end
    
    % run simulation
    [LINK, ROUND_SAMPLES] = runSimulationForSample(FUNDAMENTAL, PARAMETER, CONFIG, simu_configID, sample, simu_sensorEvolutionDataFolder,...
        LINK, JUNCTION, SOURCE_LINK, SINK_LINK, ROUND_SAMPLES);
    
    % all links density results
    save([simu_linkEvolutionDataFolder '\LINK-CONFIG-' num2str(cali_configID) '-sample-' num2str(sample)],'LINK');
    
    % get model simulation data (cumulative)
    modelDataMatrix = getModelSimulation_analyze(simu_configID, sample, testingSensorIDs, PARAMETER.T, PARAMETER.deltaTinSecond, ROUND_SAMPLES);
    
    % save cumulative density Matrix
    save([simu_sensorEvolutionDataFolder '\' num2str(sample) '\cumuDensity'],'modelDataMatrix');
    
    if mod(sample, 2) == 0
        disp(['sample ' num2str(sample) ' is finished']);
    end
end


% PLOT
figure
for i = 1 : length(testingSensorIDs)
    
    subplot(2,1,i)
    
    for j = 1 : (1 * numSamplesStudied)
        load(['.\Result\testingData\config-' num2str(simu_configID) '\' num2str(j) '\cumuDensity.mat']);  % prior
        density = modelDataMatrix(:,i);
        h(1) = plot(density(startTimeStamp:end),'r');
        hold on
    end
    
    for j = (numSamplesStudied+1) : (2 * numSamplesStudied)
        load(['.\Result\testingData\config-' num2str(simu_configID) '\' num2str(j) '\cumuDensity.mat']);  % prior
        density = modelDataMatrix(:,i);
        h(2) = plot(density(startTimeStamp:end),'k');
    end
    
    sensorData = sensorDataMatrix(:,i);
    h(3) = plot(sensorData(startTimeStamp+1:end), 'g');
    xlabel('time');
    ylabel('density');
    legend(h,'prior', 'posterior','true');
    hold off

    saveas(gcf, ['../Plots\series' num2str(series) '\predictionSensorPriorVsPos_sensor_ ' num2str(testingSensorIDs(i)) '_samples.pdf']);
    saveas(gcf, ['../Plots\series' num2str(series) '\predictionSensorPriorVsPos_sensor_ ' num2str(testingSensorIDs(i)) '_samples.fig']);
    saveas(gcf, ['../Plots\series' num2str(series) '\predictionSensorPriorVsPos_sensor_ ' num2str(testingSensorIDs(i)) '_samples.eps'], 'epsc');
end
