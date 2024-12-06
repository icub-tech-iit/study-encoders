This code is designed to analyze and visualize errors and warnings thrown by the Aksim2 encoder.
It processes diagnostic data, counts various types of errors, and generates plots for both raw encoder values and error occurrences.
This tool might be useful for users who need to monitor and assess the performance of an Aksim2 encoder.
## Features
1. Error Detection: Identifies and counts different types of errors including CRC errors, C2L warnings, and invalid data errors.
2. Data Visualization: Plots raw encoder values along with optional overlays of detected errors, by means of the <code>PLOT_ERRORS</code> flag.
3. Performance Metrics: Calculates and displays error/warning percentages for comprehensive analysis.
## Data Requirements
The code is designed to accept input data in the form of a <code>.mat</code> file, which has been structured in a way that aligns with the format outlined [here](https://robotology.github.io/robometry/classrobometry_1_1TelemetryDeviceDumper.html).
If you would like to obtain this kind of data, you can do so by means of the <code>telemetryDeviceDumper</code> YARP device.
You will find data retrieved from different experiments [here](inserire link branch "data").

To use the data, simply load the <code>.mat</code> file, specifying its relative path.
'''
% Specify the relative path to the file and load it as 'datastruct':
datastruct = load("Data\aksim2_file_name.mat");
'''
The code will then plot two figures:
1. Encoder raw values (optionally it will overlay the errors by setting PLOT_ERRORS = 1).
2. Joint position, joint velocity, motor position and motor current.

The core functionality is encapsulated in the <code>diagn_error</code> function, which processes diagnostic data to compute error/warnings counts and percentages.
This function is automatically called within the main script after loading the data.