import java.util.Arrays;

class Burst {
  PImage burstSprite;  // pImage of the sprite
  PImage burstMask;    // alpha mask of the sprite
  float burstD = 20;  // diameter of the sprite
 
  Burst() {
    burstSprite = new PImage(int(burstD*2), int(burstD*2));
    burstMask = new PImage(int(burstD*2), int(burstD*2));
    
    // Make a circular alpha mask for the burst
    for(int x = 0; x < burstMask.width; x++) {
      for(int y = 0; y < burstMask.height; y++) {
        // Calculate the unit distance between the center of the sprite and this point
        float delta = sqrt(pow(x - burstD, 2) + pow(y - burstD, 2));
        float intensity = map(delta,burstD, 0, 0, 255);
        
        burstMask.set(x,y,color(intensity,intensity, intensity));
      }
    }
  }
  
  void setColor(int c) {
    Arrays.fill(burstSprite.pixels, c);
    burstSprite.updatePixels();
    burstSprite.mask(burstMask);
  }

  void draw(int x, int y, int c, float s) {
    setColor(c);
    pushMatrix();
      translate(x, y);
      scale(s);
      imageMode(CENTER);
      image(burstSprite,0,0);
    popMatrix();
  }
}


