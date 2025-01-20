/*
 * timer_delay.c
 *
 *  Created on: Jun 22, 2020
 *      Author: Khaled Magdy
 */

#include "utils/timer_delay.h"

void delay_us(TIM_HandleTypeDef HTIMx, volatile uint16_t au16_us)
{
  HTIMx.Instance->CNT = 0;
  while (HTIMx.Instance->CNT < au16_us)
    ;
}

void delay_ms(TIM_HandleTypeDef HTIMx, volatile uint16_t au16_ms)
{
  while (au16_ms > 0)
  {
    HTIMx.Instance->CNT = 0;
    au16_ms--;
    while (HTIMx.Instance->CNT < 1000)
      ;
  }
}
