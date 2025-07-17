classdef AksimEncoder < Encoder
    %   This class provides methods for computing and displaying aksim diagnostic errors.
    
    properties (Access = public)
        Diagnostic
        rawDiagnosticData
        timestamps
        crc__
        c2l__
        invalid_data__
    end %end of properties

    methods
        function obj = AksimEncoder()
            % Initializes an "aksim" encoder starting from encoder base class.
            obj@Encoder();
            obj.Diagnostic = struct();
        end 
        
        function computeDiagnosticError(obj, experiment)
            % Extracts diagnostic information from the experiment and classifies errors.

            % Retrieve diagnostic data
            [obj.rawDiagnosticData, numberOfSamples] = experiment.GetDiagnosticData();

            % Initialize struct to count errors
            counts = struct( ...
                'total_samples', numberOfSamples, ...
                'crc', 0, ...
                'c2l', 0, ...
                'invalid_data', 0 ...
            );

            % Iterate over diagnostic samples
            obj.crc__ = zeros(1, numberOfSamples);
            obj.c2l__ = zeros(1, numberOfSamples);
            obj.invalid_data__ = zeros(1, numberOfSamples);

            for d = 1:numberOfSamples
                errorCode = bitand(obj.rawDiagnosticData(1, d), double(0xFFFF));

                switch errorCode
                    case 0x01 % CRC Error
                        counts.crc = counts.crc + 1;
                        obj.crc__(d) = 1;

                    case 0x02 % C2L Error
                        counts.c2l = counts.c2l + 1;
                        obj.c2l__(d) = 1;

                    case 0x03 % C2L + CRC Error
                        counts.crc = counts.crc + 1;
                        obj.crc__(d) = 1;

                    case 0x04 % Invalid Data Error
                        counts.invalid_data = counts.invalid_data + 1;
                        obj.invalid_data__(d) = 1;

                    case 0x05 % CRC + Invalid Data
                        counts.crc = counts.crc + 1;
                        obj.crc__(d) = 1;

                    case 0x06 % C2L + Invalid Data
                        counts.c2l_invalid_data = counts.c2l_invalid_data + 1;

                    case 0x07 % CRC + C2L + Invalid Data
                        counts.crc = counts.crc + 1;
                        obj.crc__(d) = 1;
                end
            end

            % obj.crc__(obj.crc__ == 0) = nan;
            % obj.c2l__(obj.c2l__ == 0) = nan;
            % obj.invalid_data__(obj.invalid_data__ == 0) = nan;
            obj.crc__(obj.crc__ == 0) = -1;
            obj.c2l__(obj.c2l__ == 0) = -1;
            obj.invalid_data__(obj.invalid_data__ == 0) = -1;

            % Compute percentages
            obj.Diagnostic.counts.crc = counts.crc;
            obj.Diagnostic.counts.c2l = counts.c2l;
            obj.Diagnostic.counts.invalid_data = counts.invalid_data;
            obj.Diagnostic.percentages = obj.computePercentages(counts);

        end

        function diagnostic = getDiagnostic(obj)
            % Returns diagnostic data
            diagnostic = obj.Diagnostic;
        end

        function percentages = computePercentages(~, counts)
            % Computes error percentages
            percentages.crc = (counts.crc / counts.total_samples) * 100;
            percentages.c2l = (counts.c2l / counts.total_samples) * 100;
            percentages.invalid_data = (counts.invalid_data / counts.total_samples) * 100;
        end

        function displayReport(obj)
            % Displays computed percentages in markdown table format

            crc = obj.Diagnostic.percentages.crc;
            c2l = obj.Diagnostic.percentages.c2l;
            invalid_data = obj.Diagnostic.percentages.invalid_data;

            total_error = crc + c2l + invalid_data;

            fprintf("\n### Aksim Encoder Diagnostic Report\n");
            fprintf("| Error Type (AKSIM)     | Percentage |\n");
            fprintf("|------------------------|------------|\n");
            fprintf("| Failed CRC             | %.4f%%     |\n", crc);
            fprintf("| C2L warning            | %.4f%%     |\n", c2l);
            fprintf("| Invalid data error     | %.4f%%     |\n", invalid_data);
            fprintf("| Sum of the errors      | %.4f%%     |\n", total_error);

        end

        function plotDiagnosticOnRawData(obj, experiment)
            
            obj.timestamps = experiment.GetTimestamps();
            rawData = experiment.GetRawData();

            plot(obj.timestamps, rawData(1, :))
            hold on
            plot(obj.timestamps, obj.crc__.*rawData(1, :), 'r*')
            plot(obj.timestamps, obj.c2l__.*rawData(1, :), 'g*')
            plot(obj.timestamps, obj.invalid_data__.*rawData(1, :), 'b*')
            hold off
            title('Encoder raw data (Joint position)');
            subtitle(['Joint position, (joint speed: ', 'number', ' $[\frac{deg}{sec}$])'], 'Interpreter', 'latex');
            axis([-inf, inf, 0, 2.01^19]);
            xlabel('Time (seconds)');
            lgd = legend('Joint position', 'CRC error', 'C2L error', 'Invalid Data error');
            lgd.FontSize = 5; lgd.Location = 'north'; lgd.Orientation = 'horizontal';

        end

    end % end of public methods

end %end of class