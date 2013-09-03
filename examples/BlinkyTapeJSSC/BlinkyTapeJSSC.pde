// This is an attempt to replace the RXTX/Processing Serial library with the
// java simple serial controller library:
// https://github.com/scream3r/java-simple-serial-connector


int numberOfLEDs = 60;
ArrayList<LedOutput> leds = new ArrayList<LedOutput>();

void setup() {
  size(5,60);

  // auto connect to all blinkyboards
  for (String p : listPorts()) {
    if (p.startsWith("/dev/tty.usbmodem")) {
      LedOutput output = new LedOutput(this, p, numberOfLEDs);
      //output.start();
      leds.add(output);
    }
  }
  println("done setting up");
  delay(2000);
}

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
}

