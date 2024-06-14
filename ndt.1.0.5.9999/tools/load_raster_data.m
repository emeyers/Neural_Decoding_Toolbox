function  [raster_labels, raster_site_info, raster_data] = load_raster_data(raster_file)

% This function takes the name of a file in raster-format checks if file is a .mat or .csv, 
%  and loads the data appropriately. The arguments to this function are:
%
%   1. raster_file: the name of the file in raster format
%
%  This function returns the raster_data, raster_labels struct ,
%  raster_site_info struct from loading a raster-format file that is is a 
%  .mat or .csv file
%

%==========================================================================

%     This code is part of the Neural Decoding Toolbox.
%     Copyright (C) 2011 by Ethan Meyers (emeyers@mit.edu)
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
%========================================================================== 
    
  

% Get the file extension
[~,~,file_ext] = fileparts(raster_file);


% Check if the file extension matches '.mat' (MATLAB data file)
if strcmpi(file_ext, '.mat')

    load(raster_file);

elseif strcmpi(file_ext, '.csv')

    raster_data = readcell(raster_file); 
                  
    column_names = raster_data(1,:);       
    raster_labels = struct;       
    raster_site_info = struct;        
    raster_data = raster_data(2:end, :);        
    label_col_indices = find(contains(column_names, 'labels.'));
            
    if isempty(label_col_indices )
         error(['The file', raster_file, 'is not in proper raster format (does not have labels. columns'])
    end
        
    for i = 1:numel(label_col_indices )                    
        curr_label_name = strrep(column_names{label_col_indices(i)}, 'labels.','');
        raster_labels.(curr_label_name) = raster_data(:, label_col_indices(i));                     
    end    
   
    % get the site info
    site_info_col_indices = find(contains(column_names, 'site_info.'));

    if ~isempty(site_info_col_indices)
        for i = 1:numel(site_info_col_indices)              
            curr_site_info_name = strrep(column_names{site_info_col_indices (i)}, 'site_info.','');
            raster_site_info.(curr_site_info_name) = raster_data(:, site_info_col_indices(i));
        end
    end
    

    % if there is a trial_number column, save it in the site_info
    trial_num_ind = find(contains(column_names, 'trial_number'));
    if ~isempty(trial_num_ind)
        raster_site_info.trial_number = raster_data(:, trial_num_ind);
    end


    % reduce raster data to only containing neural activity 
    time_col_inds = find(contains(column_names, 'time.'));
    raster_site_info.time_column_names = column_names(time_col_inds); % save the time column names in the raster_site_info as well
    
    raster_data = raster_data(:, time_col_inds); 
    raster_data = cell2mat(raster_data);
   
else
    error('Raster data files must be .mat or .csv files');
end



