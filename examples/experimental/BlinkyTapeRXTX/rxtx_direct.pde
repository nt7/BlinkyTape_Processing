// Direct serial implementation using RXTX, to figure out where the shoddy behaviour we're experiencing is coming from.
// Based off the RXTX examples: http://rxtx.qbang.org/wiki/index.php/Two_way_communcation_with_the_serial_port

import gnu.io.CommPort;
import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.NoSuchPortException;
import gnu.io.PortInUseException;
import java.util.Enumeration;

import java.util.List;

// TODO: This should be static inside DirectSerial, can't do this as a processing sketch.
// TODO: Rename me to list, also can't do as a processing sketch.
public static String[] listPorts() {
  List<String> ports = new ArrayList<String>();

  // Use RXTX to get a list of all ports on the system.
  Enumeration portEnum = CommPortIdentifier.getPortIdentifiers();
  while ( portEnum.hasMoreElements () ) 
  {
    CommPortIdentifier portIdentifier = (CommPortIdentifier)portEnum.nextElement();

    // If this is a serial port, add it to our list.
    if (portIdentifier.getPortType() == CommPortIdentifier.PORT_SERIAL) {
      ports.add(portIdentifier.getName());
    }
  }

  return(ports.toArray(new String[0]));
}


class DirectSerial {
  private String m_portName;
  
  public InputStream in;
  public OutputStream out;

  void connect(String portName) {


    CommPortIdentifier portIdentifier;
    try {
      portIdentifier = CommPortIdentifier.getPortIdentifier(portName);
    }
    catch (NoSuchPortException e) {
      // TODO: signal the user here
      return;
    }

    if ( portIdentifier.isCurrentlyOwned() )
    {
      System.out.println("Error: Port is currently in use");
      return;
    }

    CommPort commPort;

    try {
      commPort = portIdentifier.open(this.getClass().getName(), 2000);
    }
    catch (PortInUseException e) {
      // TODO: signal the user here
      println("PortInUseException trying to open port: " + e);
      return;
    }

    if ( commPort instanceof SerialPort )
    {
      SerialPort serialPort = (SerialPort) commPort;

      // TODO: handle parameter setting.
      //        serialPort.setSerialPortParams(57600, SerialPort.DATABITS_8, SerialPort.STOPBITS_1, SerialPort.PARITY_NONE);

      try {
        in = serialPort.getInputStream();
        out = serialPort.getOutputStream();
      }
      catch (IOException e) {
        println("IOException trying to open port: " + e);
        // TODO: signal the user here
        return;
      }
    }
    else
    {
      System.out.println("Error: Only serial ports are handled by this example.");
    }
    
    m_portName = portName;
  }

  void write(byte[] data) {
    try {
      out.write(data);
      out.flush();
    }
    catch(IOException e) {
      println("IOException writing to port " + m_portName + " " + e);
    }
  }
};

