#ifndef SNTP_H
#define SNTP_H

#define SNTP_MAX_SYNC_RETRIES 15
#define SNTP_TZ "EET-2EEST,M3.5.0/3,M10.5.0/4"

void initialize_sntp(void);

#endif