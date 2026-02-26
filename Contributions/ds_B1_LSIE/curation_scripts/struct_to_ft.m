function ftData = struct_to_ft(struct)
% This script was written to convert IMU.mat files from the LSIE data set

hdr.Fs                  = struct.samplingRate;
hdr.nFs                 = round(struct.samplingRate);
hdr.nSamplesPre         = 0;
hdr.nSamples            = size(struct.dataArray,2);
hdr.nTrials             = 1;
hdr.FirstTimeStamp      = 0;
hdr.nChans              = size(struct.dataArray,1)*size(struct.dataArray,3);
hdr.label               = cell(hdr.nChans, 1);
hdr.chantype            = cell(hdr.nChans, 1);
hdr.chanunit            = cell(hdr.nChans, 1);

iT = 1;
for indP = 1:numel(struct.axisValue{3})
    for indC = 1:numel(struct.axisValue{1})
        hdr.label{iT}        = 'unknown'; % merely a placeholder at this step 
        hdr.chantype{iT}     = 'unknown';
        hdr.chanunit{iT}     = 'unknown';
        iT = iT + 1; 
    end
end

% keep the original header details
data = struct.dataArray;
[nChan, nTime, nTrials] = size(data);
ftData.trial = {reshape(data, nChan*nTrials, nTime)};
ftData.time     = {linspace(0,hdr.nSamples*1/hdr.Fs,hdr.nSamples)};
ftData.hdr      = hdr;
ftData.label    = hdr.label;
end