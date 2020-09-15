class GridImage {
  final int GI_SQUARES = 0;
  final int GI_POINTS = 1;
  int DRAW_MODE;
  final int pSize = 4;

  GridImage(PImage baseImage, int numColors) {
    DRAW_MODE = GI_POINTS;
    println("Grid dimentions for size " + pSize + " is " + baseImage.width / pSize + " x " + baseImage.height / pSize);
    calcDitherImage(baseImage, numColors);
  }


  /* scale grid by pixel size of grid, then rewrite the colour value
   push difference from quantized color and push forward. */
  void calcDitherImage(PImage baseImage, int factor) { 
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

    //drawImageAsGridPoints(baseImage, 1);
  }

  int index(int x, int y) {
    return (y * baseImage.width) + x;
  }


  int index(int x, int y, int row_width) {
    int pos = (y * row_width) + x;
    if (x>row_width) {
      println("Index array params out of bounds");
      return -1;
    } else {
      return pos;
    }
  }

  void drawAllPoints(PImage image) {

    if (DRAW_MODE == GI_SQUARES) { // square mode
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
        if (DRAW_MODE == GI_SQUARES) { // square mode
          fill(pix);
          rect(xCentre, yCentre, pSize, pSize);
        } else {
          stroke(pix);
          point(xCentre, yCentre);
        }
      }
    }
  }
}
