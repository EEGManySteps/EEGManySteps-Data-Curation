
%--------------------------------------------------------------------------
function [ftdata] = stream2ft(xdfstream)

% construct header
if isfield(xdfstream.info, 'effective_srate')
    hdr.Fs                  = xdfstream.info.effective_srate;
else
    hdr.Fs                  = xdfstream.info.nominal_srate;
end

if ~strcmp(xdfstream.info.type, 'EEG') % if effective srate is missing and type is non-EEG, add Latency channel
    xdfstream.time_series(end+1,:) = xdfstream.time_stamps - xdfstream.time_stamps(1); 
    xdfstream.info.desc.channels.channel{end+1}.label = 'latency';
    xdfstream.info.desc.channels.channel{end}.type = 'latency'; 
    xdfstream.info.desc.channel_count = numel(xdfstream.info.desc.channels.channel); 
end

hdr.nFs                 = str2double(xdfstream.info.nominal_srate);
hdr.nSamplesPre         = 0;
hdr.nSamples            = length(xdfstream.time_stamps);
hdr.nTrials             = 1;
hdr.FirstTimeStamp      = xdfstream.time_stamps(1);
hdr.TimeStampPerSample  = (xdfstream.time_stamps(end)-xdfstream.time_stamps(1)) / (length(xdfstream.time_stamps) - 1);
if isfield(xdfstream.info.desc, 'channels')
    hdr.nChans    = numel(xdfstream.info.desc.channels.channel);
else
    hdr.nChans    = str2double(xdfstream.info.channel_count);
end

hdr.label       = cell(hdr.nChans, 1);
hdr.chantype    = cell(hdr.nChans, 1);
hdr.chanunit    = cell(hdr.nChans, 1);

prefix = xdfstream.info.name;
for j=1:hdr.nChans
    if isfield(xdfstream.info.desc, 'channels')
        hdr.label{j} = [prefix '_' xdfstream.info.desc.channels.channel{j}.label];
        
        try
            hdr.chantype{j} = xdfstream.info.desc.channels.channel{j}.type;
        catch
            disp([hdr.label{j} ' missing type'])
        end
        
        try
            hdr.chanunit{j} = xdfstream.info.desc.channels.channel{j}.unit;
        catch
            disp([hdr.label{j} ' missing unit'])
        end
    else
        % the stream does not contain continuously sampled data
        hdr.label{j} = num2str(j);
        hdr.chantype{j} = 'unknown';
        hdr.chanunit{j} = 'unknown';
    end
end

% keep the original header details
hdr.orig = xdfstream.info;

ftdata.trial    = {xdfstream.time_series};
ftdata.time     = {xdfstream.time_stamps};
ftdata.hdr = hdr;
ftdata.label = hdr.label;

end