% configure paths and tools
rootDir         = 'P:\Sein_Jeung\Project_ManySteps\Datasets\SJBP';
sourceFolder    = fullfile(rootDir, 'source-data');
bidsFolder      = fullfile(rootDir, 'BIDS-data');
eeglabPath      = 'P:\Sein_Jeung\Tools\eeglab2025.1.0'; 
fieldTripPath   = 'P:\Sein_Jeung\Tools\fieldtrip-20250501'; 


% configure/initialize eeglab and fieldtrip  
rmpath(fileparts(which('eeglab')))
addpath(eeglabPath); eeglab
addpath(fieldTripPath); ft_defaults


% participant IDs
IDs = {'001', '002'};

% default time (eeg onset in scans.tsv)
defaultTime = [1800,12,31,5,5,5.000]; 

% sessions
sessions = {'baselinestanding', 'baselinewalking', 'walking', 'standing'};
bidssession = {'BaseStand', 'BaseWalk', 'OddballWalk', 'OddballStand'};

for IDi = 1:numel(IDs)
    
    ID = IDs{IDi};
    
    for Si = 1:numel(sessions)
        
        if Si == 1 || Si == 2
            runs = 1; % for baseline sessions only 1 run
        else
            runs = [1,2,3,4]; % for oddball task up to 4 runs
        end
        
        for Ri = runs
            
            if Si == 1 || Si == 2
                blockName = sessions{Si};
            else
                blockName = ['block', num2str(Ri), sessions{Si}];
            end

            try
                % 1. load and inspect EEG files
                %----------------------------------------------------------
                streams     = load_xdf(fullfile(sourceFolder, ['pilot-' ID '\PILOT' ID '_' blockName '.xdf']));
            catch
                disp(['pilot-' ID '\PILOT' ID '_' blockName '.xdf file does not exist'])
                continue;
            end
            
            ESi = 0; CSi = 0; MSi = 0; NSi = 0; 
            for STi = 1:numel(streams)
                if strcmp(streams{STi}.info.name, 'BrainVision RDA')
                    ESi = STi; % found EEG stream index
                elseif strcmp(streams{STi}.info.name, 'CometaWaveX')
                    CSi = STi; % found Cometa stream index
                elseif strcmp(streams{STi}.info.name, 'Presentation')
                    MSi = STi; % found Marker stream index
                elseif strcmp(streams{STi}.info.name, 'BPN-Neon2_Neon Gaze')
                    NSi = STi; % found NEON stream index
                end
            end
            
            % 2. convert data to fiedtrip structs
            %--------------------------------------------------------------
            eeg             = stream2ft(streams{ESi});
            motion          = stream2ft(streams{CSi});
            if NSi ~= 0
                eye             = stream2ft(streams{NSi});
            end
            
            % 3. enter generic metadata
            %--------------------------------------------------------------
            cfg                                         = [];
            cfg.README                                  = 'This experiment is still pilotted - motion data to be added';
            cfg.bidsroot                                = bidsFolder;
            cfg.sub                                     = ID;
            cfg.task                                    = 'Oddball';
            cfg.ses                                     = bidssession{Si};

            if Si >= 3 % only add run entity if there are multiple runs 
                cfg.run                                     = num2str(runs(Ri));
            end
            
            cfg.dataset_description.Name                = 'SJBP';
            cfg.dataset_description.BIDSVersion         = '1.10.1';
            cfg.InstitutionName                         = 'Technical University of Berlin';
            cfg.InstitutionalDepartmentName             = 'Biopsychology and Neuroergonomics';
            cfg.InstitutionAddress                      = 'n/a';
            cfg.TaskDescription                         = 'oddball task with button response';
            cfg.dataset_description.License             = 'CC BY 4.0';
            cfg.dataset_description.Authors             = {'Sein Jeung'};
            cfg.dataset_description.Acknowledgements    = 'special thanks to student participating in WiSe 2526 TUB seminar psychophysiology';
            cfg.dataset_description.Funding             = 'n/a';
            cfg.dataset_description.ReferencesAndLinks  = 'n/a';
            cfg.dataset_description.DatasetDOI          = 'n/a';
            
            % read in the event stream (synched to the EEG stream)
            if MSi ~=0
                xdfmarkers = streams(MSi);
                if any(cellfun(@(x) ~isempty(x.time_series), xdfmarkers))
                    events               = stream2events(xdfmarkers, streams{ESi}.time_stamps);
                    [events, eventsJSON] = parsemarkers(events);
                    cfg.events = events;
                end
            end
            
            %--------------------------------------------------------------
            % 5. enter eeg metadata and feed to data2bids function
            %--------------------------------------------------------------
            cfg.datatype                        = 'eeg';
            cfg.eeg.Manufacturer                = 'BrainProducts';
            cfg.eeg.ManufacturersModelName      = 'LiveAmp';
            cfg.eeg.PowerLineFrequency          = 50;
            cfg.eeg.EEGReference                = 'REF';
            cfg.eeg.SoftwareFilters             = 'n/a';
            cfg.scans.acq_time                  = datenum(defaultTime);
            cfg.scans.acq_time                  = datestr(cfg.scans.acq_time,'yyyy-mm-ddTHH:MM:SS.FFF'); % milisecond precision
            data2bids(cfg, eeg);
            
            %-------------------------------------------------------------- 
            % 6. enter motion metadata and feed to data2bids function
            %--------------------------------------------------------------
            cfg.datatype                            = 'motion';
            cfg                                     = rmfield(cfg, 'eeg');
            if isfield(cfg, 'events')
                cfg                                     = rmfield(cfg, 'events');
            end
            cfg.tracksys                            = 'COMETAIMU';
            cfg.motion.TrackingSystemName           = 'COMETA'; % found in xml.recordingParameterSets.recordingParameterSet(7).channelType.modality.description
            cfg.motion.DeviceSerialNumber           = 'n/a';
            cfg.motion.SoftwareVersions             = 'n/a';
            cfg.motion.Manufacturer                 = 'COMETA';
            cfg.motion.ManufacturersModelName       = 'WaveX';
            cfg.motion.ManySteps_SpaceType          = 'Indoor';
            cfg.motion.ManySteps_SurfaceType        = 'Overground';
            cfg.motion.ManySteps_Footware           = 'on';
            
            % Initialize containers
            all_names = {};
            all_component = {};
            all_type = {};
            all_units = {};
            all_tracked_point = {};
            
            % Define per-sensor templates (constant across Pi)
            trackedPoints = {'FootL', 'FootR', 'KneeL', 'KneeR', 'LowerBack'};
            components = {'x','y','z'};
            types = {'ACCEL','GYRO','MAGN'};
            units = {'m/s^2','rad/s','uT'};
            
            % Loop through tracked points
            for Ti = 1:numel(trackedPoints)
                tracked           = trackedPoints{Ti};
                chanName          = repmat({tracked}, 1, 9);
                
                % add empty EMG metadata 
                all_component     = [all_component,     'n/a'];
                all_type          = [all_type,          'EMG'];
                all_units         = [all_units,         'n/a'];
                all_tracked_point = [all_tracked_point,  tracked];
                
                % add imu metadata
                all_component     = [all_component,     repmat(components,1,3)];
                all_type          = [all_type,          repelem(types,1,3)];
                all_units         = [all_units,         repelem(units,1,3)];
                all_tracked_point = [all_tracked_point, repmat({tracked}, 1,9)];
            end
            
            % construct channel labels
            for CHi = 1:numel(all_component)
                all_names{end+1} = strjoin({all_tracked_point{CHi}, all_type{CHi}, all_component{CHi}}, '_');
            end
            
            % add latency channel
            all_names{end+1} = 'Latency';
            all_component{end+1} = 'n/a';
            all_type{end+1} = 'LATENCY';
            all_units{end+1} = 's';
            all_tracked_point{end+1} = 'n/a';
            
            % Collapse into a single FieldTrip-compatible struct
            cfg.channels = struct( ...
                'name',          {all_names}, ...
                'component',     {all_component}, ...
                'type',          {all_type}, ...
                'units',         {all_units}, ...
                'tracked_point', {all_tracked_point} );
            
            % rename the channels in the data to match with channels.tsv
            motion.label = cfg.channels.name;
            
            % time synch information in scans.tsv file
            motionStartTime                 = motion.time{1}(1);
            motionTimeShift                 = motionStartTime - eeg.time{1}(1);
            acq_time = datenum(defaultTime) + (motionTimeShift/(24*60*60));
            cfg.scans.acq_time = datestr(acq_time,'yyyy-mm-ddTHH:MM:SS.FFF'); % milisecond precision
            data2bids(cfg, motion);
            
%             %--------------------------------------------------------------
%             % 7. enter eye metadata and feed to data2bids function
%             %--------------------------------------------------------------
%             if NSi ~=0
%                 cfg.datatype                     = 'physio';
%                 cfg                              = rmfield(cfg, 'motion');
%                 
%                 % default values for physio specific fields in json
%                 cfg.physio.Manufacturer                     = 'PupilLabs';
%                 cfg.physio.ManufacturersModelName           = 'Neon';
%                 efg.physio.RecordingType                    = 'continuous';
%                 
%                 % shift acq_time to store relative offset to eeg data
%                 eyeStartTime                     = eye.time{1}(1);
%                 eyeTimeShift                     = eyeStartTime - eeg.time{1}(1);
%                 acq_time = datenum(defaultTime) + (eyeTimeShift/(24*60*60));
%                 cfg.scans.acq_time = datestr(acq_time,'yyyy-mm-ddTHH:MM:SS.FFF'); % milisecond precision
%                 data2bids(cfg, eye);
%             end
        end
       
    end
end

