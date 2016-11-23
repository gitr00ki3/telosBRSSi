#ifndef RSSIHEADER_H
#define RSSIHEADER_H

typedef nx_struct RssiMsg{
  nx_int16_t nodeid;
  nx_int16_t msgid;
} RssiMsg;

typedef nx_struct BsMsg{
  nx_int16_t maxMsg;
  nx_int8_t maxPower;
} BsMsg;

enum {
  MAX_COUNTER = 100,
  MAX_BASE_COUNTER = 10,
  TIMER = 500,
  TIMER_OFFSET = 10000,
  AM_RSSIMSG = 10,
  AM_BSMSG = 11,
  MAX_POWER = 31,
  MIN_POWER_COUNTER = 1
};

#endif
