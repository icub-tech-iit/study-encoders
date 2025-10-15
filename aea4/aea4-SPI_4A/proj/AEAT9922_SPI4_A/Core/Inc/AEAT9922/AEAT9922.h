/**
  ******************************************************************************
  * @file    AEAT9922.h
  * @brief   Header for AEAT9922.c file.
  ******************************************************************************
  * @attention
  *
  * This header file declares the function prototypes for the AEAT9922 driver.
  * It includes all necessary dependencies for the driver to function correctly.
  *
  ******************************************************************************
  */

#ifndef INC_AEAT9922_H_
#define INC_AEAT9922_H_

#ifdef __cplusplus
extern "C" {
#endif

/* Includes */
#include "stm32g4xx_hal.h"
#include <stdbool.h>
#include <stdint.h>

/* Sensor includes */
#include "AEAT9922/config.h"
#include "AEAT9922/diagnostic.h"
#include "AEAT9922/SPI4A_dataframe.h"
#include "AEAT9922/datastructures.h"

HAL_StatusTypeDef AEAT9922_Read_SPI4A(uint8_t reg_addr, uint8_t* read_data);
HAL_StatusTypeDef AEAT9922_Write_SPI4A(uint8_t reg_addr, uint8_t data_to_write);
HAL_StatusTypeDef AEAT9922_ReadPosition_SPI4A(AEAT9922_Reading_t* reading);

#ifdef __cplusplus
}
#endif

#endif /* INC_AEAT9922_H_ */
