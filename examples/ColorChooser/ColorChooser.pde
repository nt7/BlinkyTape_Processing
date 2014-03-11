import controlP5.*;
import processing.serial.*;

ArrayList<BlinkyTape> leds = new ArrayList<BlinkyTape>();

ControlP5 controlP5;
ColorPicker cp;

int numberOfLEDs = 60;

void setup()
{
  frameRate(30);
  size(220, 255);
  
  cp = new ColorPicker( 10, 10, 200, 200, 255 );

  // auto connect to all blinkyboards
  for(String p : Serial.list()) {
    if(p.startsWith("/dev/cu.usbmodem")) {
      leds.add(new BlinkyTape(this, p, numberOfLEDs));
    }
  }
}

float bright = 0;

void draw()
{ 
 background(127);

  cp.render();

  for(int i = 0; i < leds.size(); i++) {
    leds.get(i).render(20, 235, 100, 235);
    leds.get(i).send();
  }
}

