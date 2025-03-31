classdef Encoder < handle
    
    properties (Access = public)
        Resolution % Encoder resolution (counts per revolution)
    end
    
    methods
        function set.Resolution(obj, resolution)
            % Sets the encoder resolution.
            obj.Resolution = resolution;
        end
        
        function resolution = get.Resolution(obj)
            % Retrieves the encoder resolution.
            if isempty(obj.Resolution)
                disp('--------------------------------------------------------------------')
                warning('Encoder: no resolution set. This will output "empty" value.');
                disp('--------------------------------------------------------------------')
                resolution = []; % Return empty if no resolution is set
            else
                resolution = obj.Resolution;
            end
        end
    end
end