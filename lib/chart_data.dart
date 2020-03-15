import 'package:chart_animate_flutter/point.dart';

class ChartData{
  String title;
  String nameAxisX;
  String nameAxisY;
  List<Point> points;
  ChartData([this.title, this.nameAxisX, this.nameAxisY, List<Point> points]){
    this.points = points;
  }

  @override
  String toString() {
    return 'ChartData{title: $title, nameAxisX: $nameAxisX, nameAxisY: $nameAxisY, points: $points}';
  }

}