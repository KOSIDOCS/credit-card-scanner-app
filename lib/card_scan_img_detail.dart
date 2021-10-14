import 'dart:typed_data';
import 'dart:ui';

import 'package:delayed_display/delayed_display.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class CardScanImgDetail extends StatefulWidget {
  final Uint8List frontImg;
  final Uint8List backImg;

  const CardScanImgDetail({
    Key? key,
    required this.frontImg,
    required this.backImg,
  }) : super(key: key);

  @override
  _CardScanImgDetailState createState() => _CardScanImgDetailState();
}

class _CardScanImgDetailState extends State<CardScanImgDetail> {
  final Duration initialDelay = Duration(seconds: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF171A29),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  FeatherIcons.arrowLeft,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
              SizedBox(height: 50.0),
              DelayedDisplay(
                delay: initialDelay,
                // child: Container(
                //   decoration: BoxDecoration(
                //     boxShadow: [
                //       BoxShadow(
                //         blurRadius: 16,
                //         spreadRadius: 16,
                //         color: Colors.black.withOpacity(0.1),
                //       )
                //     ],
                //   ),
                //   child: ClipRRect(
                //     borderRadius: BorderRadius.circular(16.0),
                //     child: BackdropFilter(
                //         filter: ImageFilter.blur(
                //           sigmaX: 20.0,
                //           sigmaY: 20.0,
                //         ),
                //         child: Image.memory(widget.frontImg)),
                //   ),
                // ),
                child: _cardFlip(
                    frontImg: widget.frontImg, backImg: widget.backImg),
              ),
              SizedBox(height: 60.0),
              DelayedDisplay(
                delay: Duration(seconds: initialDelay.inSeconds + 1),
                // child: Container(
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(16.0),
                //     boxShadow: [
                //       BoxShadow(
                //         blurRadius: 16,
                //         spreadRadius: 16,
                //         color: Colors.black.withOpacity(0.1),
                //       )
                //     ],
                //   ),
                //   child: ClipRRect(
                //     borderRadius: BorderRadius.circular(16.0),
                //     child: BackdropFilter(
                //         filter: ImageFilter.blur(
                //           sigmaX: 20.0,
                //           sigmaY: 20.0,
                //         ),
                //         child: Image.memory(widget.backImg)),
                //   ),
                // ),
                child: _cardFlip(
                    frontImg: widget.backImg, backImg: widget.frontImg),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardFlip({required Uint8List frontImg, required Uint8List backImg}) {
    return FlipCard(
      direction: FlipDirection.VERTICAL,
      front: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              spreadRadius: 16,
              color: Colors.black.withOpacity(0.1),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 20.0,
                sigmaY: 20.0,
              ),
              child: Image.memory(frontImg)),
        ),
      ),
      back: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              spreadRadius: 16,
              color: Colors.black.withOpacity(0.1),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 20.0,
                sigmaY: 20.0,
              ),
              child: Image.memory(backImg)),
        ),
      ),
    );
  }
}
