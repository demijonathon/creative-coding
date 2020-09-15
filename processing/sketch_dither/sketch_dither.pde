
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
final int WAIT_TIME = 2 * 1000;
final int TRANS_TIME = 3 * 1000;
final int NUM_STEPS = 4;
final int CYCLE_TIME = NUM_STEPS * (WAIT_TIME + TRANS_TIME);
int step_count = 4;
boolean new_target = true;
int maxVehicles;
int[] shuffleIndex1, shuffleIndex2;

List<Particle> particles = new ArrayList<Particle>();
List<Vehicle> vehicles = new ArrayList<Vehicle>();

HexImage hexData;
GridImage gridData;
SvgWord word1Data, word2Data, word3Data;

void setup() {
  PImage baseImage;
  String imageName = "london.jpg"; // 512x512
  size(512, 512); // window size must be hard coded
  baseImage = loadImage(imageName);
  baseImage.filter(GRAY);

  // Draw image to screen
  //image(baseImage, 0, 0);
  int ditherImageOffset = 0;

  println(imageName + " is " + baseImage.width + " x " + baseImage.height);

  int numColors = 2;
  int hexPointCount;

  if (HEXMODE) {
    hexData = new HexImage(baseImage, ditherImageOffset, numColors);
    hexPointCount = hexData.getPointCount();
    //hexData.drawAllPoints();
  } else { // Grid mode
    gridData = new GridImage(baseImage, ditherImageOffset, numColors);
    gridData.drawAllPoints(baseImage);
  }

  RG.init(this);
  word1Data = new SvgWord("Hello World", width/2, 3*height/4);
  int word1PointCount = word1Data.calcWordPoints();

  word2Data = new SvgWord("Are you not", width/2, 3*height/4);
  int word2PointCount = word2Data.calcWordPoints();

  word3Data = new SvgWord("Entertained ?", width/2, 3*height/4);
  int word3PointCount = word3Data.calcWordPoints();

  println("Hex points number: " + hexPointCount + " and word points number: " + word1PointCount);
  int[] pointCounts = {hexPointCount, word1PointCount, word2PointCount, word3PointCount};
  maxVehicles = max(pointCounts);

  int pSize =6;
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


void draw() {
  int m=millis() % CYCLE_TIME;
  int tmp_step = m/(WAIT_TIME + TRANS_TIME);

  if (tmp_step != step_count) {
    new_target = true;
    step_count = tmp_step;
  }

  if (new_target) {
    switch (step_count) {
      case(0): 
      {
        hexData.assignNewTargets(maxVehicles, shuffleIndex1);
        break;
      }
      case(1): 
      {
        word1Data.assignNewTargets(maxVehicles, shuffleIndex2);
        break;
      }
      case(2): 
      {
        word2Data.assignNewTargets(maxVehicles, shuffleIndex1);
        break;
      }
      case(3): 
      {
        word3Data.assignNewTargets(maxVehicles, shuffleIndex2);
        break;
      }
    default: 
      {
        break;
      }
    }
  }

  new_target = false;
  background(51);

  //println("step count" + step_count);
  for (int i = 0; i < vehicles.size(); i++) {
    Vehicle v = vehicles.get(i);
    v.behaviors();
    v.update();
    v.show();
  }

  //delay(100);
}
