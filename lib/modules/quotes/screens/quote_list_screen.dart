import 'dart:async';
import 'dart:developer';

import 'package:booksum/modules/core/widgets/common_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';

class QuoteListScreen extends StatefulWidget {
  const QuoteListScreen({super.key});

  @override
  State<QuoteListScreen> createState() => _QuoteListScreenState();
}

class _QuoteListScreenState extends State<QuoteListScreen> {
  String text = "";
  final StreamController<String> _streamController = StreamController<String>();
  bool torchOn = false;
  int cameraSelection = 0;
  bool lockCamera = true;
  bool loading = false;
  final GlobalKey<ScalableOCRState> _cameraKey = GlobalKey<ScalableOCRState>();

  void setText(value) {
    _streamController.add(value);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              !loading
                  ? ScalableOCR(
                      key: _cameraKey,
                      torchOn: torchOn,
                      cameraSelection: cameraSelection,
                      lockCamera: lockCamera,
                      paintboxCustom: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 4.0
                        ..color = const Color.fromARGB(153, 102, 160, 241),
                      boxLeftOff: 5,
                      boxBottomOff: 2.5,
                      boxRightOff: 5,
                      boxTopOff: 2.5,
                      boxHeight: MediaQuery.of(context).size.height / 3,
                      getRawData: (value) {
                        inspect(value);
                      },
                      getScannedText: (value) {
                        setText(value);
                      })
                  : Padding(
                      padding: const EdgeInsets.all(17.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: defaultBorderRadius,
                        ),
                        height: MediaQuery.of(context).size.height / 3,
                        width: MediaQuery.of(context).size.width,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
              StreamBuilder<String>(
                stream: _streamController.stream,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  return Result(
                      text: snapshot.data != null ? snapshot.data! : "");
                },
              ),
              Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          loading = true;
                          cameraSelection = cameraSelection == 0 ? 1 : 0;
                        });
                        Future.delayed(const Duration(milliseconds: 150), () {
                          setState(() {
                            loading = false;
                          });
                        });
                      },
                      child: const Text("Switch Camera")),
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                          torchOn = !torchOn;
                        });
                        Future.delayed(const Duration(milliseconds: 150), () {
                          setState(() {
                            loading = false;
                          });
                        });
                      },
                      child: const Text("Toggle Torch")),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        loading = true;
                        lockCamera = !lockCamera;
                      });
                      Future.delayed(const Duration(milliseconds: 150), () {
                        setState(() {
                          loading = false;
                        });
                      });
                    },
                    child: const Text("Toggle Lock Camera"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Result extends StatelessWidget {
  const Result({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text("Readed text: $text");
  }
}
