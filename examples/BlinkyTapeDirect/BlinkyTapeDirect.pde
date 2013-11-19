// This is a test to show the performace of RXTX/Processing Serial

import processing.serial.*;

BlinkyTape bt = null;

void setup() {
  frameRate(60);
  size(5,60);
  
  // auto connect to all blinkyboards
  for(String p : Serial.list()) {
    if (p.startsWith("/dev/tty.usbmodem")) {
      bt = new BlinkyTape(this, p, 60);
    }
  }
}

int frame = 0;
float frameRateSum = 0;

float phase = 0;

void draw() {
  if(bt != null) {
    for(int i = 0; i < 60; i++) {      
      color c = color((sin(phase*.9         +i*.2)+1)*128,
                      (sin(phase     + PI/2 +i*.2)+1)*128,
                      (sin(phase*1.1 + PI   +i*.2)+1)*128);
      bt.pushPixel(c);
    }
    bt.update();
    phase += .1;
  }
  
  
  frame += 1;
  frameRateSum += frameRate;  
  if(frame == 30) {
    println(frameRateSum/30);
    frameRateSum = 0;
    frame = 0;
  }
}

