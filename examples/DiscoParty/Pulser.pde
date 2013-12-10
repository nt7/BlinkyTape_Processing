// Pulse to the music

float maxWidth = 30;

class Pulser {
  float m_x;
  float m_y;
  float m_xv;
  float m_yv;
  float m_size;
  float m_scale;
  
  int m_band;

  float m_falloff;
  
  float m_h;
  float m_s;
  
  ArrayList<Float> m_values = new ArrayList<Float>();

  Pulser() {
    m_x = random(0,maxWidth);
    m_y = random(0,height);
    m_xv = random(-.2,.2);
    m_yv = random(-.2,.2);

    m_size  = 10;
    m_scale = 3;
    
    m_falloff = .70;
    
    m_h = random(0,100);
    m_s = 100;
  }
  
  // @param x X position
  // @param y Y position
  // @param s size
  Pulser(float x, float y, float s) {
    m_x = x;
    m_y = y;
    m_size = s;
  }
  
  void draw(FFT fft) {
    m_scale = Sensitivity;
    
    m_values.add(fft.getAvg(m_band));
    
    float value = 0;
    for(Float v : m_values) {
      value += v;
    }
    value = value/m_values.size();
    
    while(m_values.size() > Smoothing) {
      m_values.remove(0);
    }
    
    // draw the particle
    pushStyle();
      colorMode(HSB, 100);

      float hue = (m_h + sin(colorAngle)*100+50)%100;
      float val = max(50,min(100,m_scale*value));
      float alpha = max(0,min(100,m_scale*value));

      color burstcolor = color(hue, m_s, val, alpha);

      int w = (int)(m_scale*value);

      burst.draw(int(m_x),int(m_y),burstcolor, w/20.0);
    popStyle();
    
    // Move the particle forward in space
    m_x = (m_x + m_xv);
    m_y = (m_y + m_yv);
  
    if(m_x > maxWidth) {
      m_x = 0;
      m_y = random(0,height);
    }
    else if(m_x < 0) {
      m_x = maxWidth;
      m_y = random(0,height);
    }
  
    if(m_y > height) {
      m_y = 0;
      m_x = random(0,maxWidth);
    }
    else if(m_y < 0) {
      m_y = height;
      m_x = random(0,maxWidth);
    }
  }
}
