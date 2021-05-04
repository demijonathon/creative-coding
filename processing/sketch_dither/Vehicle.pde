// Daniel Shiffman
// http://codingtra.in
// Steering Text Paths
// Video: https://www.youtube.com/watch?v=4hA7G3gup-4

class Vehicle {
  PVector pos;
  PVector target;
  PVector vel;
  PVector acc;
  PVector col;
  PVector targetCol;
  int r; // Stroke weight / point radius
  float maxspeed;
  float maxforce;

  final float FLEE_TIME = 0.2; // 20 %
  final float HEX_FLAT_HEIGHT = sqrt(3.0);
  
  Vehicle(float x, float y, int size) {
    this.pos = new PVector(x, y);
    this.target = new PVector(x, y);
    this.vel = new PVector(0, 0); //PVector.random2D();
    this.acc = new PVector(0, 0);
    this.col = new PVector(255.0, 255.0, 255.0);
    this.targetCol = new PVector(255.0, 255.0, 255.0);
    this.r = size;
    this.maxspeed = 7;
    this.maxforce = 1;
  }

  void behaviors() {
    PVector arrive = this.arrive(this.target);
    arrive.mult(1);
    this.applyForce(arrive);
  }
  
  
  void behaviors(float transition) {
    PVector arrive = this.arrive(this.target);
    PVector flee = this.flee(new PVector(256.0,256.0)); // this fails with vector > 0
    if (transition < FLEE_TIME) {
      flee.mult(3);
      this.applyForce(flee);
    } else {
      arrive.mult(1);
      this.applyForce(arrive);
    }
  }

  void applyForce(PVector f) {
    this.acc.add(f);
  }

  void update() {
    this.pos.add(this.vel);
    this.vel.add(this.acc);
    this.acc.mult(0);
  }

  void show(float fraction, int debug) {
    //stroke(255);
    PVector tmpCol; // use tmpCol as we need to interpolate between col and targetCol
    if (fraction < 1.0) {
      tmpCol = PVector.add(PVector.mult(PVector.sub(this.targetCol,this.col),fraction),this.col);
    } else {
      tmpCol = this.targetCol;
      this.col=this.targetCol;
    }
    stroke(int(tmpCol.x), int(tmpCol.y), int(tmpCol.z));
    strokeWeight(this.r*HEX_FLAT_HEIGHT);
    point(this.pos.x, this.pos.y);
  }
 


  PVector arrive(PVector target) {
    final int PULL_RADIUS = 100;
    PVector desired = PVector.sub(target, this.pos);
    float d = desired.mag();
    float speed = this.maxspeed;
    if (d < PULL_RADIUS) {
      speed = map(d, 0, 100, 0, this.maxspeed);
    }
    desired.setMag(speed);
    PVector steer = PVector.sub(desired, this.vel);
    steer.limit(this.maxforce);
    return steer;
  }

  PVector flee(PVector target) {
    final int FLEE_RADIUS = 300;
    PVector desired = PVector.sub(target, this.pos);
    float d = desired.mag();
    if (d < FLEE_RADIUS) {
      desired.setMag(this.maxspeed);
      desired.mult(-1);
      PVector steer = PVector.sub(desired, this.vel);
      steer.limit(this.maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }
}
