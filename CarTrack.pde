Tracks tracks;
ArrayList<Particle> currGen, deadParticles;
GA ga;
int popSize = 1000;
boolean sav = false;
void setup() {
  size(600, 900, P2D);
  tracks = new Tracks(width * .3, height * .35);
  currGen = new ArrayList<Particle>();
  deadParticles = new ArrayList<Particle>();
  for (int i = 0; i < popSize; i++) {
    currGen.add(new Particle());
  }
  ga = new GA();
}

void draw() {
  background(0);
  tracks.moveTracks(10);
  tracks.updateTracks();
  tracks.showTracks();

  for (int i = 0; i < currGen.size(); i++) {
    Particle pt = currGen.get(i);
    pt.lookAt(tracks.boundaries);
    if (pt.hitBoundary) {
      deadParticles.add(currGen.get(i));
      currGen.remove(i);
      i--;
      continue;
    }
    pt.thinkAndAct();
    pt.showRayHints();
    pt.show();
  }
  if (sav) {
    saveFrame("imgs/cartrack-#####.jpg");
  }

  if (currGen.size() == 0) {
    currGen = ga.generateNextGeneration(deadParticles);
    deadParticles.clear();
  }
}

void mousePressed() {
  sav = true;
}
