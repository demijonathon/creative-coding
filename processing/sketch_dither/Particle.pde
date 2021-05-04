class Particle {
  PVector pos;
  PVector col;
  Boolean active;
  //PVector prev;
  //PVector vel;
  //PVector acc;

  Particle(float x, float y, Boolean isActive) {
    pos = new PVector(x, y);
    active = isActive;
    col = new PVector(0.0,0.0,0.0);
    //prev = new PVector(x, y);
    //vel = new PVector(); //p5.Vector.random2D();
    //acc = new PVector();
  }
  
  void show() {
   
    stroke(int(this.col.x),int(this.col.y),int(this.col.z));
    point(this.pos.x, this.pos.y); 
    //println("Point printed at " + this.pos.x + " / " + this.pos.y); 
  }
}
