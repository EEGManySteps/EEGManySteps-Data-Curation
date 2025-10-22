% configure paths and tools
dataFolder      = 'P:\Sein_Jeung\Project_ManySteps\Datasets\LSIE';
fieldTripPath   = 'P:\Sein_Jeung\Project_BIDS\Workshops\Workshop_2024_NEC\public\Tools\fieldtrip-20240515'; 
bidsFolder      = fullfile(dataFolder, 'BIDS-data');
addpath(fieldTripPath); ft_defaults % add eeglab too if not already on path

% 1. load and inspect EEG files
% consists of 264 channels EEG data, sampling rate 512 Hz
%--------------------------------------------------------------------------
eeg     = pop_loadset(fullfile(dataFolder, 'LSIE_04\LSIE_04_Indoor.set')); 
eeg.etc.dateTime % presumably the onset of the recording

% 2. load and inspect imu files 
% consists of 10 channels IMU data placed on four body parts
% sampling rate approx. 128 Hz 
%--------------------------------------------------------------------------
imu     = load(fullfile(dataFolder, 'LSIE_04\LSIE_04_Indoor_imu.mat'));
imu.IMU.axisValue{1}'   % display channel types
imu.IMU.axisValue{3}'   % display tracked body parts
imu.IMU.samplingRate    % display sampling rate 
imu.IMU.dateTime        % presumably the onset of the recording 

% 3. load and insepct other relevant metadata files  
% best read as a struct, contains information similar to dataset
% description json in BIDS 
%--------------------------------------------------------------------------
xml = readstruct(fullfile(dataFolder, 'UM_LSIE.xml')); 


% 4. convert data to fiedtrip structs 
%--------------------------------------------------------------------------
%EEGftData           = stream_to_ft(streams{EEGStreamInd}); 
%MotionftData        = stream_to_ft(streams{MotionStreamInd}); 

% 4. enter generic metadata
%--------------------------------------------------------------------------
cfg                                         = [];
cfg.bidsroot                                = bidsFolder;
cfg.sub                                     = '004';
cfg.task                                    = 'LSIE';
cfg.dataset_description.Name                = xml.title;
cfg.dataset_description.BIDSVersion         = '1.10.1';
cfg.InstitutionName                         = 'University of Michigan';
cfg.InstitutionalDepartmentName             = xml.organization.name;
cfg.InstitutionAddress                      = 'n/a';
cfg.TaskDescription                         = xml.description;

% optional for dataset_description.json
cfg.dataset_description.License             = 'CC BY 4.0';
expArray                                    = xml.experimenters(1).experimenter;
names                                       = arrayfun(@(x) x.name, expArray, 'UniformOutput', false);
cfg.dataset_description.Authors             = names;
cfg.dataset_description.Acknowledgements    = 'n/a';
cfg.dataset_description.Funding             = [xml.project.funding.organization, xml.project.funding.grantId];
cfg.dataset_description.ReferencesAndLinks  = 'n/a';
cfg.dataset_description.DatasetDOI          = 'n/a';

% 5. enter eeg metadata and feed to data2bids function
%--------------------------------------------------------------------------
cfg.datatype = 'eeg';
cfg.eeg.Manufacturer                = 'BioSemi';
cfg.eeg.ManufacturersModelName      = 'n/a';
cfg.eeg.PowerLineFrequency          = 60; 
cfg.eeg.EEGReference                = 'n/a'; 
cfg.eeg.SoftwareFilters             = 'n/a'; 

% time synch information in scans.tsv file
cfg.scans.acq_time  = eegAcqTime; 

data2bids(cfg, EEGftData);

% 6. enter motion metadata and feed to dat2bids functino
%--------------------------------------------------------------------------
cfg.datatype    = 'motion'; 
cfg             = rmfield(cfg, 'eeg'); 
cfg.tracksys    = 'IMU';

cfg.motion.TrackingSystemName          = 'IMU';
cfg.motion.DeviceSerialNumber          = 'n/a';
cfg.motion.SoftwareVersions            = 'n/a';
cfg.motion.Manufacturer                = 'n/a';
cfg.motion.ManufacturersModelName      = 'n/a';

% specify channel details, this overrides the details in the original data structure
cfg.channels = [];
cfg.channels.name = {
  'HTCVive_posX'
  'HTCVive_posY'
  'HTCVive_posZ'
  'HTCVive_quatX' 
  'HTCVive_quatY'
  'HTCVive_quatZ'
  'HTCVive_quatW'
  'HTCVive_ori'
  };
cfg.channels.component= {
  'x'
  'y'
  'z'
  'quat_x'
  'quat_y'
  'quat_z'
  'quat_w'
  'n/a'
  };
cfg.channels.type = {
  'POS'
  'POS'
  'POS'
  'ORI'
  'ORI'
  'ORI'
  'ORI'
  'MISC'
  };
cfg.channels.units = {
  'm'
  'm'
  'm'
  'n/a'
  'n/a'
  'n/a'
  'n/a'
  'n/a'
  };

cfg.channels.tracked_point = {
  'head'
  'head'
  'head'
  'head'
  'head'
  'head'
  'head'
  'head'
  };

% rename the channels in the data to match with channels.tsv
MotionftData.label = cfg.channels.name;

% time synch information in scans.tsv file
cfg.scans.acq_time  = motionAcqTime; 

data2bids(cfg, MotionftData);
