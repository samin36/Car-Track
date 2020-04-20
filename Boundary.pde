class Boundary {
  ArrayList<PVector> leftLanes;
  ArrayList<PVector> rightLanes;

  Boundary() {
    leftLanes = new ArrayList<PVector>();
    rightLanes = new ArrayList<PVector>();
  }

  Boundary addStraightBoundary(float lAx, float lAy, float lBx, float lBy, float rAx, float rAy, float rBx, float rBy) {
    PVector leftA = new PVector(lAx, lAy);
    PVector leftB = new PVector(lBx, lBy);
    PVector rightA = new PVector(rAx, rAy);
    PVector rightB = new PVector(rBx, rBy);
    leftLanes.add(leftA);
    leftLanes.add(leftB);
    rightLanes.add(rightA);
    rightLanes.add(rightB);
    return this;
  }

  void moveBoundaries(PVector vel) {
    for (PVector left : leftLanes) {
      left.add(vel);
    }
    for (PVector right : rightLanes) {
      right.add(vel);
    }
  }

  boolean outOfBounds() {
    return (getLastLeft().y > height || getLastRight().y > height);
  }

  PVector getLastLeft() {
    return leftLanes.get(leftLanes.size() - 1);
  }

  PVector getLastRight() {
    return rightLanes.get(rightLanes.size() - 1);
  }

  void show() {
    stroke(255);
    strokeWeight(3);
    for (int i = 0; i < leftLanes.size() - 1; i++) {
      PVector lCurr = leftLanes.get(i), lNext = leftLanes.get(i + 1);
      PVector rCurr = rightLanes.get(i), rNext = rightLanes.get(i + 1);
      line(lCurr.x, lCurr.y, lNext.x, lNext.y);
      line(rCurr.x, rCurr.y, rNext.x, rNext.y);
      //line(lCurr.x, lCurr.y, rCurr.x, rCurr.y);
    }
  }

  ArrayList<PVector> getLanes() {
    ArrayList<PVector> combinedLanes = new ArrayList<PVector>(leftLanes);
    combinedLanes.addAll(rightLanes);
    return combinedLanes;
  }

  float getAvgBx() {
    return (getLastLeft().x + getLastRight().x) / 2;
  }

  Boundary addBezierBoundary(PVector lp0, PVector lp1, PVector lp2, PVector lp3, PVector rp0, PVector rp1, PVector rp2, PVector rp3) {
    for (float t = 0; t <= 1; t += .1) {
      leftLanes.add(cubicBezier(lp0, lp1, lp2, lp3, t));
      rightLanes.add(cubicBezier(rp0, rp1, rp2, rp3, t));
    }
    return this;
  }

  PVector cubicBezier(PVector p0, PVector p1, PVector p2, PVector p3, float t) {
    PVector pFinal = new PVector();
    pFinal.x = pow(1-t, 3)*p0.x + 3*pow(1-t, 2)*t*p1.x + 3*(1-t)*t*t*p2.x + t*t*t*p3.x;
    pFinal.y = pow(1-t, 3)*p0.y + 3*pow(1-t, 2)*t*p1.y + 3*(1-t)*t*t*p2.y + t*t*t*p3.y;
    return pFinal;
  }
}
