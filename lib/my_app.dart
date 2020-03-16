import 'dart:ui' as ui;

import 'package:chart_animate_flutter/chart_data.dart';
import 'package:chart_animate_flutter/point.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'main.dart';

double width(context) => MediaQuery.of(context).size.width;

double height(context) => MediaQuery.of(context).size.height;

double chart_height(context) => height(context) * 0.3;

class PageOffsetNotifier with ChangeNotifier {
  double _offset = 0;
  double _page = 0;

  PageOffsetNotifier(PageController pageController) {
    pageController.addListener(() {
      _offset = pageController.offset;
      _page = pageController.page;
      notifyListeners();
    });
  }

  double get offset => _offset;

  double get page => _page;
}

class ChartDataNotifier with ChangeNotifier {
  List<ChartData> _chartdata = List();

  ChartDataNotifier() {
    _chartdata = generateCharts();
    notifyListeners();
  }

  void generate() {
    _chartdata = generateCharts();
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF383838),
        accentColor: Color(0xFFA0A0A0),
        scaffoldBackgroundColor: Color(0x616161),

        // Define the default font family.
        fontFamily: 'Roboto',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline5: TextStyle(
              fontSize: 36.0,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w200),
          bodyText2: TextStyle(fontSize: 24.0),
        ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChartDataNotifier>(
          create: (_) => ChartDataNotifier(),
        ),
        ChangeNotifierProvider<PageOffsetNotifier>(
          create: (_) => PageOffsetNotifier(_pageController),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            "Chart Animation",
            style: GoogleFonts.changa(),
          ),
          actions: <Widget>[
            Consumer<ChartDataNotifier>(
              builder: (BuildContext context, ChartDataNotifier value,
                  Widget child) {
                return IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.grey[300],
                    ),
                    onPressed: () {
                      Provider.of<ChartDataNotifier>(context, listen: false)
                          .generate();
                    });
              },
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Consumer<ChartDataNotifier>(
              builder: (_, nofiier, child) {
                return PageView(
                  physics: ClampingScrollPhysics(),
                  controller: _pageController,
                  children: <Widget>[
                    ChartInfoPage(0),
                    ChartInfoPage(1),
                    ChartInfoPage(2),
                  ],
                );
              },
            ),
            IgnorePointer(
              child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: Container(
                  alignment: Alignment.topCenter,
                  child: Consumer2<PageOffsetNotifier, ChartDataNotifier>(
                    builder: (_, pageOffset, chartData, child) {
                      return CustomPaint(
                        painter:
                            ChartPainter(pageOffset.page, chartData._chartdata),
                        child: Container(
                          height: chart_height(context),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  double offset;
  final double animationValue;
  double width;
  double height;
  List<ChartData> charts;

  ChartData currentChart;
  ChartData nextChart;

  ChartPainter(this.animationValue, this.charts);

  double interpolate(double x) {
    return width / 2 + (x - width / 2) * animationValue;
  }

  @override
  void paint(Canvas canvas, Size size) {
    getAnimationValueAndChartData(animationValue);
    var paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final width = size.width;
    final height = size.height;
    final pointMode = ui.PointMode.polygon;
    final points = List<Offset>();
    var index = 0;
    currentChart.points.forEach((element) {
      var a = element;
      var b = nextChart.points[index];
      index++;
      points.add(Offset(
        (a.x + ((b.x - a.x) * offset)) * width / 100,
        ((a.y + (b.y - a.y) * offset)) * height / 100,
      ));
    });

    canvas.drawPoints(pointMode, points, paint);
    canvas.drawLine(Offset(10, 10), Offset(10, height), paint);
    canvas.drawLine(Offset(0, height - 10), Offset(width, height - 10), paint);
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return (oldDelegate.animationValue != animationValue) !=
        (oldDelegate.currentChart != currentChart);
  }

  void getAnimationValueAndChartData(double animationValue) {
    currentChart = charts[animationValue.toInt()];
    if (animationValue.toInt() + 1 < charts.length) {
      nextChart = charts[animationValue.toInt() + 1];
    } else {
      nextChart = currentChart;
    }
    offset = animationValue - animationValue.toInt();
  }
}

class ChartInfoPage extends StatelessWidget {
  var i = 0;
  ChartInfoPage(this.i);

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ChartDataNotifier>(context);
    var chartdata = data._chartdata[i];
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            child: Row(children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: RichText(
                  text: TextSpan(
                      style: GoogleFonts.raleway(
                          fontSize:
                              Theme.of(context).textTheme.bodyText2.fontSize),
                      children: [
                        TextSpan(text: chartdata.title.split(" ").first + " "),
                      ]),
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: RichText(
                  text: TextSpan(
                      style: GoogleFonts.raleway(
                          fontSize:
                              Theme.of(context).textTheme.bodyText2.fontSize),
                      children: [
                        TextSpan(
                            text: chartdata.title.split(" ").last,
                            style: GoogleFonts.josefinSlab(
                                decoration: TextDecoration.underline))
                      ]),
                ),
              ),
            ]),
          ),
          Container(
            height: chart_height(context),
          ),
          Expanded(
            child: Container(
              color: Colors.white12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: ListView.builder(
                        itemBuilder: (_, index) => (index == 0)? PointCard("Name", "X", "Y") : PointCard(chartdata.points[index-1].name,chartdata.points[index-1].x.round().toString(),chartdata.points[index-1].y.round().toString()),
                        itemCount: chartdata.points.length+1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class PointCard extends StatelessWidget{
  String title;
  String x;
  String y;
  PointCard(this.title,this.x,this.y);


  @override
  Widget build(BuildContext context) {
      return  Card(
        color: Colors.black54,
        child: IntrinsicHeight(
          child: Row(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(title)),
              Spacer(),
              VerticalDivider(
                color: Colors.white,
                thickness: 1.0,
              ),
              Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    width: 50,
                    child: Center(
                      child: Text(x),
                    ),
                  )),
              VerticalDivider(
                width: 2.0,
                color: Colors.white,
                thickness: 1.0,
              ),
              Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    width: 50,
                    child: Center(
                      child: Text(y),
                    ),
                  )),
            ],
          ),
        ),
      );
  }

}