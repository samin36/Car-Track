import java.util.Random;
/*
This class contains the tools needed to operate on the double arrays
 */
public class NeuralNetTools {


    /*
    Creates a random double array with given size and a range (inclusive on
    both ends).
     */
    public static double[] randomArray(int size, double low, double high) {
        if (size < 1) {
            return null;
        }
        double[] randArray = new double[size];
        for (int i = 0; i < size; i++) {
            randArray[i] = Math.random() * (high - low) + low;
        }
        return randArray;
    }

    /*
    Creates a random 2d double array with given number of rows, columns, and a range (inclusive on both ends)
     */
    public static double[][] randomArray(int rows, int cols, double low, double high) {
        if (rows < 1 || cols < 1) {
            return null;
        }
        double[][] randArray = new double[rows][cols];
        for (int r = 0; r < rows; r++) {
            randArray[r] = randomArray(cols, low, high);
        }
        return randArray;
    }




}
