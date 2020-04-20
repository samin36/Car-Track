class Particle {
  PVector pos;
  ArrayList<PVector> rays;
  double[] rayDistances;
  float r;
  boolean hitBoundary;
  float fitness; //how long particle stays alive
  double rayDistanceSum;
  NeuralNet brain;
  Particle(float x, float y) {
    pos = new PVector(x, y);
    rays = new ArrayList<PVector>();
    for (float angle = 0; angle < TWO_PI; angle += PI/2) {
      rays.add(PVector.fromAngle(angle));
    }
    rayDistances = new double[rays.size()];
    rayDistanceSum = 0;
    r = 20;
    hitBoundary = false;
    fitness = 0;
    //Input to brains is the rays
    //64 Hidden Layers?
    //Output is either moving left or right
    brain = new NeuralNet(null, rayDistances.length, 64, 1);
  }

  Particle() {
    this(width/2, height - 50);
  }

  void setPos(float x, float y) {
    pos.x = x;
    pos.y = y;
  }

  void showRayHints() {
    stroke(255, 0, 0);
    strokeWeight(r * .15);
    for (PVector ray : rays) {
      line(pos.x, pos.y, pos.x + ray.x * r, pos.y + ray.y * r);
    }
  }

  void show() {
    noStroke();
    fill(255);
    ellipse(pos.x, pos.y, r, r);
  }

  void incrementFitness() {
    fitness += 0.001;
  }

  void lookAt(ArrayList<Boundary> boundaries) {
    float x1 = pos.x;
    float y1 = pos.y;
    int rayNum = 0;
    for (PVector ray : rays) {
      float x2 = pos.x + ray.x;
      float y2 = pos.y + ray.y;
      float t, u;
      PVector closestPoint = null;
      double closestPointDist = (float) Integer.MAX_VALUE;
      for (int j = 0; j < boundaries.size(); j++) {
        Boundary wall = boundaries.get(j);
        ArrayList<PVector> lanes = wall.getLanes();
        for (int i = 0; i < lanes.size() - 1; i++) {
          if (i == wall.leftLanes.size() - 1) {
            //Switch to rightLane. Need to do this because examining current and next lane point below. 
            //One could be from left lane and other could be from right
            i++;
          }
          PVector laneA = lanes.get(i), laneB = lanes.get(i + 1);
          float x3 = laneA.x;
          float x4 = laneB.x;
          float y3 = laneA.y;
          float y4 = laneB.y;

          t = (x1 - x3)*(y3 - y4) - (y1 - y3)*(x3 - x4);
          t /= (x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4);
          u = (x1 - x2)*(y1 - y3) - (y1 - y2)*(x1 - x3);
          u /= (x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4);
          u *= -1;
          if (t >= 0 && u >= 0 && u <= 1.0) {
            float pointX = x1 + t * (x2 - x1);
            float pointY = y1 + t * (y2 - y1);
            PVector point = new PVector(pointX, pointY);
            double pointDist = PVector.dist(point, pos);
            if (pointDist < closestPointDist) {
              closestPointDist = pointDist;
              closestPoint = point;
            }
          }
        }
      }
      if (closestPoint != null) {
        stroke(255, 0, 0);
        strokeWeight(r * .10);
        line(pos.x, pos.y, closestPoint.x, closestPoint.y);
        float angle = abs(atan2(ray.y, ray.x));
        //println("angle: ", angle);
        if (abs(angle - PI) <= 0.1 && pos.x <= closestPoint.x) {
          hitBoundary = true;
          fitness = 0;
        } else if (abs(angle) <= 0.1 && pos.x >= closestPoint.x) {
          hitBoundary = true;
          fitness = 0;
        } else if (closestPointDist < 5) {
          hitBoundary = true;
          fitness = 0;
        } else if (pos.x <= 0 || pos.x >= width) {
          hitBoundary = true;
          fitness = 0;
        } else if (pos.y >= height || pos.y <= 0) {
          hitBoundary = true;
          fitness = 0;
        }
        rayDistances[rayNum] = closestPointDist;
        rayDistanceSum += closestPointDist;
      }
      rayNum++;
    }
  }

  void thinkAndAct() {
    //Feedforward neural network
    for (int i = 0; i < rayDistances.length; i++) {
      rayDistances[i] /= rayDistanceSum;
    }
    double[] output = brain.feedForward(rayDistances);
    if (output[0] > 0.5) {
      pos.x += 25;
    } else {
      pos.x -= 25;
    }
    rayDistances = new double[rayDistances.length];
    rayDistanceSum = 0;
  }

  NeuralNet getBrain() {
    return brain.cloneNetwork();
  }

  void setBrain(NeuralNet brain) {
    this.brain = brain;
  }

  void mutate() {
    brain.mutateNetwork(.01);
  }
}
