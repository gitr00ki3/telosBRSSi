/**
* Main code file
*/
#include "Timer.h"
#include "printf.h"
#include "RssiHeader.h"
#include <UserButton.h>

module BaseStationC {
  uses {
    interface Boot;
    interface Leds;
    interface Timer<TMilli> as Timer0;
    interface Receive;
    interface SplitControl as RadioControl;
    interface CC2420Packet;
    interface AMSend as RssiMsgSend;
    interface Packet;
    interface Notify<button_state_t>;
  }
}
implementation {

  uint16_t rssi;
  uint16_t lqi;
  uint8_t counter;
  RssiMsg* rssiMsg;
  BsMsg* bsMsg;
  message_t msg0;

  event void Boot.booted() {
    // Enable the radio
    call RadioControl.start();
  }
  
  event void RadioControl.startDone(error_t result) {
    if ( result == SUCCESS ) {
        // Light on yellow LED to indicate radio on
        call Leds.led1On();
        // Enable the button
        call Notify.enable();
        printf("Node id\tMsg no\tRSSi\tLQI\r\n");
    }
  }
  
  event void RadioControl.stopDone(error_t result){ }
  
  event void Notify.notify( button_state_t state ) {
    if ( state == BUTTON_PRESSED ) {
        // Tx message contents
        bsMsg = (BsMsg*)(call Packet.getPayload(&msg0, sizeof(BsMsg)));
        bsMsg->maxMsg = MAX_COUNTER;
        // Fetching transmissin power of the packet (0-31) {1=-25dBm 31= 0dBm}
        bsMsg->maxPower = MAX_POWER;
        // Start timer to send message
        counter = 0;
        call Timer0.startPeriodic(TIMER);
    }
  }
  
  event void Timer0.fired() {
    if (++counter>MAX_BASE_COUNTER && (call Timer0.isRunning())==TRUE) {
        // After sending max messages, program should stop
        call Timer0.stop();
    } else {
        // Light on blue LED to indicate Tx message
        call Leds.led2On();
        // Tx the message
        call RssiMsgSend.send(AM_BROADCAST_ADDR, &msg0, sizeof(BsMsg));
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(RssiMsg)) {
      call Leds.led2Toggle();
      // Fetching raw RSSi power (rssi+(-45))dBm
      rssi = ((uint16_t) call CC2420Packet.getRssi(msg));
      // Fetching link quality index (0-255)
      lqi = ((uint16_t) call CC2420Packet.getLqi(msg));
      rssiMsg = (RssiMsg*)payload;
      printf("%d\t%d\t%d\t%d\r\n", rssiMsg->nodeid, rssiMsg->msgid, rssi, lqi);
      printfflush();
    } else {
        call Leds.led0Toggle();
    }
    return msg;
  }
  
  event void RssiMsgSend.sendDone(message_t *m, error_t error){
    if ( error == SUCCESS ) {
        // Light off blue LED to indicate message sent
        call Leds.led2Off();
    }
  }

}
