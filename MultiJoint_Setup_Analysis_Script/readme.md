<<<<<<< HEAD
To run the script, open `multijoint_setup_handler.m` and execute it, calling the required functions as needed.

The principal functions are listed below:

- `LoadData(robometry_data_path)`: Loads the robometry `.mat` files and assigns them the name `experiment_data`.
- `GetTimestamps(experiment_data)`: Retrieves the timestamps of the experiment for analysis and plotting purposes.
- `GetNumberOfJoints(experiment_data)`: Returns the number of joints involved in the experiment.
- `DefineMotorStruct(experiment_data)`: Creates a structure filled with motor data.
- `DefineJointStruct(experiment_data)`: Creates a structure filled with joint data.
- `GetRawData(experiment_data)`: Extracts raw data from the encoders.
- `SetReductionsRatio(joint_struct, r_ratio_1, r_ratio_2, ..., r_ratio_N)`: Sets the reduction ratios of the joint gearboxes.
- `SetEncodersResolution('encoder_1_name', encoder_1_resolution, ..., 'encoder_3_name', encoder_3_resolution)`: Sets the resolution values for the specified encoders. Supported encoder names include `aksim`, `amo`, and `mrie`.
- `SetEncoderTypeDiagnostic(experiment_data, 'encoder_i_name')`: Retrieves diagnostic data and analyzes it according to the documentation of the selected encoder. It implements the `aksim` diagnostic (support for `amo` and `mrie` is pending).

By combining these functions, various types of analyses can be performed.

The code can be used for analysis tasks but could benefit from reorganization to make it more accessible for users unfamiliar with MATLAB.
=======
To run the script, open <code>multijoint_setup_handler.m</code> and run it, calling the required functions.

The principal functions are the ones listed below:
- <code>LoadData *(robometry_data_path)</code>: Loads the robometry .mat files and gives them the name of "experiment_data".
- <code>GetTimestamps(experiment_data)</code>: Get the timestamps of the experiment, for both analysis and plotting purposes.
- <code>GetNumberOfJoints(experiment_data)*: Returns the number of joints involved in the experiment.
- <code>DefineMotorStruct(experiment_data)</code>Creates a struct filled with the motors data.
- <code>DefineJointStruct(experiment_data)</code>:  Creates a struct filled with the joints data.
- <code>GetRawData(experiment_data)</code>: Gets the raw datas from the encoders.
- <code>SetReductionsRatio(joint_struct, r_ratio_1, r_ratio_2, ..., r_ratio_N)</code>: Set the reduction ratio of the joint gearboxes.
- <code>SetEncodersResolution('encoder_1_name', encoder_1_resolution, 'encoder_2_name', encoder_2_resolution, 'encoder_3_name', encoder_3_resolution)</code>: It takes an encoder name (chosen between aksim, amo and mrie) and sets the resolution values.
- <code>SetEncoderTypeDiagnostic(experiment_data, 'encoder_i_name')</code>: Gets the diagnostic data and analyzes it according to the documentation of the selected encoder. It implements the Aksim diagnostic (amo and mrie are to do).
<br>
By combining these functions, many different types of analysis can be performed.<br>
The code can be used for analysis tasks, but it can definitely be reorganised to make it more usable for people who are not really familiar with MatLab.
>>>>>>> 994a5a2 (removed old version of aksim2_analysis (you can find the newer one in aksim2_analysis))
