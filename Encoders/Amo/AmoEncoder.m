classdef AmoEncoder < Encoder
    %   This class provides methods for computing and displaying AMO diagnostic errors.

    properties (Access = public)
        Diagnostic
        JointNumber
    end %end of properties

    methods
        function obj = AmoEncoder()
            obj@Encoder();
            obj.Diagnostic = struct();
            % no need to initialize JointNumber
        end
        function set.JointNumber(obj, joint_number)
            % Specify the order of the encoders
            obj.JointNumber = joint_number;
        end

        function joint_number = get.JointNumber(obj)
            % Retrieves the encoder resolution.
            if isempty(obj.JointNumber)
                disp('--------------------------------------------------------------------')
                error('Encoder: AMO. Unspecified Joint Number. Please assign one.');
            else
                joint_number = obj.JointNumber;
            end
        end

        function computeDiagnosticError(obj, experiment)
            % Retrieve AMO diagnostic data
            diagnostic_data = experiment.GetDiagnosticData();
            num_samples = length(diagnostic_data(obj.JointNumber, :));
            
            % Initialize struct to count errors
            counts = struct( ...
                'total_samples', num_samples, ...
                'status0', 0, ...
                'status1', 0, ...
                'not_connected', 0, ...
                'total_errors', 0 ...
            );
            % Iterate over diagnostic samples
            for d = 1:num_samples
                diagn_type = bitshift(diagnostic_data(obj.JointNumber, d), -16); % Right shift by 16 bits

                switch diagn_type
                    case 0x02 % Status 0 error
                        counts.status0 = counts.status0 + 1;
                        counts.total_errors = counts.total_errors + 1;
                    case 0x03 % Status 1 error
                        counts.status1 = counts.status1 + 1;
                        counts.total_errors = counts.total_errors + 1;
                    case 0x04 % Not connected error
                        counts.not_connected = counts.not_connected + 1;
                        counts.total_errors = counts.total_errors + 1;
                end
            end
            % Compute percentages
            obj.Diagnostic.counts = counts;
            obj.Diagnostic.percentages = obj.computePercentages(counts);
        end

        function diagnostic = getDiagnostic(obj)
            % Returns diagnostic data
            diagnostic = obj.Diagnostic;
        end

        function percentages = computePercentages(~, counts)
            % ComputePercentages - Computes error percentages

            percentages.status0 = (counts.status0 / counts.total_samples) * 100;
            percentages.status1 = (counts.status1 / counts.total_samples) * 100;
            percentages.not_connected = (counts.not_connected / counts.total_samples) * 100;
            percentages.total = (counts.total_errors / counts.total_samples) * 100;
        end

        function displayReport(obj)
            % DisplayPercentages - Displays computed percentages in markdown table format

            if ~isempty(obj.Diagnostic) && isfield(obj.Diagnostic, 'percentages')
                status0_err = obj.Diagnostic.percentages.status0;
                status1_err = obj.Diagnostic.percentages.status1;
                not_conn_err = obj.Diagnostic.percentages.not_connected;
                total_err = obj.Diagnostic.percentages.total;
                fprintf("\n### AMO Encoder Diagnostic Report\n");
                fprintf("| Error Type (AMO)       | Percentage |\n");
                fprintf("|------------------------|------------|\n");
                fprintf("| Status 0               | %.4f%%     |\n", status0_err);
                fprintf("| Status 1               | %.4f%%     |\n", status1_err);
                fprintf("| Not connected          | %.4f%%     |\n", not_conn_err);
                fprintf("| Total error            | %.4f%%     |\n", total_err);
            else
                disp('No diagnostic data available to display.');
            end
        end
    end
end