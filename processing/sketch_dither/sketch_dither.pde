
// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain

// Floyd Steinberg Dithering
// Edited Video: https://youtu.be/0L2n8Tg2FwI

import java.util.*;
import geomerative.*;

import java.util.Arrays;
import java.util.Random;

final boolean HEXMODE = true;
final int WAIT_TIME_MS = 2 * 1000;
final int TRANS_TIME_MS = 3 * 1000;
final int NUM_STEPS = 4;
final int STEP_TIME_MS = WAIT_TIME_MS + TRANS_TIME_MS;
final int CYCLE_TIME_MS = NUM_STEPS * STEP_TIME_MS;
int step_count = 4;
int prevStep=0;
boolean new_target = true;
int maxVehicles;
int[] shuffleIndex1, shuffleIndex2;
int[] pointCounts = new int[4];

List<Particle> particles = new ArrayList<Particle>();
List<Vehicle> vehicles = new ArrayList<Vehicle>();

HexImage hexData;
GridImage gridData;
SvgWord word1Data, word2Data, word3Data;
SvgShape shape1Data, shape2Data, shape3Data;

void setup() {
  PImage baseImage;
  String imageName = "sandf2.jpg"; // 512x512
  String messageOne = "Merry Christmas";
  String messageTwo = "Steph & Frank";
  size(512, 512); // window size must be hard coded
  baseImage = loadImage(imageName);
  baseImage.filter(GRAY);

  // Draw image to screen
  //image(baseImage, 0, 0);
  int ditherImageOffset = 0;

  println("Using image" + imageName + " : " + baseImage.width + " x " + baseImage.height);

  int numColors = 4;
  int pSize = 3; // Particle draw size - 5 or less

  if (HEXMODE) {
    hexData = new HexImage(baseImage, ditherImageOffset, numColors, float(pSize));
    pointCounts[0] = hexData.getPointCount();
    //hexData.drawAllPoints();
  } else { // Grid mode
    gridData = new GridImage(baseImage, ditherImageOffset, numColors);
    gridData.drawAllPoints(baseImage);
  }

  RG.init(this);
  word1Data = new SvgWord(messageOne, width/2, 3*height/5, pSize, 60);
  pointCounts[1] = word1Data.calcWordPoints();

  shape2Data = new SvgShape(1, width/2, 3*height/5, pSize);
  pointCounts[2] = shape2Data.calcShapePoints();

  word3Data = new SvgWord(messageTwo, width/2, 3*height/5, pSize, 72);
  pointCounts[3] = word3Data.calcWordPoints();

  println("Hex image points number: " + pointCounts[0] + " // word 1 points number: " + pointCounts[1]);
  println("Shape 2 points number: " + pointCounts[2] + " // word 3 points number: " + pointCounts[3]);
  maxVehicles = max(pointCounts);

  shuffleIndex1 = new int[maxVehicles];
  shuffleIndex2 = new int[maxVehicles];
  for (int i=0; i<maxVehicles; i++) {
    vehicles.add(new Vehicle(random(width), random(height), pSize));
    shuffleIndex1[i] = i;
    shuffleIndex2[i] = i;
  }

  // Create a random shuffling for the array
  Random rand = new Random();
  for (int i=maxVehicles-1; i>0; i--) {
    int randomI = rand.nextInt(i);
    int temp = shuffleIndex1[randomI];
    shuffleIndex1[randomI] = shuffleIndex1[i];
    shuffleIndex1[i] = temp;
    randomI = rand.nextInt(i);
    temp = shuffleIndex2[randomI];
    shuffleIndex2[randomI] = shuffleIndex2[i];
    shuffleIndex2[i] = temp;
  }
}

// A cycle is a full set of steps
void draw() {
  int mSecPerCycle=millis() % CYCLE_TIME_MS;
  int tmp_step = mSecPerCycle/STEP_TIME_MS; // rounds to integer
  float transition = (mSecPerCycle - (tmp_step*STEP_TIME_MS))/(float)TRANS_TIME_MS;
  //println("transition: " + transition);

  if (tmp_step != step_count) {
    new_target = true;
    step_count = tmp_step;
  }

  if (new_target) {
    switch (step_count) {
      case(0): {
        hexData.assignNewTargets(maxVehicles, shuffleIndex1);
        prevStep = pointCounts.length - 1;
        break;
      }
      case(1): {
        word1Data.assignNewTargets(maxVehicles, shuffleIndex2);
        prevStep = 0;
        break;
      }
      case(2): {
        shape2Data.assignNewTargets(maxVehicles, shuffleIndex1);
        prevStep = 1;
        break;
      }
      case(3): {
        word3Data.assignNewTargets(maxVehicles, shuffleIndex2);
        prevStep = 2;
        break;
      }
    default: {
        break;
      }
    }
  }

  new_target = false;
  background(51);
  int maxShowCount=(maxVehicles + max(new int[] {pointCounts[step_count], pointCounts[prevStep]})) / 2;

  //println("step count: " + step_count + "prevstep count: " + prevStep + "// max show count: " + maxShowCount);
  for (int i = 0; i < vehicles.size(); i++) {
    Vehicle v = vehicles.get(i);
    v.behaviors(transition);
    v.update();
    if (i < maxShowCount) {
      v.show(transition,i);
    }
  }

  //delay(100);
}
