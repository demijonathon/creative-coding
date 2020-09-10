
// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain

// Floyd Steinberg Dithering
// Edited Video: https://youtu.be/0L2n8Tg2FwI

import java.util.*;

PImage baseImage;
int pSize = 4;
float hexSize = 5.0;
int ditherImageOffset;
List<Particle> particles = new ArrayList<Particle>();
int[][] particleRef;
int xCellCount, yCellCount;

float HEX_FLAT_HEIGHT = sqrt(3.0);
boolean HEXMODE = true;

void setup() {
  String imageName = "london.jpg";
  size(1024, 512); // must be hard coded
  baseImage = loadImage(imageName);
  baseImage.filter(GRAY);
  // Draw image to screen
  image(baseImage, 0, 0);
  ditherImageOffset = baseImage.width;

  println(imageName + " is " + baseImage.width + " x " + baseImage.height);

  int numColors = 6;

  if (HEXMODE) {
    xCellCount = floor(- 0.5 + (baseImage.width / (hexSize * sqrt(3.0))));
    yCellCount = floor(0.5 + (baseImage.height / (hexSize * 1.5)));
    createHexArrayReference(xCellCount, yCellCount);
    println("Cell count for size " + pSize + " is " + xCellCount + " x " + yCellCount);

    ditherHexImage(numColors);
  } else {
    println("Grid count for size " + pSize + " is " + baseImage.width / pSize + " x " + baseImage.height / pSize);
    ditherImage(numColors);
  }
}

void createHexArrayReference(int map_width, int map_height) {
  int r_offset = floor(map_height / 2);
  int i = 1;
  particleRef = new int[map_width][map_height];

  for (int r = 0; r < map_height; r++) {
    r_offset = floor(r/2); // or r>>1
    for (int q = -r_offset; q < map_width - r_offset; q++) {
      //particles.add(new Particle(0,0,true,r,q));
      particleRef[q + r_offset][r]= i++;
    }
  }
}


void ditherHexImage(int factor) {
  //baseImage.resize(0, ditherImageOffset/pSize);
  //baseImage.resize(0, ditherImageOffset);
  //PImage newbaseImage = baseImage.get();
  //image(baseImage, ditherImageOffset, 0);

  transformImageAsHexPoints(baseImage);
  quantizeHexPointColors(factor);
  drawAllPoints();
}


void draw() {
  ;
}


void quantizeHexPointColors(int factor) {
  int map_width = xCellCount;
  int map_height = yCellCount;
  int r_offset = floor(map_height / 2);

  // Loop through hexes, row by row
  for (int r = 0; r < map_height; r++) {
    r_offset = floor(r/2); // or r>>1
    for (int q = -r_offset; q < map_width - r_offset; q++) {
      int index = particleRef[q + r_offset][r];

      // Get the particle that is referenced by the particleRef array for that hex
      if (index > 0 && index < particles.size()) {
        Particle particle = particles.get(index);

        float oldR = particle.col.x;
        float oldG = particle.col.y;
        float oldB = particle.col.z;
        // quantize the color
        int newR = round(factor * oldR / 255) * (255/factor);
        int newG = round(factor * oldG / 255) * (255/factor);
        int newB = round(factor * oldB / 255) * (255/factor);
        particle.col = new PVector(float(newR), float(newG), float(newB));

        // calculate the error to push fwd
        float errR = oldR - newR;
        float errG = oldG - newG;
        float errB = oldB - newB;

        // loop over adjacent hexagons
        for (int n=0; n< 3; n++) {
          int[] qLoopOffset = new int[]{1, 0, 1}; // q offset for each hex
          int[] rLoopOffset = new int[]{0, 1, 1}; // r offset for each hex
          float[] errorDist = new float[]{0.4, 0.3, 0.3}; // must sum to 1

          if ((q + r_offset + qLoopOffset[n] < map_width) && (r + rLoopOffset[n] < map_height)) {
            int indexN = particleRef[q + r_offset + qLoopOffset[n]][r + rLoopOffset[n]];
            if (indexN > 0 && indexN < particles.size()) {
              particle = particles.get(indexN);
              float red = particle.col.x;
              float gre = particle.col.y;
              float blu = particle.col.z;
              // Spread the error out
              red = red + errR * errorDist[n];
              gre = gre + errG * errorDist[n];
              blu = blu + errB * errorDist[n];
              particle.col = new PVector(red, gre, blu);
            }
          }
        }
      }
    }
  }
}


void ditherImage(int factor) {
  baseImage.resize(0, ditherImageOffset/pSize);
  baseImage.loadPixels();
  for (int y = 0; y < baseImage.height-1; y++) {
    for (int x = 1; x < baseImage.width-1; x++) {
      color pix = baseImage.pixels[index(x, y)];
      float oldR = red(pix);
      float oldG = green(pix);
      float oldB = blue(pix);
      int newR = round(factor * oldR / 255) * (255/factor);
      int newG = round(factor * oldG / 255) * (255/factor);
      int newB = round(factor * oldB / 255) * (255/factor);
      baseImage.pixels[index(x, y)] = color(newR, newG, newB);

      float errR = oldR - newR;
      float errG = oldG - newG;
      float errB = oldB - newB;

      int[] xStep = new int[]{1, -1, 0, 1};
      int[] yStep = new int[]{0, 1, 1, 1};
      float[] errorDist = new float[]{0.44, 0.19, 0.31, 0.06}; // must sum to 1

      for (int n=0; n<4; n++) {
        if ((x>=0 && x<baseImage.width-1) && 
          (y>=0 && y<baseImage.height-1)) {
          int index = index(x+xStep[n], y+yStep[n] );
          color c = baseImage.pixels[index];
          float r = red(c);
          float g = green(c);
          float b = blue(c);
          r = r + errR * errorDist[n];
          g = g + errG * errorDist[n];
          b = b + errB * errorDist[n];
          baseImage.pixels[index] = color(r, g, b);
        }
      }
    }
  }
  baseImage.updatePixels();
  //PImage newbaseImage = baseImage.get();
  //baseImage.resize(0, ditherImageOffset);
  //image(baseImage, ditherImageOffset, 0);

  drawImageAsGridPoints(baseImage, 1);
}


int index(int x, int y) {
  return (y * baseImage.width) + x;
}

int index(int x, int y, int row_width) {
  return (y * row_width) + x;
}

// Create Particles at centre of each hex
void transformImageAsHexPoints(PImage image) {
  //int cellSize = pSize;
  float hexOffset = HEX_FLAT_HEIGHT * hexSize;
  float xCellOffset = hexSize * sqrt(3.0);
  float yCellOffset = hexSize * 3.0 / 2.0;

  image.loadPixels();

  println("Image dimentions are " + image.height + "/" + image.width);
  for (int y = 0; y < yCellCount; y++) {
    if (y%2 == 0) {
      hexOffset = HEX_FLAT_HEIGHT * hexSize/2.0;
    } else {
      hexOffset = HEX_FLAT_HEIGHT * hexSize;
    }
    for (int x = 0; x < xCellCount; x++) {
      float hexX = ditherImageOffset + hexOffset + (x*xCellOffset);
      float hexY = hexSize + (yCellOffset * y);
      particles.add(new Particle(hexX, hexY, true));
    }
  }

  calculateHexColors(image);
}

// Compare hex to local pixels to approximate its color.
void calculateHexColors(PImage image) {
  int colorMag;
  for (int i = 0; i< particles.size(); i++) {
    colorMag = 0;
    Particle particle = particles.get(i);
    float xCentre = particle.pos.x;
    float yCentre = particle.pos.y;

    // Loop through all pixels in the area
    for (int y=int(yCentre - hexSize); y < yCentre + hexSize; y++) {
      for (int x=int(xCentre - hexSize); x < xCentre + hexSize; x++) {

        // Sum colours inside the cirlce
        if (pow((xCentre - x), 2) + pow((yCentre -y), 2) < pow(hexSize, 2)) {
          // inside circle
          int index = y * image.width + x -512;
          if (index < image.pixels.length) {
            color c = image.pixels[index];
            particle.col.add(new PVector(red(c), green(c), blue(c)));
            colorMag++;
          }
        }
      }
    }
    // Normalise the color values
    particle.col.div(colorMag);
  }
}


void drawAllPoints() {
  strokeWeight(HEX_FLAT_HEIGHT * hexSize);
  for (int i = 0; i< particles.size(); i++) {

    Particle particle = particles.get(i);
    particle.show();
  }
}

void drawImageAsGridPoints(PImage image, int mode) {

  if (mode == 0) { // square mode
    noStroke();
    rectMode(CENTER);
  } else { // point mode
    noStroke();
    rectMode(CORNERS);  // Default rectMode is CORNER
    fill(127);
    rect(512, 0, 1024, 512);
  }

  strokeWeight(pSize);

  image.loadPixels();

  //println("Image dimentions are " + image.height + "/" + image.width);
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      color pix = image.pixels[index(x, y, image.width)];
      float xCentre = pSize * (float(x) + 0.5) + ditherImageOffset;
      float yCentre = pSize * (float(y) + 0.5);
      if (mode == 0) { // square mode
        fill(pix);
        rect(xCentre, yCentre, pSize, pSize);
      } else {
        stroke(pix);
        point(xCentre, yCentre);
      }
    }
  }
}
