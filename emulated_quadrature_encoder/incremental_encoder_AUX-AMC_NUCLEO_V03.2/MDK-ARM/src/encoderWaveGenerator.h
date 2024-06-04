/*
 * Copyright (C) 2024 iCub Facility - Istituto Italiano di Tecnologia
 * Author:  Andrea Solari
 * email:   andrea.solari@iit.it
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


// - include guard ----------------------------------------------------------------------------------------------------
#ifndef _ENCODERWAVEGENERATOR_H_
#define _ENCODERWAVEGENERATOR_H_


#include <stdint.h>
#include "stdbool.h"
#include "gpio.h"
#include "tim.h"


extern uint32_t counter;  
extern bool index_state;
extern bool index_none;
extern bool turn_onoff; 
extern uint32_t t1;
extern uint32_t time;
extern uint16_t cpr;

// this function generate a output signial 
void Wave_generator(void);
// this function detect index ctate condition
void Index_generator(void);
// This function generate a output signal for index event
void Index_timing(void);
// This function increment a time variable every uS
uint32_t micros_asolari(void);

void init(uint32_t waveLen, uint32_t offsetWave, uint32_t TIndex);
//uint32_t getCounter(void);
//void setCounter(uint32_t value);


#endif