import processing.serial.*;
import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput audioin;

FFT leftFft;
FFT rightFft;

ControlP5 controlP5;

float Sensitivity = 10;  // amplification value
float Smoothing = 1;     // how fast things die off
float colorSpeed = .05;  // How much the colors flicker


ArrayList<BlinkyTape> bts = new ArrayList<BlinkyTape>();

float colorAngle = 0;
int numberOfLEDs = 60;

// A bunch of dynamic pulsers
ArrayList<Pulser> leftPulsers = new ArrayList<Pulser>();
ArrayList<Pulser> rightPulsers = new ArrayList<Pulser>();

Burst burst;

DiscoPartyParticle logo;

SerialSelector s;

void setup()
{
  frameRate(30);
  size(400, 250, P2D);
  
  minim = new Minim(this);
  audioin = minim.getLineIn(Minim.STEREO, 2048);

  leftFft = new FFT(audioin.bufferSize(), audioin.sampleRate());
  leftFft.logAverages(10,1);
  
  rightFft = new FFT(audioin.bufferSize(), audioin.sampleRate());
  rightFft.logAverages(10,1);

  for (int i = 0; i < leftFft.avgSize(); i++) {
    Pulser p = new Pulser();
    p.m_band = i;
    
    if(random(0,1) > .5) {
      p.m_h = 87 + i;
      p.m_s = 100;
      p.m_yv = random(.2,2);
    }
    else {
      p.m_h = 52 + i;
      p.m_s = 100;
      p.m_yv = random(-.2,-2);
    }
    
    p.m_xv = 0;

    leftPulsers.add(p);
  }

  for (int i = 0; i < rightFft.avgSize(); i++) {
    Pulser p = new Pulser();
    p.m_band = i;
    
    if(random(0,1) > .5) {
      p.m_h = 87 + i;
      p.m_s = 100;
      p.m_yv = random(.2,2);
    }
    else {
      p.m_h = 52 + i;
      p.m_s = 100;
      p.m_yv = random(-.2,-2);
    }
    
    p.m_xv = 0;

    rightPulsers.add(p);
  }

  controlP5 = new ControlP5(this);

  controlP5.Slider slider = controlP5.addSlider("Sensitivity")
    .setPosition(40,230)
    .setSize(100,15)
    .setRange(1, 100)
    .setValue(10)
    .setId(1);  
  slider.getValueLabel()
      .align(ControlP5.RIGHT,ControlP5.CENTER);
  slider.getCaptionLabel()
      .align(ControlP5.LEFT,ControlP5.CENTER);
      
  slider = controlP5.addSlider("Smoothing")
    .setPosition(150,230)
    .setSize(100,15)
    .setRange(1, 20)
    .setValue(1)
    .setId(1);  
  slider.getValueLabel()
      .align(ControlP5.RIGHT,ControlP5.CENTER);
  slider.getCaptionLabel()
      .align(ControlP5.LEFT,ControlP5.CENTER);
      
  slider = controlP5.addSlider("colorSpeed")
    .setPosition(260,230)
    .setSize(100,15)
    .setRange(.001, .1)
    .setValue(.05)
    .setId(1);  
  slider.getValueLabel()
      .align(ControlP5.RIGHT,ControlP5.CENTER);
  slider.getCaptionLabel()
      .align(ControlP5.LEFT,ControlP5.CENTER);
      

  s = new SerialSelector();
  logo = new DiscoPartyParticle();
  
  burst = new Burst();
}

void draw()
{
  rightFft.forward(audioin.mix);
  leftFft.forward(audioin.mix);
  
  background(0);
  
  logo.draw();

  // Cover the logo up under where the BlinkyTapes are drawn,
  // so they don't pick up the white flashes.
  for(int i = 0; i < bts.size(); i++) {
    float pos = 15 + 15*i;
    
    stroke(0);
    line(pos, 0, pos, height);
  }

  for(Pulser p : leftPulsers) {
    p.draw(leftFft);
  }

  for(Pulser p : rightPulsers) {
    p.draw(rightFft);
  }
  
  for(int i = 0; i < bts.size(); i++) {
    float pos = 15 + 15*i;
    bts.get(i).render(pos, 0, pos, height);
    bts.get(i).update();
    
    stroke(255,100);
    line(pos, 0, pos, height);
  }
  
  colorAngle += colorSpeed;
  
  if(s != null && s.m_chosen) {
    s.m_chosen = false;
    bts.add(new BlinkyTape(this, s.m_port, numberOfLEDs));
    s = null;
  }
}
