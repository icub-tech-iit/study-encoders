/*
 * Copyright (C) 2024 iCub Facility - Istituto Italiano di Tecnologia
 * Author: Andrea Solari
 * email:  andrea.solari@iit.it
 * website: www.robotcub.org
 * Permission is granted to copy, distribute, and/or modify this program
 * under the terms of the GNU General Public License, version 2 or any
 * later version published by the Free Software Foundation.
 *
 * A copy of the license can be found at
 * http://www.robotcub.org/icub/license/gpl.txt
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
 * Public License for more details
*/


#include "encoderWaveGenerator.h"

#define TIM_TIME htim16

static uint32_t t = 0;                                                  // Current temp set 0
static uint32_t T_wave = 0;                                             // Define wave period end set default
static bool state1 = true;                                              // Flag state for square wave 1
static bool state2 = true;                                              // Flag state for square wave 2
static bool sequence = true;                                            // Check flag
static uint32_t offset_wave = 50;                                       // Define wave offset end set default
static uint32_t T_index = 100;                                          // Define index end set default
                                                                        
bool index_state = false;                                               // Flag for index call
bool index_none = false;                                                // flag test for index none
bool turn_onoff = false;                                                // Flag to turn on the features with blue button
                                                                        
uint32_t counter = 0;                                                   // Global start value for counter
uint32_t time = 0;                                                      // Global start value for time
uint32_t t1 = 0;                                                        // Global start value for t1
uint16_t cpr = 940*4;                                                  // Correct value for cpr


void init(uint32_t waveLen, uint32_t offsetWave, uint32_t TIndex)     // First value without button press
{
    T_wave = waveLen;
    offset_wave = offsetWave;
    T_index = TIndex;
}


// - create a micros counter ---------------------------------------------------------------------------------------------------
uint32_t micros_asolari(void)
{
	return ((__HAL_TIM_GET_COUNTER(&TIM_TIME) + (time << 16) ) );       // I create a micro time base
}

// - build a index time dimension ----------------------------------------------------------------------------------------------

void Index_timing(void)
{
  uint32_t dt1 = micros_asolari() - t1;
	
	if(dt1 >= T_index)
	{
		HAL_GPIO_WritePin(ENCZ_GPIO_Port,ENCZ_Pin,false);               // Here write the state for GPIO
		index_state = false;                                            // Update the index condition
	}
}

// - build A e B channel time dimension ----------------------------------------------------------------------------------------

void Wave_generator(void)
{
    
    uint32_t dt = micros_asolari()- t;

    if((dt>= T_wave) && (sequence==true))
    {
        state1 = !state1;
        HAL_GPIO_WritePin(ENCA_GPIO_Port,ENCA_Pin,state1);              // Here write the state for GPIO
        sequence = false;
    }
    
    if (dt >= (T_wave + offset_wave))
    {
        state2 = !state2;
        HAL_GPIO_WritePin(ENCB_GPIO_Port,ENCB_Pin,state2);              // Here write the state for GPIO
        t = micros_asolari();
        sequence = true;

        if((true==state1) && (true==state2))
        {
            counter++;                                                  // Update a index counter only when both signals are low
        }
    }
}

// - Here detect index condition and create a output ------------------------------------------------------------------------------

void Index_generator(void)
{
	if (index_state == true)
	{
        HAL_GPIO_WritePin(ENCZ_GPIO_Port,ENCZ_Pin,true);
        Index_timing();
	}
}

// here the Callback function ----------------------------------------------------------------------------------------------------


/*
 * ENCODER CPR --> 1300  (940)
 * => 360°/1300 = 0.2769° OF RESOLUTION, 360°/940 = 0.3830°
 * THE GEARBOX BETEWEEN HIGH/LOW SPEED IS 160, 100
 * MAX SPEED MOTOR IS 6000 RPM --> 105 KHz
*/

// press button SW1 to configure the "normal situation" with Vel = 20°/s --> 11.5 KHz  (5.22 KHz se cpr=940 e r=100)
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
  if(GPIO_Pin == BUTTON_HALL_Pin) 
  {
      
    cpr = 940*16;                                              // Set normal cpr
      
    T_wave = 4800/2;              //48/2;
    offset_wave = 4800/2;         //48/2;
    T_index = 4800;               //48;
  
    // Update LED USER status
      
      HAL_GPIO_WritePin(LED_UP_GPIO_Port,LED_UP_Pin,true);
      HAL_GPIO_WritePin(LED_S2_GPIO_Port,LED_S2_Pin,false);     
      HAL_GPIO_WritePin(LED_S3_GPIO_Port,LED_S3_Pin,true);
      
      HAL_GPIO_WritePin(LED_M2_GPIO_Port,LED_M2_Pin,true);
      HAL_GPIO_WritePin(LED_S1_GPIO_Port,LED_S1_Pin,true);
      
  }
// press button SW2 to configure the "normal situation" with Vel = 20°/s --> 23 KHz  (10.44 KHz se cpr=940 e r=100)
   if(GPIO_Pin == BUTTON_START_Pin) 
  {
      
    cpr = 940*16;                                              // Set normal cpr
      
    T_wave = 22/2;
    offset_wave = 22/2;
    T_index = 22;

    // Update LED USER status
   
      
      HAL_GPIO_WritePin(LED_UP_GPIO_Port,LED_UP_Pin,false);
      HAL_GPIO_WritePin(LED_S2_GPIO_Port,LED_S2_Pin,true);     
      HAL_GPIO_WritePin(LED_S3_GPIO_Port,LED_S3_Pin,true);
      
      HAL_GPIO_WritePin(LED_M2_GPIO_Port,LED_M2_Pin,true);
      HAL_GPIO_WritePin(LED_S1_GPIO_Port,LED_S1_Pin,true);
      
  }
// press button SW5 to configure the "normal situation" with incremental from previus normal Vel condition
    if(GPIO_Pin == BUTTON_MODE_Pin) 
  {
      
    cpr = 940*16;                                             // Set normal cpr      
      
    T_wave = (T_wave/2);
    offset_wave = (offset_wave/2);
    T_index = (T_index/2); 
    index_none = false;                                       // test for index none, set true here if you don't wont a index wave
  
    // Update LED USER status
      
      HAL_GPIO_WritePin(LED_UP_GPIO_Port,LED_UP_Pin,true);
      HAL_GPIO_WritePin(LED_S2_GPIO_Port,LED_S2_Pin,true);     
      HAL_GPIO_WritePin(LED_S3_GPIO_Port,LED_S3_Pin,false);

      HAL_GPIO_WritePin(LED_M2_GPIO_Port,LED_M2_Pin,true); 
      HAL_GPIO_WritePin(LED_S1_GPIO_Port,LED_S1_Pin,true);      
      
      
  }
  
//MORE TEST NECESSARY//  
  
// press button SW4 to configure the "cpr error = tick error" from cpr=940 to cpr=1300
    if(GPIO_Pin == BUTTON_UP_DOWN_Pin) 
  {
      cpr = 940;                                            // Set e wrong value of CPR (wrong but probable)
  
    // Update LED USER status
      
      HAL_GPIO_WritePin(LED_UP_GPIO_Port,LED_UP_Pin,true);
      HAL_GPIO_WritePin(LED_S2_GPIO_Port,LED_S2_Pin,true);     
      HAL_GPIO_WritePin(LED_S1_GPIO_Port,LED_S1_Pin,false);

      HAL_GPIO_WritePin(LED_M2_GPIO_Port,LED_M2_Pin,true);      
      
      
  }

// press button SW3 to create a incremental index fault from previus condition
    if(GPIO_Pin == BUTTON_SPEED_Pin) 
  {
    cpr = 940*16;                                               // Set normal cpr
    T_index = T_index/2;
      
    // Update LED USER status
    
    HAL_GPIO_WritePin(LED_M2_GPIO_Port,LED_M2_Pin,false);
    HAL_GPIO_WritePin(LED_S1_GPIO_Port,LED_S1_Pin,true);
    
  }
}



//here i use the interrupt callback when timer roll over
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{

	//check the callback and toggle the GPIO pin
	if (htim == &TIM_TIME)
	{
		time++;
    }
}