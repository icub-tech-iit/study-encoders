function PlotDiagnostic(experiment_data, varargin)
    %{
    PlotDiagnostic: This function overlays diagnostic data on top of 
                    raw encoder data, aligning them using the
                    message generation timestamps.
     Inputs:
     - experiment_data: Experiment dataset required to compute raw encoder 
                        data and extract timestamps.
     - varargin: Pairs of encoder names and their corresponding diagnostic
                 data, specified as 'encoder_name', diagnostic_data.
     For example:
     PlotDiagnostic(experiment_data, 'aksim', diagnostic_data_aksim);
    %}

    expected_encoder_names = {'aksim', 'amo'};
    % The arguments number must be even ([diagnostic_data, associated encoder name])
    if mod(length(varargin), 2) ~= 0
        error('Arguments must be provided as pairs of encoder names and associated diagnostic data.');
    end
    for i = 1:2:length(varargin)
        encoder_name = varargin{i};
        diagnostic_data = varargin{i+1};
        CheckIfEncoderNameValid(encoder_name, expected_encoder_names)
    end

    timestamps = GetTimestamps(experiment_data);
    raw_data = GetRawData(experiment_data);
    switch encoder_name
        case 'aksim'
            mask = MakeMaskAksim(diagnostic_data);
            masked_data = ApplyMaskAksim(raw_data, mask);
            figure(104)
            plot(timestamps, raw_data(1, :), 'k', 'LineWidth', 0.5);
            hold on
            plot(timestamps, masked_data(1, :), 'r*')
            plot(timestamps, masked_data(2, :), 'y*')
            plot(timestamps, masked_data(3, :), 'b*')
            plot(timestamps, masked_data(4, :), 'g*')
            hold off
            title('Errors on raw data (AKSIM)');
            axis([-inf, inf, -2^15, 2.01^19]);
            xlabel('Time (seconds)');
            lgd = legend('Raw joint position', 'Failed CRC', 'C2L warning', 'Invalid Data error', 'Failed CRC + invalid data error');
            lgd.FontSize = 5; lgd.Location = 'north'; lgd.Orientation = 'horizontal';
            set(gca,'color', [0.9 0.9 0.9]);
        case 'amo'
            mask = MakeMaskAMO(diagnostic_data);
            masked_data = ApplyMaskAMO(raw_data, mask);
            figure(105)
            plot(timestamps, raw_data(1, :), 'k', 'LineWidth', 0.5);
            hold on
            plot(timestamps, masked_data(1, :), 'r*')
            plot(timestamps, masked_data(2, :), 'y*')
            plot(timestamps, masked_data(3, :), 'b*')
            hold off
            title('Errors on raw data (AMO)');
            axis([-inf, inf, -2^16, 2.005^20]);
            xlabel('Time (seconds)');
            lgd = legend('Raw joint position', 'Not connected', 'Status 0', 'Status 1');
            lgd.FontSize = 5; lgd.Location = 'north'; lgd.Orientation = 'horizontal';
            set(gca,'color', [0.9 0.9 0.9]);
    end
end

function CheckIfEncoderNameValid(encoder_name, expected_encoder_names)
    % Check if the encoder name exists
    if ~any(strcmp(encoder_name, expected_encoder_names))
        error('Invalid encoder name: %s. Expected one of: %s.', ...
            encoder_name, strjoin(expected_encoder_names, ', '));
    end
end

function mask = MakeMaskAksim(diagnostic)
    mask.crc = diagnostic.aksim.diagn_info.crc > 0;
    mask.c2l = diagnostic.aksim.diagn_info.c2l > 0;
    mask.invalid_data = diagnostic.aksim.diagn_info.invalid_data > 0;
    mask.crc_invalid_data = diagnostic.aksim.diagn_info.crc_invalid_data > 0;
end
function masked_data = ApplyMaskAksim(raw_data, mask)
    if all(raw_data(2, :) == 0) % len(encoder_name) == 1
        crc = raw_data'.*mask.crc; %apply the mask
        c2l = raw_data'.*mask.c2l;
        invalid_data = raw_data'.*mask.invalid_data;
        crc_invalid_data = raw_data'.*mask.crc_invalid_data;
    else
        crc = raw_data(2, :)'.*mask.crc; %apply the mask
        c2l = raw_data(2, :)'.*mask.c2l;
        invalid_data = raw_data(2, :)'.*mask.invalid_data;
        crc_invalid_data = raw_data(2, :)'.*mask.crc_invalid_data;
    end

    processed_data = [crc, c2l, invalid_data, crc_invalid_data]';
    processed_data(processed_data == 0) = nan; % Replace zeros with NaN for plotting
    masked_data = processed_data;
end
function mask = MakeMaskAMO(diagnostic)
    mask.not_connected = diagnostic.amo.not_connected > 0;
    mask.status0 = diagnostic.amo.status0 > 0;
    mask.status1 = diagnostic.amo.status1 > 0;
end
function masked_data = ApplyMaskAMO(raw_data, mask)
    not_connected = raw_data(1, :)'.*mask.not_connected; %apply the mask
    status0 = raw_data(1, :)'.*mask.status0;
    status1 = raw_data(1, :)'.*mask.status1;
    processed_data = [not_connected, status0, status1]';
    processed_data(processed_data == 0) = nan; % Replace zeros with NaN for plotting
    masked_data = processed_data;
end