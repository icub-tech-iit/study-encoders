/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "AEAT9922/AEAT9922.h"
#include <stdio.h>
#include <string.h>

/* Private variables ---------------------------------------------------------*/
UART_HandleTypeDef hlpuart1;
SPI_HandleTypeDef hspi2;
SPI_HandleTypeDef hspi3;

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_LPUART1_UART_Init(void);
static void MX_SPI2_Init(void);

#define pos

/**
 * @brief  The application entry point.
 * @retval int
 */
int main(void)
{
	/* MCU Configuration--------------------------------------------------------*/
	HAL_Init();
	SystemClock_Config();
	MX_GPIO_Init();
	MX_LPUART1_UART_Init();
	MX_SPI2_Init();

	char buf[200];

	AEAT9922_Reading_t reading_data;

	HAL_UART_Transmit(&hlpuart1, (uint8_t*)("AEAT-9922\r\n"), 12, HAL_MAX_DELAY);

#ifdef config

	AEAT9922_Write_SPI4A(0x10, UNLOCK); // Unlocks shadow registers.
	HAL_Delay(1);

	AEAT9922_Write_SPI4A(0x0B, 0x20); //Sets SPI-4(B) (actually this is the only register I cannot write on!!!)
	HAL_Delay(1);

	AEAT9922_Write_SPI4A(0x11, PROGRAM); // Ends the config. phase.
	HAL_Delay(45);

	HAL_UART_Transmit(&hlpuart1, (uint8_t*)("Restart the board\r\n"), 25, HAL_MAX_DELAY);

#endif

#ifdef regs

		// checks for some useful register values

		uint8_t unlock_register_val;
		uint8_t protocol_register_val;

		uint8_t register7_val;
		uint8_t register8_val;

		uint8_t status_register_val;

		AEAT9922_Read_SPI4A(0x10, &unlock_register_val);

		AEAT9922_Read_SPI4A(0x0B, &protocol_register_val);

		AEAT9922_Read_SPI4A(0x07, &register7_val);

		AEAT9922_Read_SPI4A(0x08, &register8_val);

		AEAT9922_Read_SPI4A(0x21, &status_register_val);

		sprintf(buf, "Read from Reg 0x%02X: Value = 0x%02X\r\n", 0x10, unlock_register_val);
		HAL_UART_Transmit(&hlpuart1, (uint8_t*)buf, strlen(buf), HAL_MAX_DELAY);

		sprintf(buf, "Read from Reg 0x%02X: Value = 0x%02X\r\n", 0x08, register8_val);
		HAL_UART_Transmit(&hlpuart1, (uint8_t*)buf, strlen(buf), HAL_MAX_DELAY);

		sprintf(buf, "Read from Reg 0x%02X: Value = 0x%02X\r\n", 0x07, register7_val);
		HAL_UART_Transmit(&hlpuart1, (uint8_t*)buf, strlen(buf), HAL_MAX_DELAY);

		sprintf(buf, "Read from Reg 0x%02X: Value = 0x%02X\r\n", 0x0B, protocol_register_val);
		HAL_UART_Transmit(&hlpuart1, (uint8_t*)buf, strlen(buf), HAL_MAX_DELAY);

		sprintf(buf, "Read from Reg 0x%02X: Value = 0x%02X\r\n", 0x21, status_register_val);
		HAL_UART_Transmit(&hlpuart1, (uint8_t*)buf, strlen(buf), HAL_MAX_DELAY);
#endif

	#ifdef pos

		while (1)
		{
			AEAT9922_ReadPosition_SPI4A(&reading_data); // See AEAT9922.c
			sprintf(buf, "Pos: %6lu | Angle: %7.2f° | Parity: %s |\r\n",
					(unsigned long)reading_data.position,
					reading_data.angle_degrees,
					reading_data.crc_ok ? "OK" : "FAIL");

			HAL_UART_Transmit(&hlpuart1, (uint8_t*)buf, strlen(buf), HAL_MAX_DELAY);

			HAL_Delay(250); // Loop delay for readability.
		}

	#endif

}

void SystemClock_Config(void)
{
	RCC_OscInitTypeDef RCC_OscInitStruct = {0};
	RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

	HAL_PWREx_ControlVoltageScaling(PWR_REGULATOR_VOLTAGE_SCALE1_BOOST);

	RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
	RCC_OscInitStruct.HSIState = RCC_HSI_ON;
	RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
	RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
	RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
	RCC_OscInitStruct.PLL.PLLM = RCC_PLLM_DIV4;
	RCC_OscInitStruct.PLL.PLLN = 85;
	RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
	RCC_OscInitStruct.PLL.PLLQ = RCC_PLLQ_DIV2;
	RCC_OscInitStruct.PLL.PLLR = RCC_PLLR_DIV2;

	if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK) {
		Error_Handler();
	}

	RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
			|RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
	RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
	RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
	RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
	RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

	if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_4) != HAL_OK) {
		Error_Handler();
	}
	HAL_RCC_MCOConfig(RCC_MCO_PG10, RCC_MCO1SOURCE_HSI, RCC_MCODIV_1);
}

static void MX_LPUART1_UART_Init(void)
{
	hlpuart1.Instance = LPUART1;
	hlpuart1.Init.BaudRate = 115200;
	hlpuart1.Init.WordLength = UART_WORDLENGTH_8B;
	hlpuart1.Init.StopBits = UART_STOPBITS_1;
	hlpuart1.Init.Parity = UART_PARITY_NONE;
	hlpuart1.Init.Mode = UART_MODE_TX_RX;
	hlpuart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
	hlpuart1.Init.OneBitSampling = UART_ONE_BIT_SAMPLE_DISABLE;
	hlpuart1.Init.ClockPrescaler = UART_PRESCALER_DIV1;
	hlpuart1.AdvancedInit.AdvFeatureInit = UART_ADVFEATURE_NO_INIT;

	if (HAL_UART_Init(&hlpuart1) != HAL_OK) {
		Error_Handler();
	}
	if (HAL_UARTEx_SetTxFifoThreshold(&hlpuart1, UART_TXFIFO_THRESHOLD_1_8) != HAL_OK) {
		Error_Handler();
	}
	if (HAL_UARTEx_SetRxFifoThreshold(&hlpuart1, UART_RXFIFO_THRESHOLD_1_8) != HAL_OK) {
		Error_Handler();
	}
	if (HAL_UARTEx_DisableFifoMode(&hlpuart1) != HAL_OK) {
		Error_Handler();
	}
}

static void MX_SPI2_Init(void)
{
	hspi2.Instance = SPI2;
	hspi2.Init.Mode = SPI_MODE_MASTER;
	hspi2.Init.Direction = SPI_DIRECTION_2LINES;
	hspi2.Init.DataSize = SPI_DATASIZE_8BIT;
	hspi2.Init.CLKPolarity = SPI_POLARITY_LOW;
	hspi2.Init.CLKPhase = SPI_PHASE_2EDGE;
	hspi2.Init.NSS = SPI_NSS_SOFT;
	hspi2.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_256;
	hspi2.Init.FirstBit = SPI_FIRSTBIT_MSB;
	hspi2.Init.TIMode = SPI_TIMODE_DISABLE;
	hspi2.Init.CRCCalculation = SPI_CRCCALCULATION_DISABLE;
	hspi2.Init.CRCPolynomial = 7;
	hspi2.Init.CRCLength = SPI_CRC_LENGTH_DATASIZE;
	hspi2.Init.NSSPMode = SPI_NSS_PULSE_DISABLE;

	if (HAL_SPI_Init(&hspi2) != HAL_OK) {
		Error_Handler();
	}
}

static void MX_GPIO_Init(void)
{
	GPIO_InitTypeDef GPIO_InitStruct = {0};

	__HAL_RCC_GPIOC_CLK_ENABLE();
	__HAL_RCC_GPIOF_CLK_ENABLE();
	__HAL_RCC_GPIOG_CLK_ENABLE();
	__HAL_RCC_GPIOA_CLK_ENABLE();
	__HAL_RCC_GPIOB_CLK_ENABLE();

	HAL_GPIO_WritePin(ENCODER_NSS_PORT, ENCODER_NSS_PIN, GPIO_PIN_SET);
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_RESET);  // LD2

	GPIO_InitStruct.Pin = GPIO_PIN_13;  // B1
	GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

	GPIO_InitStruct.Pin = GPIO_PIN_10;
	GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	GPIO_InitStruct.Alternate = GPIO_AF0_MCO;
	HAL_GPIO_Init(GPIOG, &GPIO_InitStruct);

	GPIO_InitStruct.Pin = ENCODER_NSS_PIN | GPIO_PIN_5;  // NSS and LD2
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

	HAL_NVIC_SetPriority(EXTI15_10_IRQn, 0, 0);
	HAL_NVIC_EnableIRQ(EXTI15_10_IRQn);
}

void Error_Handler(void)
{
	__disable_irq();
	while (1) {
	}
}
