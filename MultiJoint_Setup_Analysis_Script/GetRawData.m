function raw_data = GetRawData(experiment_data)
    %{
     - This function retrieves the raw data from the .mat robometry file
     - The first component is the primary encoder of the joint 0
     - The second component is the secondary encoder of the joint 0
     - The third component is the primary encoder of the joint 1
     - and so on...
    %}
    joint_number = GetNumberOfJoints(experiment_data);
    data_length = size(experiment_data.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data, 3);
    raw_data = zeros(2*joint_number, data_length);
    for i = 1:joint_number
        raw_data(i:(i + 1), :) = [experiment_data.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data((3*i - 2):(3*i - 1), :)];
    end
end