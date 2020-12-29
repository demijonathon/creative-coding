class SvgShape {
  // Declare the objects we are going to use, so that they are accesible from setup() and from draw()
 
  RShape grp;
  RPoint[] points;
  int xOffset;
  int yOffset;
  int pSize;

  SvgShape(int id, int xOff, int yOff, int size) {

    // VERY IMPORTANT: Always initialize the library in the main setup
    if (RG.initialized() != true) {
      print("Not initialised");
      exit();
    }
    xOffset = xOff;
    yOffset = yOff;
    pSize = size * 3 / 2;

    int Peak = -180;
    int Row1 = -80;
    int Row2 = 10;
    int Row3 = 90;
    int PotTop = 110;
    int PotBase = 160;

    if (id==1) {
      grp = new RShape();
      grp.addMoveTo(-30,PotBase);
      grp.addLineTo(-40,PotTop);
      grp.addLineTo(-10,PotTop);
      grp.addLineTo(-10,Row3);
      grp.addLineTo(-100,Row3);
      grp.addLineTo(-50,Row2);
      grp.addLineTo(-70,Row2);
      grp.addLineTo(-20,Row1);
      grp.addLineTo(-40,Row1);
      grp.addLineTo(0,Peak);
      grp.addLineTo(40,Row1);
      grp.addLineTo(20,Row1);
      grp.addLineTo(70,Row2);
      grp.addLineTo(50,Row2);
      grp.addLineTo(100,Row3);
      grp.addLineTo(10,Row3);
      grp.addLineTo(10,PotTop);
      grp.addLineTo(40,PotTop);
      grp.addLineTo(30,PotBase);
      grp.addLineTo(-30,PotBase);
      //grp.addArcTo(50,75,100,30);
      //grp.addBezierTo(130,90,75,100,90,150);
      //grp.addLineTo(130,250);
      //grp.addBezierTo(80,200,70,200,130,250);
  
      //grp.addMoveTo(60,120);
      //grp.addBezierTo(75,110,85,130,75,140);
      //grp.addBezierTo(70,150,65,140,60,120);
    }
    else {
    // Create the 5 pointed star
    //grp = RG.createStar(xOff, yOff, 5);
      pSize+=1;
    }
    // Enable smoothing
    //smooth();
  }
  
  int calcShapePoints() {
    RG.setPolygonizer(RG.UNIFORMLENGTH);
    RG.setPolygonizerLength(pSize);
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
        
        v.targetCol = new PVector(25.0,255.0,25.0);
        //println("New position: " + v.target.x + " , " + v.target.y);
      }
    }
  }
}
