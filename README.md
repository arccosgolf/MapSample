# MapSample

This sample project demonstrates the limitation of MKMapViewDelegate in determining whether a visible region is a satellite image or a gray tile.

## STEPS TO REPRODUCE
Run the sample project on a device. After the map loads for the first hole, select the number 2 at the top and allow the map to load. Next, enable airplane mode or go offline so that when you switch numbers at the top, the map doesn’t load. You will notice in the console that switching between holes 1 and 2 doesn’t always trigger the tiles to finish rendering.
