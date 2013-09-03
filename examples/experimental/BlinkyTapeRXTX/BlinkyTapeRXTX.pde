// This is an attempt to replace the RXTX/Processing Serial library with a
// straight implementation of the RXTX library.

int numberOfLEDs = 60;
ArrayList<LedOutput> leds = new ArrayList<LedOutput>();

void setup() {
  size(5,60);

  // auto connect to all blinkyboards
  for (String p : listPorts()) {
    if (p.startsWith("/dev/cu.usbmodem")) {
      println("Connecting to port " + p);
      leds.add(new LedOutput(this, p, numberOfLEDs));
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
   stroke(color((sin(phase*.5         +i*.2)+1)*128,
                (sin(phase     + PI/2 +i*.2)+1)*128,
                (sin(phase*1.2 + PI   +i*.2)+1)*128));
   line(0,i,displayWidth, i); 
  }
  phase += .2;
  
  stroke(color(0));
  for(int i = 0; i < displayHeight; i++) {
   if(i%3 != 0) {
     line(0,i,displayWidth, i);
   }
  }
  
  for (int i = 0; i < leds.size(); i++) {
    leds.get(i).sendUpdate(i, height-1, i, 0);
  }
  
  frame += 1;
  frameRateSum += frameRate;  
  if(frame == 30) {
    println(frameRateSum/30);
    frameRateSum = 0;
    frame = 0;
  }
}


