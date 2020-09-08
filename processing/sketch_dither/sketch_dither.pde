  
// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain

// Floyd Steinberg Dithering
// Edited Video: https://youtu.be/0L2n8Tg2FwI

import java.util.*;

PImage kitten;
int pSize = 10;
float hexSize = 5.0;
int ditherImageOffset;
List<Particle> particles = new ArrayList<Particle>();
int[][] particleRef;
int xCellCount, yCellCount;

float HEX_FLAT_HEIGHT = sqrt(3.0);

void setup() {
  size(1024, 512); // must be hard coded
  kitten = loadImage("kitten.jpg");
  kitten.filter(GRAY);
  image(kitten, 0, 0);
  ditherImageOffset = kitten.width;
  xCellCount = floor(- 0.5 + (kitten.width / (hexSize * sqrt(3.0))));
  yCellCount = floor(0.5 + (kitten.height / (hexSize * 1.5)));
  
  println("Kitten.jpg is " + kitten.width + " x " + kitten.height);
  println("Cell count for size " + pSize + " is " + xCellCount + " x " + yCellCount);
  createHexArrayReference(xCellCount, yCellCount);
  ditherHexImage(2);
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


int index(int x, int y) {
  return x + y * kitten.width;
}

int index(int x, int y, int width) {
  return x + y * width;
}

void draw() {
  ;
}


void ditherImage(int factor) {
  kitten.resize(0, ditherImageOffset/pSize);
  kitten.loadPixels();
  for (int y = 0; y < kitten.height-1; y++) {
    for (int x = 1; x < kitten.width-1; x++) {
      color pix = kitten.pixels[index(x, y)];
      float oldR = red(pix);
      float oldG = green(pix);
      float oldB = blue(pix);
      int newR = round(factor * oldR / 255) * (255/factor);
      int newG = round(factor * oldG / 255) * (255/factor);
      int newB = round(factor * oldB / 255) * (255/factor);
      kitten.pixels[index(x, y)] = color(newR, newG, newB);

      float errR = oldR - newR;
      float errG = oldG - newG;
      float errB = oldB - newB;


      int index = index(x+1, y  );
      color c = kitten.pixels[index];
      float r = red(c);
      float g = green(c);
      float b = blue(c);
      r = r + errR * 7/16.0;
      g = g + errG * 7/16.0;
      b = b + errB * 7/16.0;
      kitten.pixels[index] = color(r, g, b);

      index = index(x-1, y+1  );
      c = kitten.pixels[index];
      r = red(c);
      g = green(c);
      b = blue(c);
      r = r + errR * 3/16.0;
      g = g + errG * 3/16.0;
      b = b + errB * 3/16.0;
      kitten.pixels[index] = color(r, g, b);

      index = index(x, y+1);
      c = kitten.pixels[index];
      r = red(c);
      g = green(c);
      b = blue(c);
      r = r + errR * 5/16.0;
      g = g + errG * 5/16.0;
      b = b + errB * 5/16.0;
      kitten.pixels[index] = color(r, g, b);


      index = index(x+1, y+1);
      c = kitten.pixels[index];
      r = red(c);
      g = green(c);
      b = blue(c);
      r = r + errR * 1/16.0;
      g = g + errG * 1/16.0;
      b = b + errB * 1/16.0;
      kitten.pixels[index] = color(r, g, b);
    }
  }
  kitten.updatePixels();
  PImage newKitten = kitten.get();
  kitten.resize(0, ditherImageOffset);
  image(kitten, ditherImageOffset, 0);
    
  //drawImageAsHexPoints(newKitten);
  drawImageAsHexPoints(kitten);
  //drawImageAsGridPoints(newKitten);
}

void ditherHexImage(int factor) {
  //kitten.resize(0, ditherImageOffset/pSize);
  //kitten.resize(0, ditherImageOffset);
  //PImage newKitten = kitten.get();
  image(kitten, ditherImageOffset, 0);
    
  drawImageAsHexPoints(kitten);
}

/*
PVector pixel_to_pointy_hex(PVector coords, int size) {
  q = (sqrt(3)/3 * coords.x - 1.0 /3 * coords.y) / size;
  r = (                       2.0 /3 * coords.y) / size;
  return new PVector(q, r);
}*/


void imageToHexPoints(PImage image) {
  ; 
}

void drawImageAsHexPoints(PImage image) {
  stroke(255,0,0);
  strokeWeight(HEX_FLAT_HEIGHT * hexSize);
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
      particles.add(new Particle(hexX,hexY,true));
    }
  }
  
  calculateHexColors(image);
  //ditherHexImage(2);
  drawAllPoints();
}

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
        if (pow((xCentre - x),2) + pow((yCentre -y),2) < pow(hexSize,2)) {
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
    
    particle.col.div(colorMag);
  }
}


void drawAllPoints() {
  for (int i = 0; i< particles.size(); i++) {
 
    Particle particle = particles.get(i);
    particle.show();
  }
}

void drawImageAsGridPoints(PImage image) {
  stroke(0,0,0);
  strokeWeight(pSize);
  
  image.loadPixels();
  
  println("Image dimentions are " + image.height + "/" + image.width);
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      color pix = image.pixels[index(x,y, image.width)];
      if (red(pix) == 0 ) {
        point(ditherImageOffset + (pSize * (x - 1/2)), (pSize * (y - 1/2)));
      }
    }
  }
}
