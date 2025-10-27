% inspect xdf script from presentation 
% author : Sein Jeung 
%          seinjeung@gmail.com
%--------------------------------------------------------------------------

filename        = 'P:\Sein_Jeung\Project_ManySteps\test_PC.xdf'; 
streams         = load_xdf(filename); 
events          = streams{1}.time_series; 

% create vectors to store the latencies for each response type 
hitResponse     = [];        
missResponse    = []; 
falseAlarm      = [];
correctRej      = []; 


%--------------------------------------------------------------------------
% Preallocate
nE = numel(events);
etype  = cell(nE,1);
ecode  = cell(nE,1);
unc    = nan(nE,1);

% Loop over events and extract with regex
for i = 1:nE
    str = events{i};
    
    % Extract <etype>...</etype>
    t = regexp(str,'<etype>(.*?)</etype>','tokens','once');
    if ~isempty(t), etype{i} = t{1}; end
    
    % Extract <ecode>...</ecode>
    c = regexp(str,'<ecode>(.*?)</ecode>','tokens','once');
    if ~isempty(c), ecode{i} = c{1}; end
    
    % Extract <unc>...</unc> and convert to number
    u = regexp(str,'<unc>(.*?)</unc>','tokens','once');
    if ~isempty(u)
        uncVal = str2double(u{1});
        if ~isnan(uncVal)
            unc(i) = uncVal;
        end
    end
end

% Put into a table for convenience
eTable = table(etype,ecode,unc); 

% iterate over all events
for Ei = 1:nE
    
    if strcmp(eTable.ecode{Ei},'sta')
        
        if strcmp(eTable.ecode{Ei + 1},'11')
            falseAlarm(end+1) = streams{1}.time_stamps(Ei + 1) - streams{1}.time_stamps(Ei);
        else
            correctRej(end+1) = 0; 
        end
        
    elseif strcmp(eTable.ecode{Ei},'tar')
        
        if strcmp(eTable.ecode{Ei + 1},'11')
            hitResponse(end+1) = streams{1}.time_stamps(Ei + 1) - streams{1}.time_stamps(Ei);
        else
            missResponse(end+1) = 0; 
        end
        
    end
    
end







