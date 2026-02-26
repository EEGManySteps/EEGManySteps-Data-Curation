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

% sessions
sessions = {'base_stand', 'oddball_stand', 'oddball_walk'};
bidssession = {'stand', 'oddballstand', 'oddballwalk'}; 

for IDi = 1:numel(IDs)
    
    ID = IDs{IDi};
    
    for Si = 1:numel(sessions)
    
        session = sessions{Si};
        
        % 1. load and inspect EEG files
        % consists of 32 channels EEG data, sampling rate 500 Hz
        %------------------------------------------------------------------
        streams     = load_xdf(fullfile(sourceFolder, ['pilot-' ID '\MSBP_pilot-' ID '_' session '.xdf']));
        
        MSi = 0;
        for STi = 1:numel(streams)
            if strcmp(streams{STi}.info.name, 'BrainVision RDA')
                ESi = STi; % found EEG stream index
            elseif strcmp(streams{STi}.info.name, 'Presentation')
                MSi = STi; % found Marker stream index
            end
        end
        
        % 2. convert data to fiedtrip structs
        %------------------------------------------------------------------
        eeg        = stream2ft(streams{ESi});
        
        % 3. enter generic metadata
        %------------------------------------------------------------------
        cfg                                         = [];
        cfg.README                                  = 'This experiment is still pilotted - motion data to be added';
        cfg.bidsroot                                = bidsFolder;
        cfg.sub                                     = ID;
        cfg.task                                    = 'Oddball';
        cfg.ses                                     = bidssession{Si};
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
        
        % 5. enter eeg metadata and feed to data2bids function
        %------------------------------------------------------------------
        cfg.datatype                        = 'eeg'; 
        cfg.eeg.Manufacturer                = 'BrainProducts';
        cfg.eeg.ManufacturersModelName      = 'LiveAmp';
        cfg.eeg.PowerLineFrequency          = 50; 
        cfg.eeg.EEGReference                = 'REF';
        cfg.eeg.SoftwareFilters             = 'n/a';
        
        data2bids(cfg, eeg);
       
    end
end

