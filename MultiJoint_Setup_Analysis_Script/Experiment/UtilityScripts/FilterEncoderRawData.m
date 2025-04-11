function filtered_data = FilterEncoderRawData(raw_pos_data, diagnostic_data, encoder_type)
%FILTERRAWENCODERDATA Summary of this function goes here
%   Detailed explanation goes here

    filtered_data = zeros(length(raw_pos_data),1);
    
    switch encoder_type
        case 'aksim2'
            fprintf("Filtering data for Aksim2 encoder\n");
            last_correct_value = raw_pos_data(1);
            for i = 1:length(raw_pos_data)
                if ((diagnostic_data.crc__(i) ~= 1) && (diagnostic_data.c2l__(i) ~= 1) && (diagnostic_data.invalid_data__(i) ~= 1))
                    last_correct_value = raw_pos_data(i);
                    filtered_data(i,1) = raw_pos_data(i);
                else
                    filtered_data(i,1) = last_correct_value; % Substitute with last good value
                end
            end
        case 'amo'
            fprintf("Filtering data for AMO encoder\n");
        otherwise
            fprintf("Cannot filter data for this encoder type. Available: [aksim2, amo]\n");
    end
end

