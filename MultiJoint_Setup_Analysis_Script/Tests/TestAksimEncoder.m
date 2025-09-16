classdef TestAksimEncoder < matlab.unittest.TestCase

    properties
        AksimEncoderObj;
    end

    methods (TestMethodSetup)
        function createObjects(tc)
            tc.AksimEncoderObj = AksimEncoder();
        end
    end

    methods (Test)
        function testComputeDiagnosticError(tc)
            % Create a mock Experiment object manually
            mockExperiment = struct();
            
            % Define the mock GetDiagnosticData method
            numSamples = 100;
            mockData = zeros(2, numSamples);
            mockData(1, 10) = hex2dec('01'); % CRC Error
            mockData(1, 20) = hex2dec('02'); % C2L Error
            mockData(1, 30) = hex2dec('04'); % Invalid Data
            mockData(1, 40) = hex2dec('03'); % C2L + CRC
            mockData(1, 50) = hex2dec('05'); % CRC + Invalid Data
            mockData(1, 60) = hex2dec('06'); % C2L + Invalid Data
            mockData(1, 70) = hex2dec('07'); % CRC + C2L + Invalid Data
            
            getDiagnosticDataFunc = @() deal(mockData, numSamples);
            mockExperiment.GetDiagnosticData = getDiagnosticDataFunc;

            % Run the method under test with the mock object
            tc.AksimEncoderObj.computeDiagnosticError(mockExperiment);
            
            % Verify the counts
            counts = tc.AksimEncoderObj.Diagnostic.counts;
            tc.verifyEqual(counts.crc, 4);
            tc.verifyEqual(counts.c2l, 1);
            tc.verifyEqual(counts.invalid_data, 2);
            
            % Verify percentages
            percentages = tc.AksimEncoderObj.Diagnostic.percentages;
            tc.verifyEqual(percentages.crc, 4/100 * 100);
            tc.verifyEqual(percentages.c2l, 1/100 * 100);
            tc.verifyEqual(percentages.invalid_data, 2/100 * 100);
        end
    end
end