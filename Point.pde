public class Point {
  public int x, y;
  public Edge[] connectedEdges;
 
  // whether this point has been expanded (searched) in the A*
  boolean closed;
  // Point taken to get to this point
  public Point pointTo;
  // Edge taken to get to this point
  public Edge pathTo;
  // Distance travelled (along edges) from start to get to this point
  float startWeight;
  // Heuristic- distance on a straight line from this point to end
  float endWeight;
  // Index in the priority queue
  int index;
 
  Point(int X, int Y) {
    x = X;
    y = Y;
    connectedEdges = new Edge[0];
    closed = false;
    index = 0; // index 0 means that it isn't in the priority queue
    startWeight = 0; // This value will be set as the algorithm runs
    endWeight = 0; // This value will be set after both points are picked
  }
  
  public float getWeight() {
    return startWeight + endWeight;
  }
  
  public String toString() {
    return x + ", " + y;
  }
}
