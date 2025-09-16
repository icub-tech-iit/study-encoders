classdef TestAmoEncoder < matlab.unittest.TestCase

    properties
        AmoEncoderObj;
    end

    methods (TestMethodSetup)
        function createObjects(tc)
            tc.AmoEncoderObj = AmoEncoder();
        end
    end

    methods (Test)
        function testComputeDiagnosticError(tc)
            % Create a mock Experiment object manually
            mockExperiment = struct();
            
            % Define the mock GetDiagnosticData method
            numSamples = 100;
            mockData = zeros(2, numSamples);
            mockData(2, 10) = bitshift(hex2dec('02'), 16); % Status 0 Error
            mockData(2, 20) = bitshift(hex2dec('03'), 16); % Status 1 Error
            mockData(2, 30) = bitshift(hex2dec('04'), 16); % Not Connected
            
            getDiagnosticDataFunc = @() deal(mockData, numSamples);
            mockExperiment.GetDiagnosticData = getDiagnosticDataFunc;

            % Run the method under test with the mock object
            tc.AmoEncoderObj.computeDiagnosticError(mockExperiment);
            
            % Verify the counts
            counts = tc.AmoEncoderObj.getDiagnostic().counts;
            tc.verifyEqual(counts.status0, 1);
            tc.verifyEqual(counts.status1, 1);
            tc.verifyEqual(counts.not_connected, 1);
            tc.verifyEqual(counts.total_errors, 3);

            % Verify percentages
            percentages = tc.AmoEncoderObj.getDiagnostic().percentages;
            tc.verifyEqual(percentages.status0, 1/100 * 100);
            tc.verifyEqual(percentages.status1, 1/100 * 100);
            tc.verifyEqual(percentages.not_connected, 1/100 * 100);
            tc.verifyEqual(percentages.total, 3/100 * 100);
        end
    end
end