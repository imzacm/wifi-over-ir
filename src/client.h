#ifndef WOI_CLIENT_H
#define WOI_CLIENT_H

#include <stdint.h>

#include <woi/result.h>

typedef uint16_t ClientID;

typedef struct {
    ClientID device_id;
    const char *device_name;
} ClientConfig;

WOI_Result ClientConfig_read(ClientConfig *config);

WOI_Result ClientConfig_write(const ClientConfig *config);

#endif
