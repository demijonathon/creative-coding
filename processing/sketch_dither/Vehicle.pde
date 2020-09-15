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
  int r; // Stroke weight / point radius
  float maxspeed;
  float maxforce;

  Vehicle(float x, float y, int size) {
    this.pos = new PVector(x, y);
    this.target = new PVector(x, y);
    this.vel = new PVector(0, 0); //PVector.random2D();
    this.acc = new PVector(0, 0);
    this.col = new PVector(0.0, 0.0, 0.0);
    this.r = size;
    this.maxspeed = 7;
    this.maxforce = 1;
  }

  void behaviors() {
    PVector arrive = this.arrive(this.target);
    //PVector mouse = new PVector(mouseX, mouseY);
    //PVector flee = this.flee(mouse);

    arrive.mult(1);
    //flee.mult(5);

    this.applyForce(arrive);
    //this.applyForce(flee);
  }

  void applyForce(PVector f) {
    this.acc.add(f);
  }

  void update() {
    this.pos.add(this.vel);
    this.vel.add(this.acc);
    this.acc.mult(0);
  }

  void show() {
    //stroke(255);
    stroke(int(this.col.x), int(this.col.y), int(this.col.z));
    strokeWeight(this.r);
    point(this.pos.x, this.pos.y);
  }


  PVector arrive(PVector target) {
    PVector desired = PVector.sub(target, this.pos);
    float d = desired.mag();
    float speed = this.maxspeed;
    if (d < 100) {
      speed = map(d, 0, 100, 0, this.maxspeed);
    }
    desired.setMag(speed);
    PVector steer = PVector.sub(desired, this.vel);
    steer.limit(this.maxforce);
    return steer;
  }

  PVector flee(PVector target) {
    PVector desired = PVector.sub(target, this.pos);
    float d = desired.mag();
    if (d < 50) {
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
