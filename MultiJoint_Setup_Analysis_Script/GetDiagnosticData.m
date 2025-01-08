function [diagnostic_data, number_of_samples] = GetDiagnosticData(experiment_data)
    diagnostic_field = experiment_data.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data;
    diagnostic.data = zeros(size(diagnostic_field, 1), size(diagnostic_field, 3));
    diagnostic.data = diagnostic_field(3:3:size(diagnostic_field, 1), :);
    diagnostic_data = diagnostic.data;
    number_of_samples = length(diagnostic_data);
end