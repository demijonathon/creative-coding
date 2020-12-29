class HexImage {
  // HexImage is made up of (honeycomb) cells in rows and cols
  // Map cells onto a 2d array where the index is W-E (r) and NW-SE (q)

  float hexSize = 4.0; // edge length in pixels
  final float HEX_FLAT_HEIGHT = sqrt(3.0);

  int[][] particleRef;
  int xCellCount, yCellCount; // num of cells in rows and columns, pointy top configuration

  HexImage(PImage bImage, int ditherImageOffset, int numColors, float size) {
    hexSize = size;
    xCellCount = floor(- 0.5 + (bImage.width / (hexSize * sqrt(3.0))));
    yCellCount = floor(0.5 + (bImage.height / (hexSize * 1.5)));
    createHexArrayReference(xCellCount, yCellCount);
    println("Hex Cell dimentions for size " + hexSize + " is " + xCellCount + " x " + yCellCount);

    calcDitherHexImage(bImage, numColors, ditherImageOffset);
  }

  /* Populate the 2d array with the particle id which maps to the ordering of the hexes.
   This allows us to traverse the array and propogate the dither error forward. */
  private void createHexArrayReference(int map_width, int map_height) {
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

  /* Calculate the colours for each of the hexagons in full RGB
   Then quantise down to the number provided as the numColourLevels. */
  private void calcDitherHexImage(PImage baseImage, int numColourLevels, int offset) {
    transformImageAsHexPoints(baseImage, offset);
    calculateHexColors(baseImage);
    quantizeHexPointColors(numColourLevels);
  }

  // Create Particles at centre of each hex
  private void transformImageAsHexPoints(PImage image, int drawOffset) {
    //int cellSize = pSize;
    float hexOffset = HEX_FLAT_HEIGHT * hexSize;
    float xCellOffset = hexSize * sqrt(3.0);
    float yCellOffset = hexSize * 3.0 / 2.0;

    image.loadPixels();

    //println("Image dimentions are " + image.height + "/" + image.width);
    for (int y = 0; y < yCellCount; y++) {
      if (y%2 == 0) {
        hexOffset = HEX_FLAT_HEIGHT * hexSize/2.0;
      } else {
        hexOffset = HEX_FLAT_HEIGHT * hexSize;
      }
      for (int x = 0; x < xCellCount; x++) {
        float hexX = drawOffset + hexOffset + (x*xCellOffset);
        float hexY = hexSize + (yCellOffset * y);
        particles.add(new Particle(hexX, hexY, true));
      }
    }
  }

  // Compare hex to local pixels to approximate its color.
  private void calculateHexColors(PImage image) {
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

  /* Loop through each hex, work out nearest color level, and push the
   difference onto next hexes */
  private void quantizeHexPointColors(int numColourLevels) {
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
          int newR = round(numColourLevels * oldR / 255) * (255/numColourLevels);
          int newG = round(numColourLevels * oldG / 255) * (255/numColourLevels);
          int newB = round(numColourLevels * oldB / 255) * (255/numColourLevels);
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
                //if ((red > 255.0) || (gre > 255.0) || (blu > 255.0)) {
                //  println("Index: " + index + " // red: " + red + " // green: " + gre + " // blue: " + blu);
                //}
                particle.col = new PVector(red, gre, blu);
              }
            }
          }
        }
      }
    }
  }

  int getPointCount() {
    return particles.size();
  }

  void assignNewTargets(int maxPoints, int[] shIndex) {
    if (particles != null) {
      Vehicle v;
      Particle p;
      for (int i=0; i<maxPoints; i++) {
        v = vehicles.get(shIndex[i]);
        p = particles.get(i%getPointCount());
        v.target.x = p.pos.x;
        v.target.y = p.pos.y;
        v.targetCol = p.col;
      }
    }
  }

  void drawAllPoints() {
    strokeWeight(HEX_FLAT_HEIGHT * hexSize);
    for (int i = 0; i< particles.size(); i++) {

      Particle particle = particles.get(i);
      particle.show();
    }
  }

  void show() {
  }
}
