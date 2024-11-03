# TopoViz

### A physical visualization of mountain topographies. 
##### Insert screenshot

## This Repo contains all the code I used in the project. The main components are: 

### MacOS App
The Mac app allows the user to interface with a satellite map of the world with 10 points overlayed on top of it. Each point pulls altitude data from the Open Elevation API and send it to a Python server.
This app uses SwifUI & MapKit. 

### Python Server 
The Python server runs locally on the users machine, its job is to act as a link between the MacOS app and the Arduino. 
It receives data from the MacOS app through a socket, and sends it to the Arduino through a serial connection via USB. 

### Arduino Code 
The Ardiuno recieves a list of elevations that looks like this:
###### elevation = [1000,1100,1200,1300,1400,1500,1600,1700,1800,1900,2000]. 
It parses the elevations into a list of integers and processes them with a mapping function to be within 0 - 130mm's. 
The number of steps each motor has to take can be calculated as:
###### distance = abs(current_pos - target_pos); 
###### steps = distance / distancePerStep;

After processing, each Rod object gets called to move that number of steps in the specified direction. 
There is also a function for calibration in case I forgot to zero the rods before closing the connection, since the rods cannot hold state when they lose power, they assume they start at 0 elevation.
