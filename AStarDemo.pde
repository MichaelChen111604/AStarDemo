Point[] points;
Edge[] edges;
Mover mover;
Point startPoint, endPoint;
Edge activeEdge;
PImage star;
int fps = 60;
int noPathFoundStartTime = -100;
int highlightAlgorithmStartTime = -100;
// Flag telling the program to create a mover
boolean startPathfinder = false;

// Describes the state the program is in
enum Mode {
  Selecting,
  Calculating,
  InProgress
}
Mode currentMode = Mode.Selecting;
boolean noPathFound = false, highlightAlgorithm = false;

// EDITABLE PARAMS
int numPoints = 90, pointRadius = 6, numEdges = 150, edgeWidth = 2, minPointDistance = 40, highlightAlgorithmDuration = 5000;
color startColor, endColor, activeEdgeColor, moverColor, highlightEdgeColor;

// Helper function to check if point location is valid
boolean intersectingOtherPoint(int x, int y, int currentPointsIndex) {
  for (int i = 0; i < currentPointsIndex; i++) { //<>//
    Point otherPoint = points[i];
    if (otherPoint != null && dist(x, y, otherPoint.x, otherPoint.y) < minPointDistance) {
      return true;
    }
  }
  return false;
}

// Helper function to generate valid point starting location (very sophisticated bogo algorithm)
int[] generatePointStart(int currentPointsIndex) {
  int x = (int)random(2 * pointRadius, width - 2 * pointRadius);
  int y = (int)random(2 * pointRadius, height - 2 * pointRadius);
  while (intersectingOtherPoint(x, y, currentPointsIndex)) { 
    x = (int)random(2 * pointRadius, width - 2 * pointRadius);
    y = (int)random(2 * pointRadius, height - 2 * pointRadius);
  }
  int[] ret = {x, y};
  return ret;
}

// Check edges array up to (not including) edgeIndex contains edge connecting (point, point)
boolean edgeExists(int edgeIndex, Point p1, Point p2) {
  for (int i = 0; i < edgeIndex; i++) {
    if (edges[i] != null) {
      if ((edges[i].point1 == p1 && edges[i].point2 == p2) || (edges[i].point1 == p2 && edges[i].point2 == p1)) return true;
    }
  }
  return false;
}

// Helper functions to shorten code
void drawPoint(Point point) {
  if (point != null) { 
      if (startPoint == point) { fill(startColor); }
      else if (endPoint == point) { fill(endColor); }
      else fill(255);
      ellipse(point.x, point.y, pointRadius, pointRadius); 
    }
}
void drawEdge(Edge edge) {
  if (edge != null) {
    stroke(255);
    if (edge.equals(activeEdge)) { fill(activeEdgeColor); }
    else if (edge.searched && highlightAlgorithm) { stroke(highlightEdgeColor); }
    if (!edge.equals(activeEdge)) { fill(0); }
    pushMatrix();
    // translate coordinate grid to center of edge
    translate((edge.point1.x + edge.point2.x)/2, (edge.point1.y + edge.point2.y)/2);
    
    // rotate coordinate grid so edge is correctly oriented
    if (edge.point1.x == edge.point2.x) { 
      rotate(PI/2);
    } else { 
      rotate(atan((float)(edge.point1.y - edge.point2.y)/(float)(edge.point1.x - edge.point2.x))); 
    }
    rect(0, 0, dist(edge.point1.x, edge.point1.y, edge.point2.x, edge.point2.y), edgeWidth);
    popMatrix();
  }
}

void displayNoPathFound() {
  noPathFoundStartTime = millis();
  noPathFound = true;
}

void finishPath() {
  for (Point p : points) {
    p.startWeight = 0;
    p.endWeight = 0;
    p.index = 0;
    p.closed = false;
    p.pathTo = null;
    p.pointTo = null;
  }
  currentMode = Mode.Selecting;
  endPoint = null;
  activeEdge = null;
  mover = null;
}

void setup() {
  fullScreen();
  background(0, 0, 0);
  stroke(255);
  frameRate(fps);
  
  startColor = color(0, 0, 255);
  endColor = color(255, 0, 0);
  activeEdgeColor = color(0, 255, 0);
  moverColor = color(255, 255, 0);
  highlightEdgeColor = color(255, 0, 255);
  
  // Variable setup
  points = new Point[numPoints];
  edges = new Edge[numEdges];
  star = loadImage("Star.png");

  // Generate points
  for (int i = 0; i < numPoints; i++) {
    int[] startLocation = generatePointStart(i);
    Point newPoint = new Point(startLocation[0], startLocation[1]);
    points[i] = newPoint;  //<>//
  }
  
  // Generate edges
  for (int i = 0; i < numEdges; i++) {
    Edge newEdge;
    Point point1, point2;
    do {
      point1 = points[(int)random(numPoints)];
      do { point2 = points[(int)random(numPoints)]; } while (point2.equals(point1));
    } while (edgeExists(i, point1, point2));
    newEdge = new Edge(point1, point2);
    edges[i] = newEdge;
  }
  rectMode(CENTER);
  ellipseMode(RADIUS);
  imageMode(CENTER);
}

void draw() {
  clear();
  // Draw state text
  fill(255, 255, 0);
  textSize(30);
  switch (currentMode) { 
    case Selecting: text("Select points", width / 2, 44); break;
    case Calculating: text("Calculating path...", width / 2, 44); println("Calculating"); break;
    case InProgress: text("Mover in progress", width / 2, 44); break;
  }
  // Stop displaying the noPathFound message after five seconds
  if (noPathFoundStartTime != -100 && millis() - noPathFoundStartTime >= 5000) {
    noPathFound = false;
  }
  // Stop highlighting stuff after highlightAlgorithmDuration milliseconds
  if (highlightAlgorithmStartTime != -100 && millis() - highlightAlgorithmStartTime >= highlightAlgorithmDuration) {
    highlightAlgorithm = false;
    highlightAlgorithmStartTime = -100;
    for (Edge e : edges) { 
      e.searched = false;
    }
  }
  if (noPathFound) {
    text("No path found", width / 2, height - 44);
  }
  
  // Draw edges and points
  for (Edge edge : edges) { drawEdge(edge); }
  for (Point point : points) { drawPoint(point); }
  // Draw active edge
  drawEdge(activeEdge);
  // Draw start and end point
  drawPoint(startPoint);
  drawPoint(endPoint);
  // Draw and move mover
  if (startPathfinder) {
    mover.findPath(startPoint, endPoint);
    startPathfinder = false;
  }
  if (currentMode == Mode.InProgress && mover != null) {
    image(star, mover.x, mover.y, 2 * pointRadius, 2 * pointRadius);
    mover.move();
  }
  if (highlightAlgorithm) {
    textSize(16);
    fill(color(255, 0, 0));
    for (Point p : points) {
      text(p.getWeight(), p.x, p.y);
    }
  }
}

void mouseClicked() {
  if (currentMode == Mode.Selecting) {
    for (Point point : points) {
      if (dist(point.x, point.y, pmouseX, pmouseY) < pointRadius) {
        if (mouseButton == LEFT) {
          // De-color previous start point, draw new start point
          Point prevStartPoint = startPoint;
          startPoint = point;
          drawPoint(prevStartPoint);
          drawPoint(startPoint);
        }
        else if (mouseButton == RIGHT) {
          // De-color previous end point, draw new end point
          Point prevEndPoint = endPoint;
          endPoint = point;
          drawPoint(prevEndPoint);
          drawPoint(endPoint);
        }
        // Begin pathfinding
        if (startPoint != null && endPoint != null) {
          for (Point p : points) {
            p.endWeight = dist(p.x, p.y, endPoint.x, endPoint.y);
          }
          currentMode = Mode.Calculating;
          mover = new Mover(startPoint.x, startPoint.y);
          startPathfinder = true;
        }
      }
    }
  }
}
