#include <stdio.h>
#include "utils.h"
#include <stdint.h>
#include "string.h"
#include "AEAT9922/AEAT9922.h"

/* Private defines */
#define ENCODER_RESOLUTION_BITS 18
#define ENCODER_MAX_COUNTS      (1UL << ENCODER_RESOLUTION_BITS)  // 2^18
#define DEGREES_PER_COUNT       (360.0f / ENCODER_MAX_COUNTS)

/* External SPI handles */
extern SPI_HandleTypeDef hspi2;
extern SPI_HandleTypeDef hspi3;
extern UART_HandleTypeDef hlpuart1; // For debug output
/**
 * @brief  Reads one byte from a specific register using the SPI-4(A) protocol.
 * @note   This function executes the two-transaction read sequence
 * required by the AEAT-9922's pipelined SPI protocol.
 * @param  reg_addr The 8-bit address of the register to read from.
 * @param  read_data Pointer to a variable where the read data will be stored.
 * @retval HAL_StatusTypeDef The status of the HAL SPI operation.
 */
HAL_StatusTypeDef AEAT9922_Read_SPI4A(uint8_t reg_addr, uint8_t *read_data) {

    uint8_t tx_buf[SPI4A_CMD_SIZE];
    uint8_t rx_buf[SPI4A_CMD_SIZE];
    HAL_StatusTypeDef status;

    // --- Transaction 1: Send Read Command for reg_addr ---
    // Master sends frame: [P | RW=1 | 000000 | Addr[7:0]]
    // The data received in rx_buf during this transaction is discarded.
    uint16_t command = (1 << 14) | reg_addr; // RW bit is 1 for read
    uint8_t parity = calculate_even_parity(command);
    uint16_t frame = (parity << 15) | command;

    tx_buf[0] = (uint8_t) (frame >> 8);   // MSB
    tx_buf[1] = (uint8_t) (frame & 0xFF); // LSB

    HAL_GPIO_WritePin(ENCODER_NSS_PORT, ENCODER_NSS_PIN, GPIO_PIN_RESET);
    status = HAL_SPI_TransmitReceive(&hspi2, tx_buf, rx_buf, SPI4A_CMD_SIZE, SPI_TIMEOUT_MS);
    HAL_GPIO_WritePin(ENCODER_NSS_PORT, ENCODER_NSS_PIN, GPIO_PIN_SET);

    if (status != HAL_OK) {
        return status;
    }

    // A brief delay between transactions is required to meet tCSn (min 350ns).
    // The overhead of the GPIO toggles and the next lines of code
    // is almost certainly longer than 350ns, so an explicit delay is not needed.

    HAL_Delay(1);

    uint16_t dummy_command = (1 << 14) | 0x00; // RW=1, Addr=0x00
    uint8_t dummy_parity = calculate_even_parity(dummy_command);
    uint16_t dummy_frame = (dummy_parity << 15) | dummy_command;

    tx_buf[0] = (uint8_t) (dummy_frame >> 8);   // MSB
    tx_buf[1] = (uint8_t) (dummy_frame & 0xFF); // LSB

    HAL_GPIO_WritePin(ENCODER_NSS_PORT, ENCODER_NSS_PIN, GPIO_PIN_RESET);
    status = HAL_SPI_TransmitReceive(&hspi2, tx_buf, rx_buf, SPI4A_CMD_SIZE, SPI_TIMEOUT_MS);
    HAL_GPIO_WritePin(ENCODER_NSS_PORT, ENCODER_NSS_PIN, GPIO_PIN_SET);

    if (status == HAL_OK) {
        // Slave responds with frame: [P | EF | 000000 | Data[7:0]]
        *read_data = rx_buf[1];
    }

    return status;
}

/**
 * @brief  Writes one byte to a specific register using the SPI-4(A) protocol.
 * @note   This function executes the continuous 4-byte write sequence.
 * @param  reg_addr The 8-bit address of the register to write to.
 * @param  data_to_write The 8-bit data to write.
 * @retval HAL_StatusTypeDef The status of the HAL SPI operation.
 */
HAL_StatusTypeDef AEAT9922_Write_SPI4A(uint8_t reg_addr, uint8_t data_to_write) {
    HAL_StatusTypeDef status;
    uint8_t tx_buf[4];
    uint8_t rx_buf[4];

    // --- Frame 1: Send Register Address ---
    // Frame: [P | RW=0 | 000000 | Addr[7:0]]
    uint16_t command_addr = (0 << 14) | reg_addr; // RW bit is 0 for write
    uint8_t parity_addr = calculate_even_parity(command_addr);
    uint16_t frame_addr = (parity_addr << 15) | command_addr;

    tx_buf[0] = (uint8_t) (frame_addr >> 8);   // MSB
    tx_buf[1] = (uint8_t) (frame_addr & 0xFF); // LSB

    // --- Frame 2: Send Data ---
    // Frame: [P | RW=0 | 000000 | Data[7:0]]
    uint16_t command_data = (0 << 14) | data_to_write;
    uint8_t parity_data = calculate_even_parity(command_data);
    uint16_t frame_data = (parity_data << 15) | command_data;

    tx_buf[2] = (uint8_t) (frame_data >> 8);   // MSB
    tx_buf[3] = (uint8_t) (frame_data & 0xFF); // LSB

    // --- Execute as one continuous 4-byte transaction ---
    HAL_GPIO_WritePin(ENCODER_NSS_PORT, ENCODER_NSS_PIN, GPIO_PIN_RESET);
    status = HAL_SPI_TransmitReceive(&hspi2, tx_buf, rx_buf, 4, SPI_TIMEOUT_MS);
    HAL_GPIO_WritePin(ENCODER_NSS_PORT, ENCODER_NSS_PIN, GPIO_PIN_SET);

    return status;
}

/**
 * @brief  Reads the absolute position using the SPI-4(A) protocol.
 * @note   This function implements the correct two-transaction pipelined read.
 * @param  reading Pointer to the data structure where results will be stored.
 * @retval HAL_StatusTypeDef The status of the SPI communication.
 */
HAL_StatusTypeDef AEAT9922_ReadPosition_SPI4A(AEAT9922_Reading_t *reading) {

    uint8_t tx_buf[3];
    uint8_t rx_buf[3];
    uint32_t received_frame;
    HAL_StatusTypeDef status;

    // Master sends 16-bit frame: [P | RW=1 | 000000 | 0x3F]
    uint16_t frame_data = (1 << 14) | ENCODER_READ_COMMAND;
    uint8_t parity = calculate_even_parity(frame_data);
    uint16_t command = (parity << 15) | frame_data;

    tx_buf[0] = (uint8_t) (command >> 8);
    tx_buf[1] = (uint8_t) (command & 0xFF);
    tx_buf[2] = 0x00; // Dummy byte for 3-byte read

    // --- Transaction 1: Send Read Command (0x3F) ---
    // Sends the 2-byte command and discards the 2-byte response (stale data)
    HAL_GPIO_WritePin(ENCODER_NSS_PORT, ENCODER_NSS_PIN, GPIO_PIN_RESET);
    status = HAL_SPI_TransmitReceive(&hspi2, tx_buf, rx_buf, 2, SPI_TIMEOUT_MS);
    HAL_GPIO_WritePin(ENCODER_NSS_PORT, ENCODER_NSS_PIN, GPIO_PIN_SET);

    if (status != HAL_OK) { return status; }

    // Brief delay to meet tCSn (min 350ns). A 1ms delay is three times more.
    HAL_Delay(1);

    // --- Transaction 2: Send Dummy Command, Receive Position Data ---
    // We send 3 dummy bytes (or the command again) to clock out the 20-bit response.
    // The response is 20 bits, so we must read 3 bytes (24 bits) to get it all.
    HAL_GPIO_WritePin(ENCODER_NSS_PORT, ENCODER_NSS_PIN, GPIO_PIN_RESET);
    status = HAL_SPI_TransmitReceive(&hspi2, tx_buf, rx_buf, 3, SPI_TIMEOUT_MS);
    HAL_GPIO_WritePin(ENCODER_NSS_PORT, ENCODER_NSS_PIN, GPIO_PIN_SET);

    if (status != HAL_OK) { return status; }

    // --- Process the 3-byte response ---
    // Slave responds with 20-bit frame: [P | EF | Pos[17:0]]
    // We shift right by 4 bits to align the 20-bit frame from the 24 bits received.
    received_frame = ((uint32_t) rx_buf[0] << 16) | ((uint32_t) rx_buf[1] << 8) | ((uint32_t) rx_buf[2]);
    reading->raw_frame = received_frame >> 4; // Align 20-bit frame

    // Sectioning the received data-frame
    uint8_t received_parity = (reading->raw_frame >> 19) & 0x01;
    reading->is_error = (reading->raw_frame >> 18) & 0x01;
    reading->position = reading->raw_frame & POSITION_DATA_MASK; // 0x3FFFF

    // Parity check
    uint32_t data_for_parity_check = reading->raw_frame & 0x7FFFF; // Mask for 19 bits [EF + Pos(17:0)]
    uint8_t calculated_parity = 0;
    for (int i = 0; i < 19; i++) {
        calculated_parity ^= (data_for_parity_check >> i) & 1;
    }
    reading->crc_ok = (received_parity == calculated_parity); // Even parity

    reading->angle_degrees = (float) reading->position * DEGREES_PER_COUNT;

    return HAL_OK;
}
