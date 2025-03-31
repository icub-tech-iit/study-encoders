classdef AksimEncoder < Encoder
    properties
        DiagnosticData
        Percentages
        Rescaler = 1;  % Adjust as needed
    end
    
    methods
        function obj = AksimEncoder()
            obj@Encoder(); % Call parent class constructor
        end
        
        function obj = ProcessAksimDiagnostic(obj, diagnostic_data, number_of_samples)
            % Processes the Aksim diagnostic data
            diagnostic_results = obj.computeDiagnosticError(diagnostic_data, number_of_samples);
            obj.DiagnosticData = diagnostic_results;
            
            % Compute error percentages
            obj.Percentages = obj.ComputePercentages(number_of_samples);
            
            % Display the results
            obj.DisplayPercentages();
        end
        
function diagnostic_results = computeDiagnosticError(obj, diagnostic_data, number_of_samples)
    % Initialize diagnostic results struct
    diagnostic_results = obj.initDiagnosticStruct(number_of_samples);

    % Process diagnostic data
    for d = 1:number_of_samples
        error_code = bitand(diagnostic_data, double(0xFFFF));

        switch error_code
            case 0x01
                diagnostic_results.crc(d) = obj.Rescaler;
                diagnostic_results.crcCount = diagnostic_results.crcCount + 1;
            case 0x02
                diagnostic_results.c2l(d) = obj.Rescaler;
                diagnostic_results.c2lCount = diagnostic_results.c2lCount + 1;
            case 0x03
                diagnostic_results.C2L_CRC(d) = obj.Rescaler;
                diagnostic_results.C2L_CRCCount = diagnostic_results.C2L_CRCCount + 1;
                diagnostic_results.crcCount = diagnostic_results.crcCount + 1;
            case 0x04
                diagnostic_results.invalidData(d) = obj.Rescaler;
                diagnostic_results.invalidDataCount = diagnostic_results.invalidDataCount + 1;
            case 0x05
                diagnostic_results.CRC_invalidData(d) = obj.Rescaler;
                diagnostic_results.CRC_invalidDataCount = diagnostic_results.CRC_invalidDataCount + 1;
                diagnostic_results.crcCount = diagnostic_results.crcCount + 1;
            case 0x06
                diagnostic_results.C2L_invalidData(d) = obj.Rescaler;
                diagnostic_results.C2L_invalidDataCount = diagnostic_results.C2L_invalidDataCount + 1;
            case 0x07
                diagnostic_results.CRC_InvData_C2L(d) = obj.Rescaler;
                diagnostic_results.CRC_InvData_C2LCount = diagnostic_results.CRC_InvData_C2LCount + 1;
                diagnostic_results.crcCount = diagnostic_results.crcCount + 1;
        end
    end
end

        
        function diagnostic_results = initDiagnosticStruct(obj, number_of_samples)
            % Initialize diagnostic results struct
            diagnostic_results.crc = zeros(1, number_of_samples);
            diagnostic_results.c2l = zeros(1, number_of_samples);
            diagnostic_results.C2L_CRC = zeros(1, number_of_samples);
            diagnostic_results.invalidData = zeros(1, number_of_samples);
            diagnostic_results.CRC_invalidData = zeros(1, number_of_samples);
            diagnostic_results.C2L_invalidData = zeros(1, number_of_samples);
            diagnostic_results.CRC_InvData_C2L = zeros(1, number_of_samples);
            
            diagnostic_results.crcCount = 0;
            diagnostic_results.c2lCount = 0;
            diagnostic_results.C2L_CRCCount = 0;
            diagnostic_results.invalidDataCount = 0;
            diagnostic_results.CRC_invalidDataCount = 0;
            diagnostic_results.C2L_invalidDataCount = 0;
            diagnostic_results.CRC_InvData_C2LCount = 0;
        end
        
        function percentages = ComputePercentages(obj, number_of_samples)
            % Compute error percentages
            percentages.crc = (obj.DiagnosticData.crcCount / number_of_samples) * 100;
            percentages.c2l = (obj.DiagnosticData.c2lCount / number_of_samples) * 100;
            percentages.C2L_CRC = (obj.DiagnosticData.C2L_CRCCount / number_of_samples) * 100;
            percentages.invalidData = (obj.DiagnosticData.invalidDataCount / number_of_samples) * 100;
            percentages.CRC_invalidData = (obj.DiagnosticData.CRC_invalidDataCount / number_of_samples) * 100;
            percentages.C2L_invalidData = (obj.DiagnosticData.C2L_invalidDataCount / number_of_samples) * 100;
            percentages.CRC_InvData_C2L = (obj.DiagnosticData.CRC_InvData_C2LCount / number_of_samples) * 100;
        end
        
        function DisplayPercentages(obj)
            % Displays error percentages in a Markdown-style table
            fprintf('| Error Type               | Percentage |\n');
            fprintf('|--------------------------|------------|\n');
            fprintf('| Failed CRC               | %.4f%%     |\n', obj.Percentages.crc);
            fprintf('| C2L warning              | %.4f%%     |\n', obj.Percentages.c2l);
            fprintf('| CRC + C2L                | %.4f%%     |\n', obj.Percentages.C2L_CRC);
            fprintf('| Invalid data error       | %.4f%%     |\n', obj.Percentages.invalidData);
            fprintf('| CRC + Invalid Data       | %.4f%%     |\n', obj.Percentages.CRC_invalidData);
            fprintf('| C2L + Invalid Data       | %.4f%%     |\n', obj.Percentages.C2L_invalidData);
            fprintf('| CRC + C2L + Invalid Data | %.4f%%     |\n', obj.Percentages.CRC_InvData_C2L);
        end
    end
end
