classdef Encoder
    properties
        Resolution % Encoder resolution (counts per revolution or equivalent unit)
    end
    
    methods
        function obj = setEncoderResolution(obj, resolution)
            % Set the resolution of the encoder
            obj.Resolution = resolution;
        end
        
        function resolution = getEncoderResolution(obj)
            % Get the resolution of the encoder
            resolution = obj.Resolution;
        end
    end
end
