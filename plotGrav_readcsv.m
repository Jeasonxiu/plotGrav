function [time,data,header] = plotGrav_readcsv(input_file,head,delim,date_column,date_format,data_column)
%PLOTGRAV_READCSV read csv file
%
% Input:
%   input_file  ...     input file name, i.e., full file name (string)
%   head        ...     number of header lines (double)
%   delim       ...     csv delimiter (string or cell)
%   date_column ...     date column (double)
%   date_format ...     date string
%                       Example: '"yyyy-dd-mm HH:MM:SS"'
%                                'yyyy/mm/dd HH:MM:SS'
%   data_column ...     data column
%                       Example: 5 = load fifth column (in csv)
%                                2:10 = load all columns between 2 and 10
%                                (including 2 and 10)
%                                'All' = all data columns except time
% 
% Output:
%   time        ...     time vector (in matlab datenum format)
%   data        ...     selected data columns
%   header      ...     header info
% 
% Example:
%   input_file = 'Wettzell_Hang_Mux21.dat';
%   head = 3;
%   delim = {','};
%   date_column = 1;
%   date_format = '"yyyy-mm-dd HH:MM:SS"';
%   data_column = 'All';
% [time,data,header] =  plotGrav_readcsv(input_file,head,delim,date_column,date_format,data_column);
% 
%                                                   M.Mikolaj, 20.05.2015


%% Get header
fid = fopen(input_file,'r');                                                % open file
if head > 0                                                                 % read header only if 'head' variable > 0
    row = fgetl(fid);                                                       % read line
    header = strsplit(row,delim);                                           % split header using given delimiter(s)
    if head > 1                                                             % continue reading header if required
        for i = 1:head-1
            row = fgetl(fid);
            temp = strsplit(row,delim);
            header(i+1,1:length(temp)) = temp;
        end
    end
    clear temp
else
    row = 'No header';                                                      % if no header data
    header = [];
end

%% Get data: faster reading
row = fgetl(fid);								% read only to get the number of columns. See below.
number_of_column = length(strsplit(row,delim)); % get the number of columns for further data reading using textscan
fclose(fid); % close the file to open it again for reading from beginning. The fgetl read already a row => not to loose it.
fid = fopen(input_file);
% Read/Remove the header
if head > 0
    for i = 1:head
       fgetl(fid); 
    end
end
% Create format for reading
format_spec = [];
for i = 1:number_of_column
    if i == date_column % read data as string. The datenum function and 'date_format' will be used to transform it to matlab format
        format_spec = [format_spec,'%s'];
    else
        format_spec = [format_spec,'%f']; % all other columns are expected to be a floating-point number
    end
    if i~=number_of_column % add space only up to second last column. This is independent of delimiter! See 'data_all' variable.
        format_spec = [format_spec,' '];
    end
end
data_all = textscan(fid,format_spec,'Delimiter',char(delim),'TreatAsEmpty',{'"NAN"','"INF"','"-INF"','NotYetSet','nan'}); % read the whole file at once
time = datenum(data_all{date_column},date_format);                          % convert time string to matlab format
if ischar(data_column)                                                      % is char = 'All columns'
    data = cell2mat(data_all(2:end));
else                                                                        % otherwise output only selected column
    data = cell2mat(data_all(data_column));
end

fclose(fid);                                                                % close file


end
