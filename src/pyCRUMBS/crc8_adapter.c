#include "crc8_nibble.h"

#include <stddef.h>
#include <stdint.h>

uint8_t crc_calculate(const uint8_t *data, size_t length)
{
    if (data == NULL || length == 0)
    {
        return crc_finalize(crc_init());
    }

    crc_t crc = crc_init();
    crc = crc_update(crc, data, length);
    return (uint8_t)crc_finalize(crc);
}
