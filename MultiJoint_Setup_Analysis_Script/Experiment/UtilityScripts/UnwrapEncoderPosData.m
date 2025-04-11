function unwrapped_data = UnwrapEncoderPosData(pos_data, resolution)
%UNWRAPENCODERPOSDATA Summary of this function goes here
%   Detailed explanation goes here
    temp = ((pos_data/resolution)*2*pi)*(-1);
    temp = unwrap(temp);
    unwrapped_data = (temp/(2*pi))*360;
    unwrapped_data = unwrapped_data - unwrapped_data(1);
    clear temp
end

