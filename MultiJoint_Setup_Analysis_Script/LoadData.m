function experiment_data = LoadData(data_path)
    % Load data from the specified path
    loaded_data = load(data_path);
    field_name = fieldnames(loaded_data);
    test_name = field_name{1};
    experiment_data = loaded_data.(test_name);
end