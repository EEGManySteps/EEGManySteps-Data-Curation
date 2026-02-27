# EEGManySteps-Data-Curation
Data curation repository for EEGManySteps
--------------------------------------------------------------------------------------
This repository contains helpful resources for curating data sets collected for EEGManySteps. 

It will contain the following : 
1. Guideline to curating your data for submitting to EEGManySteps
2. Metadata from individual contributions, including link to the data repository as needed.
3. Scripts for converting individual submissions to a standardized format (BIDS + custom metadata)
4. Template and utility scripts for checking metadata integrity and conversion	


## Overview of submitted data sets
Access requests for "available on request" or "controlled access" data sets are to be sent to eegmanysteps@gmail.com    
- Submission track A (ds_A...) : auditory oddball with button press    
- Submission track B (ds_B...) : auditory oddball counting task    
- Submission track C (ds_C...) : walking task     

| Dataset ID |  Contributor |Source EEG Format | Source Motion Format |Link to data set|Status|Notes|
|-------------|-------------|-------------|----------------|----------------|--------------|--------------|
| `ds_A1_TB` | Tjeerd Boonstra |`.` | . |available upon request|curation in progress|treadmill|
| `ds_A2_UK` | Daniel Büchel |`.` | `.` |n/a|data collection in progress|.|
| `ds_A3_SJBP` | Sein Jeung |`.xdf` | `.xdf` |n/a|data collection in progress|overground|
| `ds_B1_MK` | Melanie Klapprott |`.` | `.` |in preparation|curation in progress|.|
| `ds_C1_LSIE` |  Grant Hanada/Daniel Ferris |`.set` | `.mat` |[figshare](https://figshare.com/articles/dataset/LSIE_individual_subjects_full_set/6741734/2)|curation complete|treadmill + overground, curated set available upon request|
| `ds_C2_KUMC` | Sodiq Fakorede/Hannes Devos |`.xdf` | `.xdf` |in preparation|curation in progress|clinical|
| `ds_C3_HIP` | Anna Wunderlich/Klaus Gramann |`xdf.` | `xdf.` |controlled access|curation complete|aging/hearing impaired|
| `ds_C4_TW` | Nadine Jacobsen/Julius Welzel |`.` | `.` |in preparation|curation in progress|'.'|

Metadata guideline for contributors 
--------------------------------------------------------------------------------------
Contributors are recommended to follow the terminology prescribed by the Brain Imaging Data Structure ([BIDS](https://bids.neuroimaging.io/index.html)), especially [EEG-BIDS](https://bids-specification.readthedocs.io/en/stable/modality-specific-files/electroencephalography.html) and [Motion-BIDS](https://bids-specification.readthedocs.io/en/stable/modality-specific-files/motion.html). Importantly, the metadata for each channel should contain information specified for the ‘_channels.tsv’ file. We provide template ManySteps metadata files and a validator script to help you check the integrity of your data set for joint analysis of EEG and gait. 

Following are the steps on how to check for metadata for your data set:

### Gait metadata
If a system records motion from various parts on the body but is processed with the same device (e.g. Vicon), this device meta data is to be entered in the *_motion.json file.
- "ManySteps_SpaceType" : "Indoor", "Outdoor"
- "ManySteps_SurfaceType" : "Treadmill", "Overground"
- "ManySteps_Shoes" : "on", "off"

### Channels
For each device all channels and their metadata should be specified in a separate channels.tsv file. Please check the BIDS specification how to do this.

### Sensor placement
BIDS-Motion currently does not restrict keywords for body parts for sensor placement. These keywords are entered into column ‘placement’ of ‘*_channels.tsv’ file. The coordinates are defined according to the human sensor placement system proposed in this document.

| Name |  Exemplar coordinates (X,Y,Z) |
|-------------|--------------------|
| `Head` | 50,50,100 |
| `LowerBack` | 50,50,100 |
| `LeftFoot` | 50,70,30 |
| `RightFoot` | 50,70,30 |

### Pre-extracted gait events
If the system you recorded data with do not provide raw time series data, gait events can be optionally shared in ‘*_events.tsv’ file accompanying EEG or motion data. 
| Keyword |  Description |
|-------------|--------------------|
| `LHS` | left heel strike |
| `RHS` | right heel strike |

### Time synchronisation between motion.tsv and EEG
The type of time synchronisation method should be indicated in the dataset_description.json file, added as a cutom field as follows : 

"ManySteps_Timesynch" : "regular_sampling", "latency_channel", "TTL"

- regular_sampling : fixed, reliable smapling rate. Latency of each sample can be derived from sample index and SamplingFrequency    
- latency_channel : per-sample lateancy provided as an additional channle in motion data (type = "latency")    
- TTL : Hardware-based TTL trigger synchronization between systems        

Please use ‘acq’ column in the ‘*_scans.tsv’ file for aligning the onsets of different data streams if the recording starts at different times.   
For instance, if the EEG recording started 1.2 sec earlier than the motion recording, this difference is expressed as the difference in the datetime value in "acq" column.    
In case the sampling rate is irregular, please also provide information about sample-by-sample latency as data channel concatenated with the motion data. This channel should have type ‘latency’, expressed as seconds from the onset of the corresponding motion.tsv file.     

