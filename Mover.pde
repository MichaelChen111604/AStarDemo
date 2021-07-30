public class Mover {
  // speed describes the pixels moved per second
  float x, y, speed = 300;
  // Top represents first point to move
  Stack<Point> pointsOrder;
  Stack<Edge> edgesOrder;
  Point nextPoint;
  
  Mover(float X, float Y) {
    x = X;
    y = Y;
    pointsOrder = new Stack<Point>();
    edgesOrder = new Stack<Edge>();
  }
  
  // Calculate path and fill pointsOrder and edgesOrder
  void findPath(Point start, Point end) {
    highlightAlgorithm = true;
    highlightAlgorithmStartTime = millis();
    if (start == null || end == null) { return; }
    PointPQ Open = new PointPQ();
    Open.insert(start);
    
    while (!Open.isEmpty()) {
      Point Top = Open.dequeue();
      
      // end found
      if (Top.equals(end)) {
        Top.pathTo.searched = true;
        // Step through prevPoint's ancestry and push onto pointStack and edgeStack //<>//
        while (Top != null) {
          pointsOrder.Push(Top);
          if (Top.pathTo != null) {
            edgesOrder.Push(Top.pathTo);
          }
          Top = Top.pointTo;
        }
        // Setup for moving
        currentMode = Mode.InProgress;
        nextPoint = pointsOrder.Pop();
        return;
      }
      
      // end not found- keep searching
      Top.closed = true;
      if (Top.pathTo != null) Top.pathTo.searched = true;
      for (Edge connectedEdge : Top.connectedEdges) {
        Point neighbor = (connectedEdge.point2 == Top) ? connectedEdge.point1 : connectedEdge.point2;
        // neighbor is in the priority queue and new neighbor startWeight is lower
        if (neighbor.index != 0 && neighbor.startWeight > Top.startWeight + dist(Top.x, Top.y, neighbor.x, neighbor.y)) {
          // change neighbor's startWeight and path and rearrange the priority queue
          Open.changeStartWeight(neighbor, Top.startWeight + dist(Top.x, Top.y, neighbor.x, neighbor.y));  
          neighbor.pathTo = connectedEdge;
          neighbor.pointTo = Top;
        }
        // neighbor has been searched and new neighbor startWeight is lower
        else if (neighbor.closed && neighbor.startWeight > Top.startWeight + dist(Top.x, Top.y, neighbor.x, neighbor.y)) {
          // un-close neighbor, add it to Open with lower startWeight and revised path
          neighbor.startWeight = Top.startWeight + dist(Top.x, Top.y, neighbor.x, neighbor.y);
          neighbor.closed = false;
          connectedEdge.searched = false;
          neighbor.pathTo = connectedEdge;
          neighbor.pointTo = Top;
          Open.insert(neighbor);
        }
        // neighbor not in Open and hasn't been searched - add neighbor to Open
        if (neighbor.index == 0 && !neighbor.closed) {
          neighbor.startWeight = Top.startWeight + dist(Top.x, Top.y, neighbor.x, neighbor.y);
          neighbor.pointTo = Top;
          neighbor.pathTo = connectedEdge;
          Open.insert(neighbor);
        }
      }
    }
    // WeightedPointPQ empty means no path found
    if (Open.isEmpty()) {
      displayNoPathFound();
      x = -100;
      y = -100;
      currentMode = Mode.Selecting;
      finishPath();
    }
    else {
      println("Error: Open is empty, but hasn't found Top yet");
    }
  }
  
  // called every frame to move along path
  void move() {
    if (dist(x, y, nextPoint.x, nextPoint.y) < (float)speed / (float)fps) {
      // end point reached
      if (pointsOrder.length == 0)
        finishPath();
      // next point reached
      else {
        nextPoint = pointsOrder.Pop();
        activeEdge = edgesOrder.Pop();
      }
    }
    // move
    if (nextPoint != null) {
      PVector moveVector = new PVector(nextPoint.x - x, nextPoint.y - y);
      moveVector = moveVector.normalize().mult((float)speed / (float)fps);
      x += moveVector.x;
      y += moveVector.y;
    }
  }
  
}
