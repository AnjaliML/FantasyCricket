function data = importingMatchData( filename )
[~, ~, raw] = xlsread(filename,'Sheet1');
raw = raw(2:end,:);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};

% Exclude rows with non-numeric cells
I = ~all(cellfun(@(x) (isnumeric(x) || islogical(x)) && ~isnan(x),raw),2); % Find rows with non-numeric cells
raw(I,:) = [];

% Create output variable
data = reshape([raw{:}],size(raw));
end

