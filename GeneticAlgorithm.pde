class GA {

  GA() {
  }

  void sumAndNormalizeFitness(ArrayList<Particle> particles) {
    if (particles.size() == 0) {
      return;
    }
    float sum = 0;
    for (Particle particle : particles) {
      sum += particle.fitness;
    }
    for (Particle particle : particles) {
      particle.fitness /= sum;
    }
  }

  ArrayList<Particle> generateNextGeneration(ArrayList<Particle> prev) {
    sumAndNormalizeFitness(prev);
    ArrayList<Particle> newGen = new ArrayList<Particle>();
    while (newGen.size() < prev.size()) {
      Particle child = pickOne(prev);
      if (child == null) {
        return null;
      }
      newGen.add(child);
    }
    return newGen;
  }

  Particle pickOne(ArrayList<Particle> particles) {
    int index = 0;
    float r = random(1);
    while (r > 0) {
      r -= particles.get(index).fitness;
      index++;
    }
    index--;
    Particle chosenOne = particles.get(index);
    Particle child = new Particle();
    child.setBrain(chosenOne.getBrain());
    child.mutate();
    return child;
  }
}
