import 'dart:isolate';

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          children: [
            Image.asset('assets/gifs/bouncy_ball.gif'),

            //Blocking UI Task
            ElevatedButton(
              onPressed: () {
                var total = complexTask1();
                debugPrint('Result 1 -> $total');
              },
              child: const Text('Task 1'),
            ),

            //Isolate
            ElevatedButton(
              onPressed: () async{
                final receivePort = ReceivePort();
                await Isolate.spawn(complexTask2, receivePort.sendPort);
                receivePort.listen((total){
                  debugPrint('Result 2 -> $total');
                });
              },
              child: const Text('Task 2'),
            ),

            //Isolate with parameters using POJO class
            ElevatedButton(
              onPressed: () async {
                final receivePort = ReceivePort();
                await Isolate.spawn(complexTask3, Data(1000000000, receivePort.sendPort));
                receivePort.listen((total){
                  debugPrint('Result 3 -> $total');
                });
              },
              child: const Text('Task 3'),
            ),

            //Isolate with parameters using Records
            ElevatedButton(
              onPressed: () async {
                final receivePort = ReceivePort();
                await Isolate.spawn(complexTask4, (iteration: 1000000000, sendPort: receivePort.sendPort));
                receivePort.listen((total){
                  debugPrint('Result 4 -> $total');
                });
              },
              child: const Text('Task 4'),
            ),
          ],
        ),
      )),
    );
  }

  double complexTask1() {
    var total = 0.0;
    for (var i = 0; i < 1000000000; i++) {
      total += i;
    }
    return total;
  }
}

//Isolates should be independent
// must not be in any class
// must be outside of class
complexTask2(SendPort sendPort) {
  var total = 0.0;
  for (var i = 0; i < 1000000000; i++) {
    total += i;
  }
  sendPort.send(total);
}


//Sending data to isolates
complexTask3(Data data) {
  var total = 0.0;
  for (var i = 0; i < data.iteration; i++) {
    total += i;
  }
  data.sendPort.send(total);
}


class Data{
  final int iteration;
  final SendPort sendPort;

  Data(this.iteration, this.sendPort);
}


//Sending data to isolates using Record (With Named Parameter)
complexTask4(({int iteration, SendPort sendPort}) data) {
  var total = 0.0;
  for (var i = 0; i < data.iteration; i++) {
    total += i;
  }
  data.sendPort.send(total);
}

/*
//Sending data to isolates using Record (Without Named Parameter)
complexTask4((int iteration, SendPort sendPort) data) {
  var total = 0.0;
  for (var i = 0; i < data.$1; i++) {
    total += i;
  }
  data.$2.send(total);
}*/
