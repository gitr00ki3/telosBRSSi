/**
* Configuration file for declearing components like
* Button
* LED
* Main
*/

configuration RssiTxAppC {}
implementation {

  components RssiTxC as App;    // Main file name

  components MainC;
  App.Boot -> MainC; // Point of execution
  
  components LedsC;
  App.Leds -> LedsC; // To alter the 3 available LEDs
  
  components new TimerMilliC() as Timer0;
  App.Timer0 -> Timer0;  // Timer function invoke
  
  components ActiveMessageC;
  App.RadioControl -> ActiveMessageC;    // Enable/Disable radio
  
  components new AMSenderC(AM_RSSIMSG) as RssiMsgSender;
  App.RssiMsgSend -> RssiMsgSender;  // Tx message
  App.Packet -> RssiMsgSender;   // To modify the packet contents
  
  components new AMReceiverC(AM_BSMSG);   // Rx
  App.Receive -> AMReceiverC;
  
  components CC2420ActiveMessageC;
  App -> CC2420ActiveMessageC.CC2420Packet;  // To get RSSi value

}
