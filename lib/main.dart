import 'dart:ffi' as ffi;
import 'dart:math' as math;
//import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart' as wrappers;
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
      scaffoldBackgroundColor: Color.fromARGB(255, 169, 175, 179),
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
  String dec_hour = "";
  String dec_minute = "";
  String dec_second = "";
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
     
    final milliseconds = difference.inMilliseconds/864;
    // 86 400 000 milliseconds per day
    
    var second_str= (milliseconds%100).floor().toString();
    var minute_str= ((milliseconds/100)%100).floor().toString();
    setState((){
      dec_second = AlwaysTwoNumberString(second_str);
      dec_minute = AlwaysTwoNumberString(minute_str);
      dec_hour = ((milliseconds/10000)%10).floor().toString();
    });
  }
  
  String AlwaysTwoNumberString(String str)
  {
    if(str.length == 1) return "0$str";
    return str;
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
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), */
    );
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 864), (Timer t) => _updateClock());
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
    timer = Timer.periodic(Duration(milliseconds: 864), (Timer t) => _updateClock());
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
        width: 400,
        height: 400,
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
      dec_minute = (timeOfDay.inSeconds/86.4).toInt()%100;
      dec_second = (timeOfDay.inMilliseconds/864).toInt()%100;
    });
  }
}

class DecClock extends CustomPainter {
  final Duration timeOfDay;

  DecClock(this.timeOfDay);
  


  double percentToRad(double val)
  {
    return math.pi*2/(100/val);
  }

  void drawHourLine(Canvas canvas,Offset centerOffset,double radian,Paint paint,double inner,double outer)
  {
  //  final inner = 180;
  //  final outer = 200;

    var innerOffset = Offset(centerOffset.dx+math.sin(radian)*inner, centerOffset.dy-math.cos(radian)*inner);
    var outerOffset = Offset(centerOffset.dx+math.sin(radian)*outer, centerOffset.dy-math.cos(radian)*outer);

   // var p = Paint()..color = Color.fromARGB(255, 37, 22, 21) ..strokeWidth = 4;
    canvas.drawLine(innerOffset,outerOffset,paint);
  }
  @override
  void paint(Canvas canvas, Size size) {
    final halfWidth = size.width*0.5;
    final milliSize = halfWidth*.8;
    final secSize = halfWidth*.7;
    final minSize = halfWidth*.6;
    final hourSize = halfWidth*.5;

    var center = size / 2;
    var centerOffset = Offset(center.width, center.height);
    
    final milliseconds = timeOfDay.inMilliseconds/864;
    var rad_milliSeconds = percentToRad(((milliseconds).floor()%100));
    var seconds = percentToRad((timeOfDay.inMilliseconds/86400)%100);
    var minute = percentToRad((timeOfDay.inSeconds/8640)%100);
    var hour = percentToRad((timeOfDay.inMinutes/ 1440*100));
   // percentToRad((timeOfDay.inHours/ 24*10));


    var paint = Paint()..color = Color.fromARGB(255, 85, 56, 53)..strokeWidth = 2;
    var minutesPaint = Paint()..color = Color.fromARGB(255, 37, 22, 21) ..strokeWidth = 4;
    var dayPaint = Paint()..color = Color.fromARGB(255, 2, 63, 7) ..strokeWidth = 10;

    var secondsPointerOffset = Offset(center.width+math.sin(rad_milliSeconds)*milliSize, center.height-math.cos(rad_milliSeconds)*milliSize);
    var minutesPointerOffset = Offset(center.width+math.sin(seconds)*secSize, center.height-math.cos(seconds)*secSize);
    var dayPointerOffset = Offset(center.width+math.sin(hour)*hourSize, center.height-math.cos(hour)*hourSize);

    var cornerPaint = Paint()..color = Color.fromARGB(255, 209, 139, 33) ..strokeWidth = 1;
    var innerPaint = Paint()..color = Color.fromARGB(255, 169, 174, 175) ..strokeWidth = 1;
    var insidePaint = Paint()..color = Color.fromARGB(255, 255, 255, 255) ..strokeWidth = 1;
    canvas.drawCircle(centerOffset, halfWidth*1.08, cornerPaint);
    canvas.drawCircle(centerOffset, halfWidth*1.06, insidePaint);
   // canvas.drawCircle(centerOffset, halfWidth*0.8, innerPaint);

    canvas.drawLine(centerOffset,secondsPointerOffset,paint);
    canvas.drawLine(centerOffset,minutesPointerOffset,minutesPaint);
    canvas.drawLine(centerOffset,dayPointerOffset,dayPaint);





    var mayorLine = Paint()..color = Color.fromARGB(255, 37, 22, 21) ..strokeWidth = 4;
    var minorLine = Paint()..color = Color.fromARGB(255, 180, 180, 180) ..strokeWidth = 1;
    for (var i = 1; i <= 10; i++) {
      for (var j = 1; j < 10; j++) {

        drawHourLine(canvas,centerOffset,math.pi*((.2*i)+(j*.02)),minorLine,halfWidth*.9,halfWidth*.95);

      }
     // final radian = math.pi*.2*i; 
      drawHourLine(canvas,centerOffset,math.pi*.2*i,mayorLine,halfWidth*.85,halfWidth*.95);
      //textPainter.textScaler
    //  final textOffset = Offset(centerOffset.dx+math.sin(radian)*halfWidth*1.1, centerOffset.dy-math.cos(radian)*halfWidth*1.1);
 //     textPainter1.paint(canvas, textOffset);
    }


    canvas.drawCircle(centerOffset, 10, minutesPaint);
    centerOffset = centerOffset-Offset(6,16);

    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 25,
   //   fontFamily: 'Aileron Black',
    );
    final textPainter1 = TextPainter(
      text: const TextSpan(text: '1',style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );  textPainter1.layout();
    final textPainter2 = TextPainter(
      text: const TextSpan(text: '2',style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );  textPainter2.layout();
    final textPainter3 = TextPainter(
      text: const TextSpan(text: '3',style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );  textPainter3.layout();
      final textPainter4 = TextPainter(
      text: const TextSpan(text: '4',style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );  textPainter4.layout();
      final textPainter5 = TextPainter(
      text: const TextSpan(text: '5',style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );  textPainter5.layout();
    final textPainter6 = TextPainter(
      text: const TextSpan(text: '6',style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );  textPainter6.layout();
    final textPainter7 = TextPainter(
      text: const TextSpan(text: '7',style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );  textPainter7.layout();
    final textPainter8 = TextPainter(
      text: const TextSpan(text: '8',style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );  textPainter8.layout();
      final textPainter9 = TextPainter(
      text: const TextSpan(text: '9',style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );  textPainter9.layout();
      final textPainter10 = TextPainter(
      text: const TextSpan(text: '10',style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );  textPainter10.layout();

    textPainter1.paint(canvas, Offset(centerOffset.dx+math.sin(math.pi*.2)*halfWidth, centerOffset.dy-math.cos(math.pi*.2)*halfWidth));
    textPainter2.paint(canvas, Offset(centerOffset.dx+math.sin(math.pi*.4)*halfWidth, centerOffset.dy-math.cos(math.pi*.4)*halfWidth));
    textPainter3.paint(canvas, Offset(centerOffset.dx+math.sin(math.pi*.6)*halfWidth, centerOffset.dy-math.cos(math.pi*.6)*halfWidth));
    textPainter4.paint(canvas, Offset(centerOffset.dx+math.sin(math.pi*.8)*halfWidth, centerOffset.dy-math.cos(math.pi*.8)*halfWidth));
    textPainter5.paint(canvas, Offset(centerOffset.dx+math.sin(math.pi*1)*halfWidth, centerOffset.dy-math.cos(math.pi*1)*halfWidth));
    textPainter6.paint(canvas, Offset(centerOffset.dx+math.sin(math.pi*1.2)*halfWidth, centerOffset.dy-math.cos(math.pi*1.2)*halfWidth));
    textPainter7.paint(canvas, Offset(centerOffset.dx+math.sin(math.pi*1.4)*halfWidth, centerOffset.dy-math.cos(math.pi*1.4)*halfWidth));
    textPainter8.paint(canvas, Offset(centerOffset.dx+math.sin(math.pi*1.6)*halfWidth, centerOffset.dy-math.cos(math.pi*1.6)*halfWidth));
    textPainter9.paint(canvas, Offset(centerOffset.dx+math.sin(math.pi*1.8)*halfWidth, centerOffset.dy-math.cos(math.pi*1.8)*halfWidth));
    textPainter10.paint(canvas, Offset(centerOffset.dx+math.sin(0)*halfWidth-8, centerOffset.dy-math.cos(0)*halfWidth));
    
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