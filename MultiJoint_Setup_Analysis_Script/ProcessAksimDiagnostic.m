function diagnostic = ProcessAksimDiagnostic(experiment_data)
% This script handles the Aksim diagnostic message
    [diagnostic.data, number_of_samples] = GetDiagnosticData(experiment_data);
    count_struct = InitCountStruct(number_of_samples);
    diagnostic.aksim.diagn_info = InitDiagnosticStruct(number_of_samples);
    for idx = 1:number_of_samples
        [diagnostic, count_struct] = CheckErrors(diagnostic, count_struct, idx);
    end
    diagnostic.aksim.percentages = ComputePercentages(count_struct);
    DisplayPercentages(diagnostic);
end
function [diagnostic, counter] = CheckErrors(diagnostic, counter, idx)
        diagnostic.value = bitand(diagnostic.data(2, idx), double(0xFFFF));
        switch diagnostic.value
            case 0x01 % Checks for CRC
                diagnostic.aksim.diagn_info.crc(idx) = 1;
                counter.crc = counter.crc + 1;
            case 0x02  % Checks C2L
                diagnostic.aksim.diagn_info.c2l(idx) = 1;
                counter.c2l = counter.c2l + 1;
            case 0x03  % Checks for C2L + CRC
                diagnostic.aksim.diagn_info.crc_c2l(idx) = 1;
                counter.crc_c2l = counter.crc_c2l + 1;
                counter.crc = counter.crc + 1;
            case 0x04 % Checks for Invalid Data
                diagnostic.aksim.diagn_info.invalid_data(idx) = 1;
                counter.invalid_data = counter.invalid_data + 1;
            case 0x05 % Checks for CRC + Invalid Data
                diagnostic.aksim.diagn_info.crc_invalid_data(idx) = 1;
                counter.crc_invalid_data = counter.crc_invalid_data + 1;
                counter.crc = counter.crc + 1;
            case 0x06  % Checks for C2L + Invalid Data
                diagnostic.aksim.diagn_info.c2l_invalid_data(idx) = 1;
                counter.c2l_invalid_data = counter.c2l_invalid_data + 1;
            case 0x07 % Checks for CRC + C2L + Invalid Data
                diagnostic.aksim.diagn_info.crc_c2l_invalid_data(idx) = 1;
                counter.crc_c2l_invalid_data = counter.crc_c2l_invalid_data + 1;
                counter.crc = counter.crc + 1;
        end
end
function count_struct = InitCountStruct(number_of_samples)
% Initialize a counter with fields to compute error percentages
    count_struct.crc = 0;
    count_struct.c2l = 0;
    count_struct.invalid_data = 0;
    count_struct.crc_c2l = 0;
    count_struct.crc_invalid_data = 0;
    count_struct.c2l_invalid_data = 0;
    count_struct.crc_c2l_invalid_data = 0;
    count_struct.number_of_samples = number_of_samples;
end
function diagnostic = InitDiagnosticStruct(number_of_samples)
% Initialize variables to store errors
    diagnostic.crc = zeros(number_of_samples, 1);
    diagnostic.c2l = zeros(number_of_samples, 1);
    diagnostic.invalid_data = zeros(number_of_samples, 1);

    diagnostic.crc_invalid_data = zeros(number_of_samples, 1);
    diagnostic.c2l_invalid_data = zeros(number_of_samples, 1);
    diagnostic.crc_c2l = zeros(number_of_samples, 1);
    diagnostic.crc_c2l_invalid_data = zeros(number_of_samples, 1);
end
function percentages = ComputePercentages(count_struct)
    percentages.crc = (count_struct.crc / count_struct.number_of_samples) * 100;
    percentages.c2l = (count_struct.c2l / count_struct.number_of_samples) * 100;
    percentages.invalid_data = (count_struct.invalid_data / count_struct.number_of_samples) * 100;
    percentages.crc_invalid_data =  (count_struct.crc_invalid_data / count_struct.number_of_samples) * 100;
    percentages.c2l_invalid_data =  (count_struct.c2l_invalid_data / count_struct.number_of_samples) * 100;
    percentages.crc_c2l_invalid_data =  (count_struct.crc_c2l_invalid_data / count_struct.number_of_samples) * 100;
end
function DisplayPercentages(diagnostic)
% Displays the computed error percentages
% in markdown table format.
    crc_err = diagnostic.aksim.percentages.crc;
    c2l_err = diagnostic.aksim.percentages.c2l;
    inv_data_err = diagnostic.aksim.percentages.invalid_data;
    total_error = crc_err + c2l_err + inv_data_err;
    fprintf('| Error Type (AKSIM)     | Percentage |\n');
    fprintf('|------------------------|------------|\n');
    fprintf('| Failed CRC             | %.4f%%     |\n', crc_err);
    fprintf('| C2L warning            | %.4f%%     |\n', c2l_err);
    fprintf('| Invalid data error     | %.4f%%     |\n', inv_data_err);
    fprintf('| Sum of the errors      | %.4f%%     |\n', total_error);
end