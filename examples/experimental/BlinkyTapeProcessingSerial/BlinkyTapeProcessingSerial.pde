// This is a test to show the performace of RXTX/Processing Serial

import processing.serial.*;

int numberOfLEDs = 60;
ArrayList<LedOutput> leds = new ArrayList<LedOutput>();

void setup() {
  frameRate(60);
  size(5,60);
  
  // auto connect to all blinkyboards
  for(String p : Serial.list()) {
    if (p.startsWith("/dev/tty.usbmodem")) {
      LedOutput output = new LedOutput(this, p, numberOfLEDs);
      //output.start();
      leds.add(output);
    }
  }
  println("done setting up");
}

int frame = 0;
float frameRateSum = 0;

float phase = 0;
void draw() {
 strokeWeight(1);
  for(int i = 0; i < displayHeight; i++) {
   stroke(color((sin(phase*.9         +i*.2)+1)*128,
                (sin(phase     + PI/2 +i*.2)+1)*128,
                (sin(phase*1.1 + PI   +i*.2)+1)*128));
   line(0,i,displayWidth, i); 
  }
  phase += .1;
  
  stroke(color(0));
  for(int i = 0; i < displayHeight; i++) {
   if(i%3 != 0) {
     line(0,i,displayWidth, i);
   }
  }
  
  // Update the displays
  for (int i = 0; i < leds.size(); i++) {
    leds.get(i).sendUpdate(i, height-1, i, 0);
  }
  
  // Then send the data
  for (int i = 0; i < leds.size(); i++) {
    leds.get(i).startSend();
  }
  
  boolean sending = true;
  while(sending) {
    sending = false;
    
    for (int i = 0; i < leds.size(); i++) {
      if(leds.get(i).sendNextChunk()) {
        sending = true;
      }
    }
//    delay(1);
  }
  
  frame += 1;
  frameRateSum += frameRate;  
  if(frame == 30) {
    println(frameRateSum/30);
    frameRateSum = 0;
    frame = 0;
  }
}

