function diagnostic = ProcessAmoDiagnostic(experiment_data)
%% Elaborate diagnostic data
diagnostic_data = GetDiagnosticData(experiment_data);
diagnostic_data_amo = diagnostic_data(1, :);
s = length(diagnostic_data_amo);

diagnostic.amo.not_connected = zeros(s,1);
diagnostic.amo.status0 = zeros(s,1);
diagnostic.amo.status1 = zeros(s,1);

status0_counter = 0;
status1_counter = 0;
notconn_counter = 0;
diagn_error_counter = 0;

for d = 1:s
    diagn_type = bitshift(diagnostic_data_amo(d),-16); %rightshift by 16
    % diagn_val(d) =  cast(bitand(diagnostic_data_amo(d), 255), "double");   
    switch(diagn_type)
        case 0x02
            diagnostic.amo.status0(d) = 1;
            status0_counter = status0_counter + 1;
            diagn_error_counter = diagn_error_counter+1;
        case 0x03
            diagnostic.amo.status1(d) = 1;
            status1_counter = status1_counter + 1;
            diagn_error_counter = diagn_error_counter+1;
        case 0x04
            diagnostic.amo.not_connected(d) = 1;
            notconn_counter = notconn_counter + 1;
            diagn_error_counter = diagn_error_counter+1;
    end
end
diagnostic.amo.percentages.total = (diagn_error_counter / s)*100;
diagnostic.amo.percentages.status0 = (status0_counter/ s)*100;
diagnostic.amo.percentages.status1 = (status1_counter/ s)*100;
diagnostic.amo.percentages.not_conn = (notconn_counter/ s)*100;
DisplayPercentagesAMO(diagnostic);
end

function DisplayPercentagesAMO(diagnostic)
% Displays the computed error percentages
% in markdown table format.
    fprintf('| Error Type (AMO)       | Percentage |\n');
    fprintf('|------------------------|------------|\n');
    fprintf('| Status 0               | %.4f%%     |\n', diagnostic.amo.percentages.status0);
    fprintf('| Status 1               | %.4f%%     |\n', diagnostic.amo.percentages.status1);
    fprintf('| Not connected          | %.4f%%     |\n', diagnostic.amo.percentages.not_conn);
    fprintf('| Total error            | %.4f%%     |\n', diagnostic.amo.percentages.total);
end