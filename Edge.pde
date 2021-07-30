public class Edge {
  public Point point1;
  public Point point2;
  public float length;
  public boolean searched;
  
  Edge(Point p1, Point p2) {
      point1 = p1;
      point2 = p2;
      point1.connectedEdges = (Edge[]) append(point1.connectedEdges, this);
      point2.connectedEdges = (Edge[]) append(point2.connectedEdges, this);
      searched = false;
      length = dist(p1.x, p2.x, p1.y, p2.y);  
  }
  
  public String toString() {
    return point1.toString() + "-" + point2.toString();
  }
}
