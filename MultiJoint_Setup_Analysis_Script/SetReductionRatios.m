function joints = SetReductionRatios(joints, varargin)
    % The function lets you set the gearboxes reduction ratio.
    joint_number = length(joints.description_list);
    if ~isempty(varargin)
        joints.reduction_ratios = cell2mat(varargin);
        if length(joints.reduction_ratios) < joint_number
            joints.reduction_ratios = HandleMissingGearboxes(joints);
        elseif length(joints.reduction_ratios) > joint_number
            joints.reduction_ratios = HandleExtraGearboxes(joints);
        end
    else
        warning("No gearbox value found. The struct field will not be initialized.")
    end
end

function reduction_ratios =  HandleExtraGearboxes(joints)
    warning("Too many reduction ratios. " + ...
            "Dropping extra arguments.")
    joint_number = length(joints.description_list);
    gearbox_number = length(joints.reduction_ratios);
    joints.reduction_ratios((joint_number + 1):gearbox_number) = [];
    reduction_ratios = joints.reduction_ratios;
end

function full_reduction_ratios = HandleMissingGearboxes(joints)
    warning("Missing reduction ratios. " + ...
            "Automatically setting missing values to one.")
    joint_number = length(joints.description_list);
    gearbox_number = length(joints.reduction_ratios);
    joints.reduction_ratios(gearbox_number:joint_number) = 1;
    full_reduction_ratios = joints.reduction_ratios;
end