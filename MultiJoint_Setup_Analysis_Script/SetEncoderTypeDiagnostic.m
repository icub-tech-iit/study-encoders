function diagnostic = SetEncoderTypeDiagnostic(experiment_data, encoder_type)
% Select which diagnostic must be run.
% The function must be called each time a different diagnostic analysis is
% needed.
    switch encoder_type
        case 'aksim'
            diagnostic = ProcessAksimDiagnostic(experiment_data);
        case 'mrie'
            %todo
        case 'amo'
            %todo
    end
end