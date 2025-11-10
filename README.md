# EEGManySteps-Data-Curation
Data curation repository for EEGManySteps
--------------------------------------------------------------------------------------
This repository contains helpful resources for curating data sets collected for EEGManySteps. 

It will contain the following : 
1. Guideline to curating your data for submitting to EEGManySteps
2. Metadata from individual contributions, including link to the data repository as needed.
3. Scripts for converting individual submissions to a standardized format (BIDS + custom metadata)
4. Template and utility scripts for checking metadata integrity and conversion	


Overview of submitted data sets

| Dataset ID |  Contributor |Source EEG Format | Source Motion Format |Link to data set|Status|
|-------------|-------------|-------------|----------------|----------------|--------------|
| `ds_A1_TB` | `Tjeerd Boonstra` |`.` | `.` |`available upon request`|`curation in progress`|
| `ds_B1_LSIE` |  `Grant Hanada/Daniel Ferris` |`.set` | `.mat` |[figshare](https://figshare.com/articles/dataset/LSIE_individual_subjects_full_set/6741734/2)|`curation in progress`|
| `ds_B2_UK` | `Sodiq Fakorede/Hannes Devos` |`.` | `.` |`in preparation`|`curation in progress`|
| `ds_B3_HIP` | `Anna Wunderlich/Klaus Gramann` |`.` | `.` |`in preparation`|`curation in progress`|

Metadata guideline for contributors (WIP...)
--------------------------------------------------------------------------------------
Contributors are recommended to follow the terminology prescribed by [Motion-BIDS](https://bids-specification.readthedocs.io/en/stable/modality-specific-files/motion.html). Especially, the metadata for each channel should contain information specified for the ‘_channels.tsv’ file. We provide template ManySteps metadata files and a validator script to help you check the integrity of your data set for joint analysis of EEG and gait. 

Following are the steps on how to check for metadata for your data set:

### Device
If a system records motion from various parts on the body but is processed with the same device (e.g. Vicon), this device meta data is to be entered in the *_motion.json file.

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

### Pre-extracted gait data 
If the system you recorded data with do not provide raw time series data, gait events can be optionally shared in ‘*_events.tsv’ file accompanying EEG or motion data. These keywords are entered into column ‘’. 

| Keyword |  Description |
|-------------|--------------------|
| `Head` | 50,50,100 |
| `LowerBack` | 50,50,100 |
| `LeftFoot` | 50,70,30 |
| `RightFoot` | 50,70,30 |

### Reference frame and spatial axis definition 
Local or global reference frame 

### Time synchronisation between motion.tsv and EEG

Please use ‘acq’ column in the ‘*_scans.tsv’ file for aligning the onsets of different data streams. 
In case the sampling rate is irregular, please also provide information about sample-by-sample latency as data channel concatenated with the motion data. This channel should have type ‘latency’, expressed as seconds from the onset of the corresponding motion.tsv file. 
In case you use TTL-based synchronisation, 
