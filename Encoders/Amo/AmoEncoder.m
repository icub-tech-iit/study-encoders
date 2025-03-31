classdef AmoEncoder < Encoder
    methods
        function obj = AmoEncoder(resolution)
            % Constructor for AmoEncoder, optionally sets resolution
            if nargin > 0
                obj = obj.setEncoderResolution(resolution);
            end
        end
    end
end
