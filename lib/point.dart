
class Point{
  var name = "";
  double x;
  double y;

  Point(double x, double y, String name){
    this.name = name;
    this.x = x;
    this.y = y;
  }

  @override
  String toString() {
    return 'Point{name: $name, x: $x, y: $y}';
  }


}