/**
* Configuration file for declearing components like
* Button
* LED
* Main
*/
#define NEW_PRINTF_SEMANTICS

configuration BaseStationAppC {}
implementation {

  components BaseStationC as App;    // Main file name

  components MainC;
  App.Boot -> MainC; // Point of execution

  components LedsC;
  App.Leds -> LedsC; // To alter the 3 available LEDs
  
  components new TimerMilliC() as Timer0;
  App.Timer0 -> Timer0;  // Timer function invoke

  components ActiveMessageC;
  App.RadioControl -> ActiveMessageC;    // Enable/Disable radio
  
  components new AMReceiverC(AM_RSSIMSG);   // Rx
  App.Receive -> AMReceiverC;
  
  components CC2420ActiveMessageC;
  App -> CC2420ActiveMessageC.CC2420Packet;  // To get RSSi value
  
  components PrintfC, SerialStartC; // To use printf
  
  components new AMSenderC(AM_BSMSG) as RssiMsgSender;
  App.RssiMsgSend -> RssiMsgSender;  // Tx message
  App.Packet -> RssiMsgSender;   // To modify the packet contents
  
  components UserButtonC;
  App.Notify -> UserButtonC;

}
