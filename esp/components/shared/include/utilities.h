#ifndef UTILITIES_H // Include guard to prevent multiple inclusions
#define UTILITIES_H

#include "cJSON.h"

#define TEMPERATURE_RESOLUTION 0.0625

cJSON* cJSON_create_formatted_string(const char* format, ...);
float temp_to_float(uint32_t value);

#endif // UTILITIES_H
