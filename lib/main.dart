import 'dart:ffi' as ffi;
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/rendering.dart';


void main() {
  runApp(const MyApp());
}

Timer? timer;



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decimal Clock',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Decimal Clock'),
    );
  }

  
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();

  
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int dec_hour = 0;
  int dec_minute = 0;
  int dec_second = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  void _updateClock()
  {
    final now = DateTime.now();
    final today = new DateTime(now.year, now.month, now.day);
    final difference = now.difference(today);
    // 86 400 000 milliseconds per day
    setState((){
      dec_hour = (difference.inSeconds/ 8640).toInt();
      dec_minute = (difference.inSeconds/864).toInt()%100;
      dec_second = (difference.inMilliseconds/8640).toInt()%100;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            DecClockWidget(
            ),
            Text(
              '$dec_hour:$dec_minute:$dec_second',
              style: TextStyle(fontFamily: 'Aileron Black', fontSize: 50),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateClock());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

}

class DecClockWidget extends StatefulWidget{
  @override
  _DecClockWidget createState() => _DecClockWidget();
}


class _DecClockWidget extends State<DecClockWidget> {
  Duration timeOfDay = Duration();
  int dec_hour = 0;
  int dec_minute = 0;
  int dec_second = 0;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 33), (Timer t) => _updateClock());
  }
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DecClock(timeOfDay),
      child: Container(
        width: 500,
        height: 500,
      ),
    );
  }

  void _updateClock()
  {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    //today.isUtc

    // 86 400 000 milliseconds per day
    setState((){
      timeOfDay = now.difference(today);
      dec_hour = (timeOfDay.inSeconds/ 8640).toInt();
      dec_minute = (timeOfDay.inSeconds/864).toInt()%100;
      dec_second = (timeOfDay.inMilliseconds/8640).toInt()%100;
    });
  }
}

class DecClock extends CustomPainter {
  final Duration timeOfDay;

  DecClock(this.timeOfDay);

  double percentToRad(double val)
  {
    return pi*2/(100/val);
  }

  void drawHourLine(Canvas canvas,Offset centerOffset,double radian)
  {
    final inner = 180;
    final outer = 200;

    var innerOffset = Offset(centerOffset.dx+sin(radian)*inner, centerOffset.dy-cos(radian)*inner);
    var outerOffset = Offset(centerOffset.dx+sin(radian)*outer, centerOffset.dy-cos(radian)*outer);

    var paint = Paint()..color = Color.fromARGB(255, 37, 22, 21) ..strokeWidth = 4;
    canvas.drawLine(innerOffset,outerOffset,paint);
  }
  @override
  void paint(Canvas canvas, Size size) {
    final milliSize = 200;
    final secSize = 160;
    final minSize = 130;
    final hourSize = 100;

    var center = size / 2;
    var centerOffset = Offset(center.width, center.height);
    
    var milliSeconds = percentToRad((timeOfDay.inMicroseconds/86400)%100);
    var seconds = percentToRad((timeOfDay.inMilliseconds/8640)%100);
    var minute = percentToRad((timeOfDay.inSeconds/864)%100);
    var hour = percentToRad((timeOfDay.inHours/ 24*100));
   // percentToRad((timeOfDay.inHours/ 24*10));

    var paint = Paint()..color = Color.fromARGB(255, 129, 70, 65);
    var minutesPaint = Paint()..color = Color.fromARGB(255, 37, 22, 21) ..strokeWidth = 4;
    var hourPaint = Paint()..color = Color.fromARGB(255, 82, 22, 20) ..strokeWidth = 6;
    var dayPaint = Paint()..color = Color.fromARGB(255, 2, 63, 7) ..strokeWidth = 10;

    var secondsPointerOffset = Offset(center.width+sin(milliSeconds)*milliSize, center.height-cos(milliSeconds)*milliSize);
    var minutesPointerOffset = Offset(center.width+sin(seconds)*secSize, center.height-cos(seconds)*secSize);
    var hoursPointerOffset = Offset(center.width+sin(minute)*minSize, center.height-cos(minute)*minSize);
    var dayPointerOffset = Offset(center.width+sin(hour)*hourSize, center.height-cos(hour)*hourSize);

    canvas.drawLine(centerOffset,secondsPointerOffset,paint);
    canvas.drawLine(centerOffset,minutesPointerOffset,minutesPaint);
    canvas.drawLine(centerOffset,hoursPointerOffset,hourPaint);
    canvas.drawLine(centerOffset,dayPointerOffset,dayPaint);

    drawHourLine(canvas,centerOffset,0);
    drawHourLine(canvas,centerOffset,pi*.25);
    drawHourLine(canvas,centerOffset,pi*.5);
    drawHourLine(canvas,centerOffset,pi*.75);
    drawHourLine(canvas,centerOffset,pi);
    drawHourLine(canvas,centerOffset,pi*1.25);
    drawHourLine(canvas,centerOffset,pi*1.5);
    drawHourLine(canvas,centerOffset,pi*1.75);


    /*
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.width, center.height),
        width: 50,
        height: 50,
      ),
      0.4,
      2 * pi - 0.8,
      true,
      paint,
    );*/
  }

  
/*
  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      // Annotate a rectangle containing the picture of the sun
      // with the label "Sun". When text to speech feature is enabled on the
      // device, a user will be able to locate the sun on this picture by
      // touch.
      Rect rect = Offset.zero & size;
      final double width = size.shortestSide * 0.4;
      rect = const Alignment(0.8, -0.9).inscribe(Size(width, width), rect);
      return <CustomPainterSemantics>[
        CustomPainterSemantics(
          rect: rect,
          properties: const SemanticsProperties(
            label: 'Sun',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }
  */

  // Since this Sky painter has no fields, it always paints
  // the same thing and semantics information is the same.
  // Therefore we return false here. If we had fields (set
  // from the constructor) then we would return true if any
  // of them differed from the same fields on the oldDelegate.
  @override
  bool shouldRepaint(DecClock oldDelegate) => true;
  @override
  bool shouldRebuildSemantics(DecClock oldDelegate) => true;
}