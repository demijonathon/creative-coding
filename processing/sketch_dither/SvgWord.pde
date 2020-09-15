//import geomerative.*;

class SvgWord {
  // Declare the objects we are going to use, so that they are accesible from setup() and from draw()
  RFont f;
  RShape grp;
  RPoint[] points;
  //String my_word = "Happy Birthday!";
  int xOffset;
  int yOffset;

  SvgWord(String my_word, int xOff, int yOff) {

    // VERY IMPORTANT: Always initialize the library in the main setup
    if (RG.initialized() != true) {
      print("Not initialised");
      exit();
    }
    xOffset = xOff;
    yOffset = yOff;

    //  Load the font file we want to use (the file must be in the data folder in the sketch floder), 
    // with the size 60 and the alignment CENTER
    grp = RG.getText(my_word, "FreeSans.ttf", 72, CENTER);

    // Enable smoothing
    //smooth();
  }


  int calcWordPoints() {

    // Get the points on the curve's shape
    //RG.setPolygonizer(RG.UNIFORMSTEP);
    //RG.setPolygonizerStep(map(float(mouseY), 0.0, float(height), 0.0, 1.0));

    RG.setPolygonizer(RG.UNIFORMLENGTH);
    // Length is scaled between 3 and 200 using mouseY value
    //RG.setPolygonizerLength(map(mouseY, 0, height, 3, 200));
    RG.setPolygonizerLength(6);
    points = grp.getPoints();

    return points.length;
  }


  void assignNewTargets(int maxPoints, int[] shIndex) {
    if (points != null) {
      //translate(width/2, 3*height/4);
      Vehicle v;
      for (int i=0; i<maxPoints; i++) {
        v = vehicles.get(shIndex[i]);
        int modI = i%points.length;
        v.target.x = points[modI].x + xOffset;
        v.target.y = points[modI].y + yOffset;
        
        v.col = new PVector(255,255,255);
        //println("New position: " + v.target.x + " , " + v.target.y);
      }
    }
  }
}
