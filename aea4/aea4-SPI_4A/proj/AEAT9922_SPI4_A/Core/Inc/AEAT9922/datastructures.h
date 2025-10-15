/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef INC_AEAT9922_DATASTRUCTURES_H_
#define INC_AEAT9922_DATASTRUCTURES_H_
/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN TD */

typedef struct {
    uint32_t raw_frame;
    uint32_t position;
    float angle_degrees;
    uint8_t crc_received;
    uint8_t crc_calculated;
    bool is_warning;
    bool is_error;
    bool crc_ok;
} AEAT9922_Reading_t;

typedef struct {
    uint8_t addr;
    uint8_t data;
} AEAT9922_Writing_t;

/* USER CODE END TD */

#endif /* INC_AEAT9922_DATASTRUCTURES_H_ */
