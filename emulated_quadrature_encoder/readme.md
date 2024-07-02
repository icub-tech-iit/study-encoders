# **HOW TO USE AUX_AMC_TEST_17642 TO SIMULATE DIGITAL SIGNALS FROM AN INCREMENTAL ENCODER.**


# 1.	Introduction
If you are reading this document you are probably trying to simulate a pair of digital signals such as those that an incremental encoder generates. What you need to know now is that this setup is designed to provide just 2 quadrature square wave signals and their index.
Through this setup you will also be able to simulate some error cases to validate the strength of your device's reading. In particular, reference is made to the case of:

-	**Index error**
-	**Index missing**
-	**CH B Missing**
-	**CPR error**

  
We will see these situations in more detail. Normally, what you try to reproduce then is exactly this behavior:

![Picture1](https://github.com/icub-tech-iit/study-encoders/assets/160229887/6a71d2ab-cc78-44ec-9d28-fbd157826b1e)




It is possible to generate this behavior, for example, with the AEDR-9830 encoder. In this case, the optical disk rotates with respect to a sensor that will provide feedback of the successful transition through two readings offset by 90°, channel A and channel B. In the image below you will find a representation of this. Also observe the presence of the index, here the optical sensor will provide a signal of the correct size to tell you that you have made 1 full turn (360°).

>[!WARNING]
>In the fw exactly this behavior is simulated, so the resolution and index characteristics also depend on this specific case.

![Picture2](https://github.com/icub-tech-iit/study-encoders/assets/160229887/c82e5b5c-f364-4215-be0c-16f575012a07)

>[!NOTE]
>In this guide I show the behavior of the FW designed to reproduce the behavior of an incremental encoder with CPR = 940 and P0 = P/2.

# 2.	PREPARE YOUR SETUP AND UPLOAD THE FW
## 2.1 Hardware
The first step now is to have the AUX_AMC_TEST_17642 and the NUCLEO-G474RE. You will notice that the core can be inserted into the headers as in the picture.

![Picture3](https://github.com/icub-tech-iit/study-encoders/assets/160229887/5d2240d5-9894-462c-8dec-392047857271)

Another important thing is to connect the crocodile as in the picture:
![Picture4](https://github.com/icub-tech-iit/study-encoders/assets/160229887/1035d660-a619-4763-bef4-2a218fc996ed)

## 2.2	Firmaware Upload

Now you need the FW, you can find the updated version [here](https://github.com/icub-tech-iit/study-encoders/tree/code/emulated_quadrature_encoder/incremental_encoder_AUX-AMC_NUCLEO_V03.2)
Open the latest version with Keil Uvision5, you should have something like this:

![Picture5](https://github.com/icub-tech-iit/study-encoders/assets/160229887/4fa9b537-ce6d-4b54-a793-2d2a875a6e5e)

Then you can proceed to BUILD and F8 to LOAD to the core board.

![Picture6](https://github.com/icub-tech-iit/study-encoders/assets/160229887/ad1d2485-aca7-4bcc-9b2c-e72ec8148688)

If everything worked you should have no errors and you should read this in the Build output.

![Picture7](https://github.com/icub-tech-iit/study-encoders/assets/160229887/cf4c1075-8bc5-4ef6-8966-f0cf63249f66)

Now press the black reset button on your core board and you are done with this part! You can start using the set up even without a PC. You will only need to power your core board from the micro usb port.

![Picture8](https://github.com/icub-tech-iit/study-encoders/assets/160229887/14416b6e-0947-47b4-9498-9af8ddd12f51)

# 3.	FEATURES

In this chapter I describe the intended functionality, the first thing to do is to turn on your simulator. When you start it up, in fact, you will not generate any signal, so it will be like having the mechanical system stopped for you.
To turn on, press the BLUE button on your core board as in the picture, a power LED on the board will follow you.

![Picture9](https://github.com/icub-tech-iit/study-encoders/assets/160229887/f21adedb-928a-4422-8c48-c65f3cbd0a6a)

At this point, you have turned on your simulator and are already generating the signal in quadrature with the index in its correct form.

## 3.1 Default conditions
If you turned on the board now by pressing the Blue button or were using it and pressed the Black button and again the Blue button you are in the Default condition. This state corresponds to the following working point:


| DATA | Description |
| --- | --- |
| Signal frequency | 5 KHz |
| Equivalent joint speed | 10°/second |


![Picture10](https://github.com/icub-tech-iit/study-encoders/assets/160229887/3f65a496-250c-4e8f-bba1-d84396974a30)

## 3.2	Nominal Work Point 1

You can always return to this defined working point no matter what state you are in. To achieve this situation, press the SW1 button as in the picture; the status LED will also follow you.

![Picture11](https://github.com/icub-tech-iit/study-encoders/assets/160229887/4b6f7c63-d57c-4628-967c-6e0acd96855b)

The selected work point corresponds to the situation in the table:

| DATA | Description |
| --- | --- |
| Signal frequency | 100 Hz |
| Equivalent joint speed | 5°/second |

![Picture12](https://github.com/icub-tech-iit/study-encoders/assets/160229887/07357bea-9f84-4766-8887-c273661195db)

## 3.3	Nominal Work Point 2

You can always return to this a priori-defined working point no matter what state you are in. To achieve this situation, press the SW2 button as in the picture; the status LED will also follow you.


![Picture13](https://github.com/icub-tech-iit/study-encoders/assets/160229887/c86ccb69-b61f-408e-8d44-8b5372278b71)

| DATA | Description |
| --- | --- |
| Signal frequency | 23 KHz |
| Equivalent joint speed | 20°/second |

![Picture14](https://github.com/icub-tech-iit/study-encoders/assets/160229887/6980672a-7a19-4b0f-aed6-c411ee18b4aa)

## 3.4	2Xspeed

This feature allows you to start from one of the working points described above and increase the speed if necessary. Consider that each time you press the SW5 button the speed is like doubling, this also means having the index signal increasing with the frequency of the CHA and CHB.

![Picture15](https://github.com/icub-tech-iit/study-encoders/assets/160229887/25bf456c-7d40-4878-86a6-e452589a8537)

I give here an example of what happens if you press SW5 2 times consecutively at CHA (similar reasoning for other signals):

![Picture16](https://github.com/icub-tech-iit/study-encoders/assets/160229887/1bbfb04d-a384-475e-b3d7-18032355a09a)

To return to a lower speed, press the SW1 or SW2 buttons again to return to a nominal working point.


## 3.5	Index Error

This feature allows, by pressing SW3 to reproduce the case where the index signal has a different measurement from the nominal one. From the point of view of the physics of the problem, it is as if the “notch” of the index had a smaller area than the predetermined one:

![Picture17](https://github.com/icub-tech-iit/study-encoders/assets/160229887/d70df6af-978b-49b7-96bd-58f2112d2188)

Pressing the SW3 button will cause a red light to follow you to signal that, compared to your current working point, you have just halved the size of the index signal.

![Picture18](https://github.com/icub-tech-iit/study-encoders/assets/160229887/6de4f50c-757c-45c4-8081-ce8af71f74b0)

Pressing the SW3 button again means further halving the size of the index signal. This feature is designed precisely to test how far the system can detect the index signal if abnormal.

![Picture19](https://github.com/icub-tech-iit/study-encoders/assets/160229887/24b37978-20db-4021-8621-2f24dcc06dcf)

To exit this feature you can again press SW1 and SW2 to return to a default operating point. If you press SW5 instead, you double the speed to the situation despite the current fault situation. The following image helps to understand the scenario in this case.

![Picture20](https://github.com/icub-tech-iit/study-encoders/assets/160229887/d4561e72-5a49-4dd8-b10c-5a0a98a7b0be)


## 3.6 CPR error


This feature allows you to see if your system is robust to a CPR error. Normally, in fact, after a certain number of CPRs (i.e., ticks) the optical disk presents the index to signal that you have just completed a full turn. The CPR value, defined by the technology used, conditions all the readings the system can take. Pressing the SW4 button generates a scenario where the index signal is generated every 45° (in our specific case) and not 360° as it should be. From a graphical point of view it is as if you have something like this:

![image](https://github.com/icub-tech-iit/study-encoders/assets/160229887/7c63450a-958e-4bda-ba4d-401f5fa76fd8)


![Picture21](https://github.com/icub-tech-iit/study-encoders/assets/160229887/a6fd3f29-7bf0-41a3-8abd-712855dfcfd7)

By pressing the SW1 and SW2 buttons you can return to one of the two nominal points thus restoring the error condition.

# 4. HARDWARE FAULT

This part describes how to generate in HW mode the sudden absence of the index signal and the channel B signal.

## 4.1 Index Missing

Use the connector as in the figure to generate the sudden absence of the index signal.

![Picture22](https://github.com/icub-tech-iit/study-encoders/assets/160229887/ff22db60-3501-4643-90e2-950fe5aaf000)

## 4.2 CH B Missing

Use the connector as in the figure to generate the sudden absence of the CHB signal.

![Picture23](https://github.com/icub-tech-iit/study-encoders/assets/160229887/7a2c7ae3-2b95-4e51-92bf-62c528db5120)








