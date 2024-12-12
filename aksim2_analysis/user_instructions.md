
### User instructions for running the code

This document explains how to use the provided MATLAB code to process experimental data provided by the Aksim2 encoder, compute diagnostics, and visualize the results.

---
 The code expects a `.mat` file which has been structured in a way that aligns with the format outlined [here](https://robotology.github.io/robometry/classrobometry_1_1TelemetryDeviceDumper.html). The data file path is specified by `dataPath` and its data is collected in a struct using the function <code>fillStruct</code>, where you can find the following quantities:
- RawData: Encoder values expressed in terms of the chosen resolution configuration.
- jointPosition: Retrivied position at the joint in [deg].
- jointVelocity: Retrivied position at the joint in [deg\sec].
- motorCurrent: Current absorbed by the motor in [A].
- motorPosition: Retrieved position of the motor rotor in [deg\sec].
- diagnosticData: Retrieved error code.
- time: Timestamps in [sec].

The script is supposed to
 1. Compute diagnostic errors using `computeDiagnosticError`.
 2. Calculate error occurrence percentages with `calculatePercentages`.
 3. (*Optional*) Plot the data and the errors by means of <code>plotErrors</code>, <code>plotJointMotorStates</code>, <code>plotJointPos_vs_JointPosCalculated</code>.

To enable the plotting option you must set the <code>plotEnable</code> flag.  In this case you need to define:
  - `plotSpeedTitle` to change plot titles.
  - `timeOffset` to define when the actual test data starts.

The script identifies debug messages using the codes , as defined in the [encoder reader module](https://github.com/robotology/icub-firmware/blob/master/emBODY/eBcode/arch-arm/embobj/plus/board/EOappEncodersReader.c#L1469-L1494):
  - `0x01` for CRC (cycle redundancy check).
  - `0x02` for C2L (close to limits) warning.
  - `0x04` for Invalid Data errors.

These messages are chosen according to the [AksIM-2 documentation](https://www.rls.si/eng/aksim-2-off-axis-rotary-absolute-encoder).

At the end of the process, an estimate of the error is provided between the actual measured data and the reprojection of the motor position in the joint space, which is handled by the function `plotJointPos_vs_JointPosCalculated`.

The function removes the initial offset from both joint and motor position data, starting from the specified `timeOffset` index. It calculates the joint position using the motor position data scaled by a known gear ratio and determines the error as the difference between the calculated and measured joint positions. Additionally, it identifies the maximum and minimum errors along with their corresponding time indices.

Finally, the function plots the joint position error against time and highlights the maximum and minimum error values using horizontal dashed lines and markers to emphasize the error levels and specific values.
