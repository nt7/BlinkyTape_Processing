// TODO: Make this threaded! We can't hit high framerates otherwise :-(

class LedOutput
{
  private String m_portName;  // TODO: How to request cu.* devices?
  private JsscSerial m_outPort;

  private int m_numberOfLEDs;
  private Boolean m_enableGammaCorrection;
  private float m_gammaValue;
  
  private byte[] m_data;

  LedOutput(PApplet parent, String portName, int numberOfLEDs) {
    m_portName = portName;
    m_numberOfLEDs = numberOfLEDs;
    
    m_enableGammaCorrection = true;
    m_gammaValue = 1.8;

    println("Connecting to BlinkyTape on: " + portName);
    m_outPort = new JsscSerial(portName);
  }
  
  String getName() {
    return m_portName;
  }
  
  void sendUpdate(float x1, float y1, float x2, float y2) {
    sendUpdate(get(), x1, y1, x2, y2);
  }
  
  // Update the blinkyboard with new colors
  void sendUpdate(PImage image, float x1, float y1, float x2, float y2) {
    image.loadPixels();
    
    // Note: this should be sized appropriately
    byte[] data = new byte[m_numberOfLEDs*3 + 1];
    int dataIndex = 0;

    // data is R,G,B
    for(int i = 0; i < m_numberOfLEDs; i++) {
      // Sample a point along the line
      int x = (int)((x2 - x1)/m_numberOfLEDs*i + x1);
      int y = (int)((y2 - y1)/m_numberOfLEDs*i + y1);
      
      int r = int(red(image.pixels[y*width+x]));
      int g = int(green(image.pixels[y*width+x]));
      int b = int(blue(image.pixels[y*width+x]));
      
      if (m_enableGammaCorrection) {
        r = (int)(Math.pow(r/256.0,m_gammaValue)*256);
        g = (int)(Math.pow(g/256.0,m_gammaValue)*256);
        b = (int)(Math.pow(b/256.0,m_gammaValue)*256);
      }

      data[dataIndex++] = (byte)min(254, r);
      data[dataIndex++] = (byte)min(254, g);
      data[dataIndex++] = (byte)min(254, b);
    }
    
    // Add a 0xFF at the end, to signal the tape to display
    data[dataIndex++] = (byte)255;
    
    m_data = data;
  }
  
  void send() {
    startSend();
    while(sendNextChunk()) {
      delay(1);
    };
  }
  
  int m_currentChunkPos;
  
  void startSend() {
    m_currentChunkPos = 0;
  }
  
  // returns false if done
  boolean sendNextChunk() {
    // Don't send data too fast, the arduino can't handle it.
    int maxChunkSize = 32;
    
    if( m_currentChunkPos >= m_numberOfLEDs*3 + 1) {
      return false;
    }
    
    int currentChunkSize = min(maxChunkSize, m_numberOfLEDs*3 + 1 - m_currentChunkPos);
    byte[] test = new byte[currentChunkSize];
    
    for(int i = 0; i < currentChunkSize; i++) {
        test[i] = m_data[m_currentChunkPos + i];
    }
  
    m_outPort.write(test);
    
    m_currentChunkPos += maxChunkSize;
    return true;
  }
}

