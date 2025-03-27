#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h> 
#include "cJSON.h"
#include "utilities.h"

cJSON* cJSON_create_formatted_string(const char* format, ...) {
    va_list args;
    va_start(args, format);

    // Determine the required buffer size
    int buffer_size = vsnprintf(NULL, 0, format, args);
    va_end(args);

    if (buffer_size <= 0) {
        // Handle error: invalid format string
        return NULL;
    }

    // Allocate memory for the formatted string
    char* formatted_string = (char*)malloc(buffer_size + 1); // +1 for null terminator
    if (formatted_string == NULL) {
        // Handle memory allocation failure
        return NULL;
    }

    // Format the string
    va_start(args, format);
    vsnprintf(formatted_string, buffer_size + 1, format, args);
    va_end(args);

    // Create cJSON string
    cJSON* result = cJSON_CreateString(formatted_string); 

    // Free the allocated memory
    free(formatted_string);

    return result;
}

float temp_to_float(int32_t value) {
    return value * TEMPERATURE_RESOLUTION;
}

int32_t temp_to_int(float value) {
    return value / TEMPERATURE_RESOLUTION;
}