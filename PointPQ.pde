// point Priority Queue implemented using binary heap
class PointPQ {
  // Store the Points in an array
  Point[] PQ;
  
  PointPQ() {
    // First element of PQ is always null 
    // (makes it easier to traverse by dividing/multiplying by 2)
    PQ = new Point[1];
  }
  
  boolean isEmpty() { return PQ.length == 1; }
  
  // Swap the values of the Points at these indices
  void swap(int a, int b) {
    Point aPoint = PQ[a];
    PQ[a] = PQ[b];
    PQ[b] = aPoint;
    PQ[a].index = a;
    PQ[b].index = b;
  }
   
  void insert(Point point) {
    // Add point to the bottom then swim it to the top
    point.index = PQ.length;
    PQ = (Point[]) append(PQ, point);
    swim(PQ.length - 1);
  }
  
  // Pop and return the lowest-weight point- return null if empty
  Point dequeue() {
    if (PQ.length == 1) { return null; }
    Point top = PQ[1];
    // Swap the first and last elements, remove last slot, then sink the new first
    swap(1, PQ.length - 1);
    PQ = (Point[]) shorten(PQ);
    top.index = 0;
    sink(1);
    return top;
  }
  
  // Change the startWeight of point and re-order the heap
  void changeStartWeight(Point point, float newStartWeight) {
    point.startWeight = newStartWeight;
    // we only ever change the start weight if it's shorter
    swim(point.index);
  }
  
  // Move PQ[point] up with key exchanges until it's in the correct spot
  void swim(int point) {
    // Parent of point is at point/2
    while (point > 1 && PQ[point / 2].getWeight() > PQ[point].getWeight()) {
      swap(point, point / 2);
      // swim the new point spot
      point /= 2;
    }
  }
  
  // Move PQ[point] down with key exchanges until it's in the correct spot
  void sink(int point) {
    // Children of point are at point * 2 and point * 2 + 1
    while (point * 2 < PQ.length) {
      // Index of child whose Point should be swapped with PQ[point]
      int lowerChild = 2 * point;
      // if PQ[lowerChild] has greater weight than its right sibling, increment lowerChild
      if (lowerChild < PQ.length - 1 && PQ[lowerChild].getWeight() > PQ[lowerChild + 1].getWeight()) { lowerChild++; }
      if (PQ[lowerChild].getWeight() < PQ[point].getWeight()) {
        swap(lowerChild, point);
        // Repeat the process, stepping down the heap
        point = lowerChild;
      } else break;
    }
  }
  
  public String toString() {
    String ret = "";
    for (int i = 1; i < PQ.length; i++) {
      ret += PQ[i].toString() + "; ";
    }
    return ret;
  }
  
}
