
// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain

// Floyd Steinberg Dithering
// Edited Video: https://youtu.be/0L2n8Tg2FwI

import java.util.*;

final boolean HEXMODE = true;

PImage baseImage;
int ditherImageOffset;

List<Particle> particles = new ArrayList<Particle>();

void setup() {
  String imageName = "london.jpg";
  size(1024, 512); // window size must be hard coded
  baseImage = loadImage(imageName);
  baseImage.filter(GRAY);
  
  // Draw image to screen
  image(baseImage, 0, 0);
  ditherImageOffset = baseImage.width;

  println(imageName + " is " + baseImage.width + " x " + baseImage.height);

  int numColors = 4;

  if (HEXMODE) {
    HexImage hexData = new HexImage(baseImage.width, baseImage.height, numColors);
    hexData.drawAllPoints();
  } else { // Grid mode
    GridImage gridData = new GridImage(baseImage, numColors);
    gridData.drawAllPoints(baseImage);
  }
}


void draw() {
  ;
}
