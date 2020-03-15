import 'dart:math';

import 'package:chart_animate_flutter/chart_data.dart';
import 'package:chart_animate_flutter/point.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'my_app.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(MyApp());
}

int numberOfPoints = 10;

List<ChartData> generateCharts() {
  var chart1 =
      ChartData("5km 13-02-2020", "axisX", "axisY", getRandomPoints(numberOfPoints));
  var chart2 =
      ChartData("10km 13-02-2020", "axisX", "axisY", getRandomPoints(numberOfPoints));
  var chart3 =
      ChartData("12.5km 13-02-2020", "axisX", "axisY", getRandomPoints(numberOfPoints));
  return List.of([chart1, chart2, chart3]);
}

List<Point> getRandomPoints(int n) {
  Random random = Random();
  var differenceList = List<double>();
  double difference = 5;
  for (var j = 0; j < difference; j++) {
    if (random.nextInt(2) == 1) {
      differenceList.addAll(List.filled((n / difference).round(), -1));
    } else {
      differenceList.addAll(List.filled((n / difference).round(), 1));
    }
  }
  var points = List<Point>();
  double lastValue = 50;
  points.add(Point(
      0,
      lastValue + (random.nextDouble() * differenceList.first) * difference,
      "Point 0"));
  for (var i = 1; i < n; i++) {
    points.add(Point(
        100 / n * (i + random.nextDouble()),
        lastValue + (random.nextDouble() * differenceList[i]) * difference,
        "Point $i"));
  }
  points.add(Point(
      100,
      lastValue + (random.nextDouble() * differenceList.last) * difference,
      "Point $n"));
  return points;
}
