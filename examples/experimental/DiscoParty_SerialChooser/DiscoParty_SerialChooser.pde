import processing.opengl.*;
import processing.serial.*;

/**
 * This sketch demonstrates how to use the BeatDetect object in FREQ_ENERGY mode.<br />
 * You can use <code>isKick</code>, <code>isSnare</code>, </code>isHat</code>, <code>isRange</code>, 
 * and <code>isOnset(int)</code> to track whatever kind of beats you are looking to track, they will report 
 * true or false based on the state of the analysis. To "tick" the analysis you must call <code>detect</code> 
 * with successive buffers of audio. You can do this inside of <code>draw</code>, but you are likely to miss some 
 * audio buffers if you do this. The sketch implements an <code>AudioListener</code> called <code>BeatListener</code> 
 * so that it can call <code>detect</code> on every buffer of audio processed by the system without repeating a buffer 
 * or missing one.
 * <p>
 * This sketch plays an entire song so it may be a little slow to load.
 */

import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
AudioInput audioin;
AudioOutput audioout;  // Need to run soundflower for this to work...

FFT leftFft;
FFT rightFft;

BeatDetect beat;

float globalVolume = 10;  // amplification value
float globalFalloff = 1;  // how fast things die off
float globalSat = 100;

float colorSpeed = .05;

ArrayList<BlinkyTape> bts = new ArrayList<BlinkyTape>();

float kickSize, snareSize, hatSize;

float colorAngle = 0;

int numberOfLEDs = 60;
int[] values;

// A bunch of dynamic pulsers
ArrayList<Pulser> leftPulsers = new ArrayList<Pulser>();
ArrayList<Pulser> rightPulsers = new ArrayList<Pulser>();

DiscoPartyParticle logo;

SerialSelector s;

void setup()
{
  frameRate(30);
  size(400, 250, OPENGL);
  
  println(this);
  minim = new Minim(this);
  audioin = minim.getLineIn(Minim.STEREO, 2048);

  // a beat detection object that is FREQ_ENERGY mode that 
  // expects buffers the length of song's buffer size
  // and samples captured at songs's sample rate
  //  beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  beat = new BeatDetect(audioin.bufferSize(), audioin.sampleRate());

  // set the sensitivity to 300 milliseconds
  // After a beat has been detected, the algorithm will wait for 300 milliseconds 
  // before allowing another beat to be reported. You can use this to dampen the 
  // algorithm if it is giving too many false-positives. The default value is 10, 
  // which is essentially no damping. If you try to set the sensitivity to a negative value, 
  // an error will be reported and it will be set to 10 instead. 
  beat.setSensitivity(100);  
  kickSize = snareSize = hatSize = 16;

  leftFft = new FFT(audioin.bufferSize(), audioin.sampleRate());
  leftFft.logAverages(10,1);
  
  rightFft = new FFT(audioin.bufferSize(), audioin.sampleRate());
  rightFft.logAverages(10,1);

  for (int i = 0; i < leftFft.avgSize(); i++) {
    Pulser p = new Pulser();
    p.m_band = i;
    
    if(random(0,1) > .5) {
      p.m_h = 87 + i;//70;
      p.m_s = globalSat;
      p.m_yv = random(.2,2);
    }
    else {
      p.m_h = 52 + i;
      p.m_s = globalSat;
      p.m_yv = random(-.2,-2);
    }
    
    p.m_xv = 0;

    leftPulsers.add(p);
  }

  for (int i = 0; i < rightFft.avgSize(); i++) {
    Pulser p = new Pulser();
    p.m_band = i;
    
    if(random(0,1) > .5) {
      p.m_h = 87 + i;//70;
      p.m_s = globalSat;
      p.m_yv = random(.2,2);
    }
    else {
      p.m_h = 52 + i;
      p.m_s = globalSat;
      p.m_yv = random(-.2,-2);
    }
    
    p.m_xv = 0;

    rightPulsers.add(p);
  }

  s = new SerialSelector();
  logo = new DiscoPartyParticle();

  textFont(createFont("Helvetica", 16));
  textAlign(CENTER);
}

float col = 0;

float backgroundAngle = 0;

float zzz = 0;

float textSize = 1;

void draw()
{
//  loadPixels();
  
//  background(color(1+cos(backgroundAngle), 
//  1+cos(backgroundAngle+6.28/3), 
//  1+cos(backgroundAngle+6.28*2/3)));
//  backgroundAngle += .01;

  background(0);

  rightFft.forward(audioin.mix);
  leftFft.forward(audioin.mix);

  color(255);
  stroke(255);
  if ( beat.isKick() ) kickSize = min(32, kickSize+1.5);
  if ( beat.isSnare() ) snareSize = min(32, snareSize+1.5);
  if ( beat.isHat() ) hatSize = 32;

  if ( beat.isKick() ) {
    for(Pulser p : rightPulsers) {
      for(int i = 0; i < random(0,3); i++) {
        p.draw(rightFft);
      }
    }
    for(Pulser p : leftPulsers) {
      for(int i = 0; i < random(0,3); i++) {
        p.draw(leftFft);
      }
    }
  }
  
  background(0);
  
  logo.draw();

  for(Pulser p : leftPulsers) {
    p.draw(leftFft);
  }

  for(Pulser p : rightPulsers) {
    p.draw(rightFft);
  }

  // Remove disconnected tapes
  for(int i = bts.size() - 1; i > -1; i--) {
     if(!bts.get(i).isConnected()) {
       bts.remove(i);
     }
  }
  
  for(int i = 0; i < bts.size(); i++) {
    float pos = 15 + 15*i;
    bts.get(i).render(pos, 0, pos, height);
    bts.get(i).send();
    
    stroke(255);
    line(pos, 0, pos, height);
  }
  
  colorAngle += colorSpeed;

  float fadePercent = .98;
  kickSize  = constrain(kickSize  * fadePercent, 16, 32);
  snareSize = constrain(snareSize * fadePercent, 16, 32);
  hatSize   = constrain(hatSize   * fadePercent, 16, 32);
  
  if(s != null && s.m_chosen) {
    s.m_chosen = false;
    bts.add(new BlinkyTape(this, s.m_port, numberOfLEDs));
    s = null;
  }
}

void stop()
{
  // always close Minim audio classes when you are finished with them
  //  song.close();
  audioin.close();

  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}

void keyPressed()
{
  if(keyCode==UP) {
    globalVolume += .3;
    println(globalVolume);
  }
  else if(keyCode==DOWN) {
    globalVolume -= .3;
    println(globalVolume);
  }
  if(keyCode==RIGHT) {
    globalFalloff += 1;
    println(globalFalloff);
  }
  else if(keyCode==LEFT) {
    globalFalloff -= 1;
    println(globalFalloff);
  }
}

