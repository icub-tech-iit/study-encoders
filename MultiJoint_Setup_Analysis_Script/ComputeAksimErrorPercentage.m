function diagnostic_aksim_percentages = ComputeAksimErrorPercentage(diagnostic, count)
    %% Calculate percentages
    diagnostic.aksim.percentages.crc = (count.crc / number_of_samples) * 100;
    diagnostic.aksim.percentages.c2l = (count.c2l / number_of_samples) * 100;
    diagnostic.aksim.percentages.invalid_data = (count.invalid_data / number_of_samples) * 100;

    % Mixed errors
    diagnostic.aksim.percentages.crc_invalid_data =  (count.crc_invalid_data / number_of_samples) * 100;
    diagnostic.aksim.percentages.c2l_invalid_data =  (count.c2l_invalid_data / number_of_samples) * 100;
    diagnostic.aksim.percentages.crc_c2l_invalid_data =  (count.crc_c2l_invalid_data / number_of_samples) * 100;
    
    % Total error as sum of the single errors
    total_error = diagnostic.aksim.percentages.crc + ...
                  diagnostic.aksim.percentages.c2l + ...
                  diagnostic.aksim.percentages.invalid_data;

    % Display diagnostic results
    fprintf('Failed CRC: %.4f%%\n', diagnostic.aksim.percentages.crc);
    fprintf('C2L warning: %.4f%%\n', diagnostic.aksim.percentages.c2l);
    fprintf('Invalid data error: %.4f%%\n', diagnostic.aksim.percentages.invalid_data);
    fprintf('Sum of the errors: %.4f%%\n', total_error);

    diagnostic_aksim_percentages = diagnostic;
end