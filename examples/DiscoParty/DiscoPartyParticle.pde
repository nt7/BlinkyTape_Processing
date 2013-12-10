class DiscoPartyParticle {
  float m_scale;
  float m_rotation;
  
  float m_scaleFactor;
  float m_rotationFactor;
  
  final float m_maxScale = 22;
  
  float m_posX;
  float m_posY;

  PFont m_font;

  DiscoPartyParticle() {
    m_font = createFont("Helvetica", 100);
    
    reset();
  }
  
  void reset() {
    m_scaleFactor = 1.05;
    m_rotationFactor = .05;
    
    m_scale = .07;
    m_posX = random(width);
    m_posY = random(height);
  }

  void draw() {
    pushStyle();
    pushMatrix();
      fill(255, map(m_scale,0,m_maxScale,255,-100));
      translate(m_posX, m_posY);
      rotate(m_rotation);
      scale(m_scale);
      
      textFont(m_font);
      textAlign(CENTER);
      text("Disco Party",0,+textAscent()/2);
    
      m_scale*=m_scaleFactor;
      if(m_scale > m_maxScale) {
        reset();
      }
 
      m_rotation += m_rotationFactor;
      
    popMatrix();
    popStyle();
  }
  
}  
  
  

