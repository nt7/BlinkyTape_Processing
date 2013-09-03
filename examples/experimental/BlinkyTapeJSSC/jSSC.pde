import jssc.SerialPortList;
import jssc.SerialPort;
import jssc.SerialPortException;

public static String[] listPorts() {
  return SerialPortList.getPortNames();
}

class JsscSerial {
  SerialPort m_serialPort;

  JsscSerial(String portName) {
    m_serialPort = new SerialPort(portName);
    try {
      m_serialPort.openPort();//Open serial port
      m_serialPort.setParams(SerialPort.BAUDRATE_9600, 
      m_serialPort.DATABITS_8,
      m_serialPort.STOPBITS_1, 
      m_serialPort.PARITY_NONE);
    }
    catch (SerialPortException ex) {
      println(ex);
    }
  }
  
  
  void write(byte[] data) {
    try {
      // The problem here seems to be that the Arduino usb serial driver is buggy;
      // if we send it data too fast (or let too  much data collect in it's buffer)
      // it tends to hang. Try to handle it with kid gloves by always clearing
      // before sending. We might loose a little data this way, though.
      
      // TODO: why does sending data too fast crash the Leonardo!!!!
      //m_serialPort.purgePort(SerialPort.PURGE_TXCLEAR);
      
      boolean ret = m_serialPort.writeBytes(data);
      if(!ret) {
        // TODO: disable the port if we have a problem here?
      }
    }
    catch (SerialPortException ex) {
      println(ex);
    }
  }
  
  void close() {
    try {
      m_serialPort.closePort();
    }
    catch (SerialPortException ex) {
      println(ex);
    }
  }
}

