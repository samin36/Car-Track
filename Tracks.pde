class Tracks {
  ArrayList<Boundary> boundaries;
  float trackWidth;
  float trackHeight;
  int numTracks;
  Tracks(float trackWidth_, float trackHeight_) {
    //Center will be (width/2, height)
    trackWidth = trackWidth_;
    trackHeight = trackHeight_;
    boundaries = new ArrayList<Boundary>();
    numTracks = (int) (height / trackHeight) + 2;
    addTrack(true); //Add the initial track
    for (int i = 1; i < numTracks; i++) {
      addTrack(false);
    }
  }

  void addTrack(boolean initialTrack) {
    if (initialTrack == true) {
      float lAx = width*.5 - trackWidth/2;
      float lAy = height;
      float lBx = lAx;
      float lBy = lAy - trackHeight;
      float rAx = width*.5 + trackWidth/2;
      float rAy = height;
      float rBx = rAx;
      float rBy = rAy - trackHeight;
      boundaries.add(new Boundary().addStraightBoundary(lAx, lAy, lBx, lBy, rAx, rAy, rBx, rBy));
    } else {
      Boundary lastBoundary = boundaries.get(boundaries.size()-1);
      float avgBx = lastBoundary.getAvgBx();
      float angle; //Experiment with Perlin Noise later
      if (avgBx > width/2) {
        // choose angles in the 2nd quadrant
        angle = random(PI/2, 3*PI/4);
      } else {
        // choose angles in the 1st quadrant 
        angle = random(PI/4, PI/2);
      }
      PVector lastLeft = lastBoundary.getLastLeft();
      PVector lastRight = lastBoundary.getLastRight();
      float lAx = lastLeft.x;
      float lAy = lastLeft.y;
      float rAx = lastRight.x;
      float rAy = lastRight.y;
      float lBx = constrain(lAx + cos(angle)*trackHeight, 0, width);
      float lBy = constrain(lAy - sin(angle)*trackHeight, 0, height);
      float rBx = constrain(lBx + trackWidth, 0, width);
      float rBy = constrain(lBy, 0, height);

      //Add a bezier-curve boundary
      PVector lp0 = new PVector(lAx, lAy);
      PVector lp1 = new PVector(lAx, (lBy + lAy) / 2);
      PVector lp2 = new PVector(lBx, (lBy + lAy) / 2);
      PVector lp3 = new PVector(lBx, lBy);
      PVector rp0 = new PVector(rAx, rAy);
      PVector rp1 = new PVector(rAx, (rBy + rAy) / 2);
      PVector rp2 = new PVector(rBx, (rBy + rAy) / 2);
      PVector rp3 = new PVector(rBx, rBy);
      boundaries.add(new Boundary().addBezierBoundary(lp0, lp1, lp2, lp3, rp0, rp1, rp2, rp3));
    }
  }

  void updateTracks() {
    for (int i = 0; i < boundaries.size(); i++) {
      if (boundaries.get(i).outOfBounds()) {
        boundaries.remove(i);
        i--;
      }
    }

    //Add tracks if necessary
    while (boundaries.size() < numTracks) {
      addTrack(false);
    }
  }

  void moveTracks(float vel) {
    PVector trackVel = new PVector(0, vel);
    for (Boundary boundary : boundaries) {
      boundary.moveBoundaries(trackVel);
    }
  }

  void showTracks() {
    for (Boundary boundary : boundaries) {
      boundary.show();
    }
  }
}
