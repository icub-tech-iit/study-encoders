function s = SetEncoderResolution(varargin)

    expected_encoder_names = {'aksim', 'amo', 'mrie'};
    
    % The arguments number must be even ([encoder_name, associated resolution])
    if mod(length(varargin), 2) ~= 0
        error('Arguments must be provided as pairs of encoder names and resolutions.');
    end

    for i = 1:2:length(varargin)
        encoder_name = varargin{i};
        resolution = varargin{i+1};
        CheckIfEncoderNameValid(encoder_name, expected_encoder_names)
        CheckIfResolutionScalar(resolution)
        s.(encoder_name) = resolution;
    end
end

function CheckIfEncoderNameValid(encoder_name, expected_encoder_names)
    % Check if the encoder name exists
    if ~any(strcmp(encoder_name, expected_encoder_names))
        error('Invalid encoder name: %s. Expected one of: %s.', ...
            encoder_name, strjoin(expected_encoder_names, ', '));
    end
end

function CheckIfResolutionScalar(resolution)
    % Check if resolution is a scalar
    if ~isnumeric(resolution) || ~isscalar(resolution)
        error('Resolution for encoder "%s" must be a numeric scalar.', encoder_name);
    end
end
