# MultiJoint_Setup_Analysis_Script

This MATLAB application is a suite of scripts and classes designed to load, analyze, and visualize data from robotic joint experiments. It provides tools to process and inspect data from motors, joints, and specific encoder types (Aksim and AMO), focusing on performance analysis, diagnostic error checking, and data correlation.

The `main.m` script provides a comprehensive example of how to use these tools to load a `.mat` experiment file and conduct various analyses, such as:

  * Encoder diagnostic reports
  * Maximum velocity tests
  * Peak torque (pendulum) tests
  * Continuous torque (position hold) tests

-----

## Key Features

  * **Data Loading:** Loads structured `.mat` experiment files using the `Experiment` class, which can handle time-based slicing of the data.
  * **Data Parsing:** Automatically extracts motor and joint data (positions, velocities, currents, PWM, temperature) into `Motor` and `Joint` objects.
  * **Encoder Diagnostics:** Computes and displays detailed diagnostic error reports for **Aksim** (CRC, C2L, Invalid Data) and **AMO** (Status 0, Status 1, Not Connected) encoders.
  * **Data Filtering:** Filters raw encoder position data by removing or holding samples that are flagged with diagnostic errors.
  * **Position Unwrapping:** Unwraps and rescales raw, wrapping encoder position counts into a continuous 360-degree representation in the joint space.
  * **Visualization:** Includes multiple plotting functions (`PlotMotorData`, `PlotJointData`, `PlotMotorDataTemperature`) to quickly visualize key metrics in a tiled layout.
  * **Correlation Analysis:** The `main.m` script demonstrates how to plot correlations between different sensors (e.g., motor position vs. joint position, position vs. current).
  * **Unit Tests:** Includes basic unit tests for encoder diagnostic logic (`TestAksimEncoder.m`, `TestAmoEncoder.m`).

-----

## Core Files

  * `main.m`: The main example script demonstrating the full analysis workflow.
  * **Classes:**
      * `Experiment.m`: Handles loading and subsetting of the main experiment `.mat` file.
      * `Motor.m`: Parses and stores all motor-specific data (PWM, current, temp, etc.).
      * `Joint.m`: Parses and stores all joint-specific data (position, velocity, etc.).
      * `Encoder.m`: Base class for encoders.
      * `AksimEncoder.m`: Implements diagnostic logic for Aksim encoders.
      * `AmoEncoder.m`: Implements diagnostic logic for AMO encoders.
  * **Plotting Functions:**
      * `PlotMotorData.m`: Generates a 2x2 plot of motor position, PWM, and current.
      * `PlotJointData.m`: Generates a 3x1 plot of joint position, velocity, and acceleration.
      * `PlotMotorDataTemperature.m`: Same as `PlotMotorData` but includes temperature.
  * **Utility Functions:**
      * `FilterEncoderRawData.m`: Cleans raw encoder data using diagnostic flags.
      * `UnwrapEncoderPosData.m`: Converts raw encoder counts into continuous degrees.
      * `Theoretical_jPos_from_mPos.m`: Calculates the theoretical joint position from the motor position.
      * `GetMotorData.m`, `DefineJointStruct.m`: Helper functions for extracting data (though `Motor.m` and `Joint.m` classes are now used in `main.m`).

-----

## How to Use

1.  **Add to Path:** Ensure the entire folder containing these scripts is added to your MATLAB path. The `main.m` script does this automatically for its own directory:

    ```matlab
    addpath(genpath('.'))
    ```

2.  **Load Experiment:**

      * Instantiate an `Experiment` object.
      * Load your `.mat` data file using the `LoadData` method.
      * (Optional) Set `StartTime` and `EndTime` properties to analyze only a slice of the experiment.
      * (Optional) Set gearbox reduction ratios using `setReductionRatios`.

    ```matlab
    my_experiment_A = Experiment(); 
    my_experiment_A.LoadData('Data/your_experiment_file.mat'); 
    my_experiment_A.StartTime = 0; % Optional: Start at 0 seconds
    my_experiment_A.setReductionRatios(100, 100); % Set gear ratios
    ```

3.  **Initialize Data Objects:**

      * Create the `Motor`, `Joint`, and `Encoder` objects using the loaded experiment data.
      * Get the `timestamps` array from the experiment object.

    ```matlab
    timestamps = my_experiment_A.GetTimestamps()';
    my_joint_A = Joint(my_experiment_A); 
    my_motor_A = Motor(my_experiment_A);
    my_aksim_encoder_A = AksimEncoder();
    my_amo_encoder = AmoEncoder();
    ```

4.  **Run Analysis & Plot:**

      * Use the object methods and standalone functions to perform analysis.
      * Refer to `main.m` for a wide variety of detailed examples.

    **Example: Run Encoder Diagnostics**

    ```matlab
    my_aksim_encoder_A.computeDiagnosticError(my_experiment_A); 
    my_aksim_encoder_A.displayReport();

    my_amo_encoder.computeDiagnosticError(my_experiment_A);
    my_amo_encoder.displayReport();
    ```

    **Example: Plot Motor Data**

    ```matlab
    figure()
    PlotMotorData(timestamps, my_motor_A);
    ```

    **Example: Plot Joint Data**

    ```matlab
    figure()
    PlotJointData(timestamps, my_joint_A);
    ```

-----

## Dependencies

  * **MATLAB:** Developed and tested in MATLAB.
  * **Data Structure:** The scripts rely on a specific `.mat` file structure, related to the `telemetryDeviceDumper`.
