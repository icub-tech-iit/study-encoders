/*
 * utils.c
 *
 *  Created on: Oct 15, 2025
 *      Author: aviscomi
 */

#include "utils.h"

uint8_t calculate_even_parity(uint16_t val)
{
    uint8_t parity = 0;
    for (int i = 0; i < 15; i++)
    {
        parity ^= (val >> i) & 0x01;
    }
    return parity;
}
