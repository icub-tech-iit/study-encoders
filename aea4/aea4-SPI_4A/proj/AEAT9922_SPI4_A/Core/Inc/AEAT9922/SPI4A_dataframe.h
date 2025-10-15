/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef INC_AEAT9922_SPI4A_DATAFRAME_H_
#define INC_AEAT9922_SPI4A_DATAFRAME_H_

/* Private defines -----------------------------------------------------------*/

/* USER CODE BEGIN Private defines */
#define SPI4A_FRAME_SIZE        2 // 16-bit frame

/* DATA-FRAME */
#define ENCODER_READ_COMMAND    0x3F // Address for reading position
#define SPI_TIMEOUT_MS          250

#define SPI4A_FRAME_P_BIT_POS   19
#define SPI4A_FRAME_EF_BIT_POS  18
#define POSITION_DATA_MASK      0x3FFFF
#define FRAME_P_BIT             (1UL << SPI4A_FRAME_P_BIT_POS)
#define FRAME_EF_BIT            (1UL << SPI4A_FRAME_EF_BIT_POS)
#define SPI4A_PAYLOAD_BYTE_SIZE 3 // 24 bit
#define SPI4A_CMD_SIZE		    2

/* GPIO definitions for software CS control */
#define ENCODER_NSS_PORT         GPIOA
#define ENCODER_NSS_PIN          GPIO_PIN_4
/* USER CODE END Private defines */

#endif /* INC_AEAT9922_SPI4A_DATAFRAME_H_ */
