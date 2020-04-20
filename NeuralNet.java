/*
Custom Neural Network Library
 Created By: Shrey Amin
 */
public class NeuralNet {

  private final int[] NEURON_IN_LAYERS;
  private final int NUM_LAYERS;
  private final int INPUT_SIZE;
  private final int OUTPUT_SIZE;

  /*
    Represents the output associated with each layer. The first index
   represents the layer and the second represents the neuron in that layer.
   To get the output of the 3rd neuron in the 5th layer:
   output[4][2]
   Format: outputs[current layer][current neuron]
   */
  private double[][] outputs;

  /*
    Represents the bias incoming to neurons in a particular layer. To get the
   bias for the 3rd neuron in 5th layer: bias[4][2]
   Format: bias[current layer][current neuron]
   */
  private double[][] bias;

  /*
    Represents the errors associated with each neuron.
   Format: errros[current layer][current neuron]
   */
  private double[][] errors;

  /*
        Represents the sigmoid derivative of each neuron.
   Format: sigmoidDeriv[current layer][current neuron]
   */

  private double[][] sigmoidDeriv;

  /*
    Represents the weights incoming to a neuron in layer from a neuron in
   previous layer. To get the incoming weight for 9rd neuron in the 5th
   layer from the 2nd neuron in the previous layer: weights[4][8][1].
   Format: weights[current layer][current neuron][neuron in previous layer]
   */
  private double[][][] weights;

  public NeuralNet(int... layers) {
    this(null, layers);
  }

  public NeuralNet(NeuralNet toCopyFrom, int... layers) {
    this.NEURON_IN_LAYERS = layers;
    this.NUM_LAYERS = layers.length;
    this.INPUT_SIZE = layers[0];
    this.OUTPUT_SIZE = layers[NUM_LAYERS - 1];

    this.outputs = new double[NUM_LAYERS][];
    this.bias = new double[NUM_LAYERS][];
    this.errors = new double[NUM_LAYERS][];
    this.sigmoidDeriv = new double[NUM_LAYERS][];
    this.weights = new double[NUM_LAYERS][][];

    if (toCopyFrom == null) {
      setupNetwork();
    } else {
      this.outputs = toCopyFrom.outputs.clone();
      this.bias = toCopyFrom.bias.clone();
      this.errors = toCopyFrom.errors.clone();
      this.sigmoidDeriv = toCopyFrom.sigmoidDeriv.clone();
      this.weights = toCopyFrom.weights.clone();
    }
  }

  ///*
  //Converts the json file into an instance of the NeuralNet class
  // */
  //public static NeuralNet loadNetwork(String jsonSave) {
  //    Gson gson = new Gson();
  //    return gson.fromJson(jsonSave, NeuralNet.class);
  //}

  private void setupNetwork() {
    for (int i = 0; i < NUM_LAYERS; i++) {
      this.outputs[i] = NeuralNetTools.randomArray(NEURON_IN_LAYERS[i], -1.0, 1.0);
      this.bias[i] = NeuralNetTools.randomArray(NEURON_IN_LAYERS[i], -1.0, 1.0);
      this.errors[i] = new double[NEURON_IN_LAYERS[i]];
      this.sigmoidDeriv[i] = new double[NEURON_IN_LAYERS[i]];

      //Since there are no incoming weights to the input layer, skip them
      if (i > 0) {
        this.weights[i] = NeuralNetTools.randomArray(NEURON_IN_LAYERS[i], NEURON_IN_LAYERS[i - 1], -1.0, 1.0);
      }
    }
  }

  /*
    Performs the feed forward process of the neural network
   */
  public double[] feedForward(double... inputs) {
    if (inputs.length != INPUT_SIZE) {
      System.out.println("Mistmatch");
      return null;
    }
    outputs[0] = inputs;
    for (int layer = 1; layer < NUM_LAYERS; layer++) {
      for (int neuron = 0; neuron < NEURON_IN_LAYERS[layer]; neuron++) {
        double weightedSum = 0.0;
        for (int prevNeuron = 0; prevNeuron < NEURON_IN_LAYERS[layer - 1]; prevNeuron++) {
          weightedSum += outputs[layer - 1][prevNeuron] * weights[layer][neuron][prevNeuron];
        }
        weightedSum += bias[layer][neuron];
        outputs[layer][neuron] = sigmoid(weightedSum);
        sigmoidDeriv[layer][neuron] = (outputs[layer][neuron]) * (1 - outputs[layer][neuron]);
      }
    }
    return outputs[NUM_LAYERS - 1];
  }

  /*
    Handles the backpropagation process of the neural network
   */
  public void train(double[] inputs, double[] target, double learningRate) {
    if (inputs.length != INPUT_SIZE || target.length != OUTPUT_SIZE) {
      return;
    }
    feedForward(inputs);
    backpropagateError(target);
    updateWeights(learningRate);
  }

  /*
    Handles the backpropagation of the error
   */
  private void backpropagateError(double... target) {
    for (int layer = NUM_LAYERS - 1; layer > 0; layer--) {
      for (int neuron = 0; neuron < NEURON_IN_LAYERS[layer]; neuron++) {
        if (layer == NUM_LAYERS - 1) {
          //This is for handling the output layer
          errors[layer][neuron] = outputs[layer][neuron] - target[neuron];
        } else {
          double error = 0.0;
          for (int nextLayerNeuron = 0; nextLayerNeuron < NEURON_IN_LAYERS[layer + 1]; nextLayerNeuron++) {
            error += errors[layer + 1][nextLayerNeuron] * weights[layer + 1][nextLayerNeuron][neuron];
          }
          errors[layer][neuron] = error;
        }
      }
    }
  }

  /*
    Handles the updating weights process of the neural network. It also updates the biases in the process.
   */
  private void updateWeights(double learningRate) {
    for (int layer = NUM_LAYERS - 1; layer > 0; layer--) {
      for (int neuron = 0; neuron < NEURON_IN_LAYERS[layer]; neuron++) {
        double delta = -learningRate * errors[layer][neuron] * sigmoidDeriv[layer][neuron];
        for (int prevNeuron = 0; prevNeuron < NEURON_IN_LAYERS[layer - 1]; prevNeuron++) {
          weights[layer][neuron][prevNeuron] += delta * outputs[layer - 1][prevNeuron];
        }
        bias[layer][neuron] += delta;
      }
    }
  }

  /*
    Performs the sigmoid activation function on the weighted sum
   */
  private double sigmoid(double weightedSum) {
    return 1d / (1 + Math.exp(-weightedSum));
  }

  /*
    Converts the NeuralNet class into a JSON string and returns it;
   */
  //public String saveToJson() {
  //    Gson gson = new GsonBuilder().setPrettyPrinting().create();
  //    return gson.toJson(this);
  //}

  /*
    Creates a copy of the current network and returns it
   */
  public NeuralNet cloneNetwork() {
    NeuralNet clonedNetwork = new NeuralNet(this, this.NEURON_IN_LAYERS);
    return clonedNetwork;
  }

  /*
    Mutates the current neural network
   */
  public void mutateNetwork(double mutationRate) {
    if (Math.random() < mutationRate) {
      setupNetwork();
    }
  }


  public int[] getNEURON_IN_LAYERS() {
    return NEURON_IN_LAYERS;
  }

  public int getNUM_LAYERS() {
    return NUM_LAYERS;
  }

  public int getINPUT_SIZE() {
    return INPUT_SIZE;
  }

  public int getOUTPUT_SIZE() {
    return OUTPUT_SIZE;
  }

  public double[][] getOutputs() {
    return outputs;
  }

  public void setOutputs(double[][] outputs) {
    this.outputs = outputs;
  }

  public double[][] getBias() {
    return bias;
  }

  public void setBias(double[][] bias) {
    this.bias = bias;
  }

  public double[][] getErrors() {
    return errors;
  }

  public void setErrors(double[][] errors) {
    this.errors = errors;
  }

  public double[][] getSigmoidDeriv() {
    return sigmoidDeriv;
  }

  public void setSigmoidDeriv(double[][] sigmoidDeriv) {
    this.sigmoidDeriv = sigmoidDeriv;
  }

  public double[][][] getWeights() {
    return weights;
  }

  public void setWeights(double[][][] weights) {
    this.weights = weights;
  }
}
