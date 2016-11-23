/**
* Main code file
*/
#include "Timer.h"
#include "RssiHeader.h"

module RssiTxC {
  uses {
    interface Boot;
    interface Leds;
    interface Timer<TMilli> as Timer0;
    interface AMSend as RssiMsgSend;
    interface SplitControl as RadioControl;
    interface Packet;
    interface Receive;
    interface CC2420Packet;
  }
}
implementation {
  message_t msg;
  BsMsg* bsMsg;
  uint16_t maxCounter = MAX_COUNTER;
  uint8_t txPower = MAX_POWER;
  uint8_t counter = 0;

  event void Boot.booted() {
    // Enable the radio
    call RadioControl.start();
  }
  
    event void RadioControl.startDone(error_t result) {
    if ( result == SUCCESS ) {
        // Light on yellow LED to indicate radio on
        call Leds.led1On();
    }
  }
  
  event void RadioControl.stopDone(error_t result){ }
  
  event message_t* Receive.receive(message_t* msg0, void* payload, uint8_t len){
    // Once message is received from base, wait for TIMER_OFFSET and then send message at every TIMER interval
    if (len == sizeof(BsMsg) && (call Timer0.isRunning())==FALSE) {
        call Leds.led2Toggle();
        bsMsg = (BsMsg*)payload;
        maxCounter = bsMsg->maxMsg<MIN_POWER_COUNTER?MIN_POWER_COUNTER:bsMsg->maxMsg;
        txPower = bsMsg->maxPower<MIN_POWER_COUNTER?MIN_POWER_COUNTER:bsMsg->maxPower;
        call Timer0.startPeriodic(TIMER);
    } else {
        call Leds.led0Toggle();
    }
    return msg0;
  }

  event void Timer0.fired()
  {
    if (++counter>=maxCounter && (call Timer0.isRunning())==TRUE) {
        // After sending max messages, program should stop
        call Timer0.stop();
        counter = 0;
    } else {
        // Tx message contents
        RssiMsg* rssiMsg = (RssiMsg*)(call Packet.getPayload(&msg, sizeof(RssiMsg)));
        rssiMsg->nodeid = TOS_NODE_ID;
        rssiMsg->msgid = counter;
        call CC2420Packet.setPower(&msg, txPower);
        // Light on blue LED to indicate Tx message
        call Leds.led2On();
        call RssiMsgSend.send(AM_BROADCAST_ADDR, &msg, sizeof(RssiMsg));    // Tx the message
    }
  }
  
  event void RssiMsgSend.sendDone(message_t *m, error_t error){
    if ( error == SUCCESS ) {
        // Light off blue LED to indicate message sent
        call Leds.led2Off();
    }
  }
  
}
