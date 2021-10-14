import 'dart:convert';
import 'dart:typed_data';

import 'package:credit_card_scanner/card_scan_img_detail.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:ui';

import 'package:blinkcard_flutter/microblink_scanner.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_swiper_tv/flutter_swiper.dart';

class CardScanImg extends StatefulWidget {
  const CardScanImg({Key? key}) : super(key: key);

  @override
  _CardScanImgState createState() => _CardScanImgState();
}

class _CardScanImgState extends State<CardScanImg> {
  final Duration initialDelay = Duration(seconds: 1);

  String _resultString = "";
  String _fullDocumentFirstImageBase64 = "";
  String _fullDocumentSecondImageBase64 = "";

  List<CardGlass> cardList = [];

  // Future<void> scan() async {
  //   List<RecognizerResult> results;
  //   String license = "";
  //   var amount = new Random().nextInt(40);

  //   Recognizer recognizer = BlinkCardRecognizer();
  //   OverlaySettings settings = BlinkCardOverlaySettings();

  //   // set your license
  //   if (Theme.of(context).platform == TargetPlatform.iOS) {
  //     license = dotenv.get('LICENCE');
  //   } else if (Theme.of(context).platform == TargetPlatform.android) {
  //     license = dotenv.get('LICENCE');
  //   }

  //   try {
  //     // perform scan and gather results
  //     results = await MicroblinkScanner.scanWithCamera(
  //         RecognizerCollection([recognizer]), settings, license);

  //     // Uint8List frontImg =
  //     //     base64.decode(result.firstSideFullDocumentImage!);
  //     // Uint8List backImg =
  //     //     base64.decode(result.secondSideFullDocumentImage!);

  //     if (results.length == 0) return;
  //     for (var result in results) {
  //       if (result is BlinkCardRecognizerResult) {
  //         // _resultString = getCardResultString(result); //to get combined strings

  //         var getResults = getCardResultArray(result);

  //         print('This is card number ' + getResults[0]);

  //         setState(() {
  //           // _resultString = _resultString; //to get combined strings
  //           // cardList.add(newCard);
  //           _fullDocumentFirstImageBase64 =
  //               result.firstSideFullDocumentImage ?? "";
  //           _fullDocumentSecondImageBase64 =
  //               result.secondSideFullDocumentImage ?? "";
  //         });

  //         print('Here is the image' +
  //             _fullDocumentFirstImageBase64 +
  //             _fullDocumentSecondImageBase64);

  //         Uint8List frontImg = base64.decode(_fullDocumentFirstImageBase64);
  //         Uint8List backImg = base64.decode(_fullDocumentSecondImageBase64);

  //         var newCard = CardGlass(
  //           cardWidth: 220.0,
  //           cardType: 'VISA',
  //           cardNumber: getResults[0].replaceRange(0, 14, '**** '),
  //           cardDate: getResults[6],
  //           amount: '\$$amount,000.00',
  //           amountSpent: ['58.00', '40.00', '90.00'],
  //           frontImg: frontImg,
  //           backImg: backImg,
  //         );

  //         cardList.add(newCard);

  //         print(cardList[0].cardNumber);

  //         return;
  //       }
  //     }
  //   } on PlatformException {
  //     // handle exception
  //   }
  // }

  Future<void> scan() async {
    String license;
    var amount = new Random().nextInt(40);
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      license = dotenv.get('LICENCE');
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      license = dotenv.get('LICENCE');
    } else {
      license = dotenv.get('LICENCE');
    }

    var cardRecognizer = BlinkCardRecognizer();
    cardRecognizer.returnFullDocumentImage = true;

    BlinkCardOverlaySettings settings = BlinkCardOverlaySettings();

    var results = await MicroblinkScanner.scanWithCamera(
        RecognizerCollection([cardRecognizer]), settings, license);

    if (!mounted) return;

    if (results.length == 0) return;
    for (var result in results) {
      if (result is BlinkCardRecognizerResult) {
        _resultString = getCardResultString(result);
        var getResults = getCardResultArray(result);

        setState(() {
          _resultString = _resultString;
          _fullDocumentFirstImageBase64 =
              result.firstSideFullDocumentImage ?? "";
          _fullDocumentSecondImageBase64 =
              result.secondSideFullDocumentImage ?? "";
        });

        print('Here is the image' +
            _fullDocumentFirstImageBase64 +
            _fullDocumentSecondImageBase64);

        Uint8List frontImg = base64.decode(_fullDocumentFirstImageBase64);
        Uint8List backImg = base64.decode(_fullDocumentSecondImageBase64);

        var newCard = CardGlass(
          cardWidth: 220.0,
          cardType: 'VISA',
          cardNumber: getResults[0].replaceRange(0, 14, '**** '),
          cardDate: getResults[6],
          amount: '\$$amount,000.00',
          amountSpent: ['58.00', '40.00', '90.00'],
          frontImg: frontImg,
          backImg: backImg,
        );

        cardList.add(newCard);

        print(cardList[0].cardNumber);

        return;
      }
    }
  }

  List<String> getCardResultArray(BlinkCardRecognizerResult result) {
    return [
      buildResult(result.cardNumber),
      buildResult(result.cardNumberPrefix),
      buildResult(result.iban),
      buildResult(result.cvv),
      buildResult(result.owner),
      buildResult(result.cardNumberValid.toString()),
      buildDateResult(result.expiryDate),
    ];
  }

  String getCardResultString(BlinkCardRecognizerResult result) {
    // for returning the card results as a combined strings
    return buildResult(result.cardNumber) +
        buildResult(result.cardNumberPrefix) +
        buildResult(result.iban) +
        buildResult(result.cvv) +
        buildResult(result.owner) +
        buildResult(result.cardNumberValid.toString()) +
        buildDateResult(result.expiryDate);
  }

  String buildResult(String? result) {
    if (result == null || result.isEmpty) {
      return "";
    }

    return result;
  }

  String buildDateResult(Date? result) {
    if (result == null || result.year == 0) {
      return "";
    }

    return buildResult("0${result.month} / ${result.year}");
  }

  String buildIntResult(int? result) {
    if (result == null || result < 0) {
      return "";
    }

    return buildResult(result.toString());
  }

  var cardAmount;

  @override
  Widget build(BuildContext context) {
    cardAmount = cardList.isEmpty ? [] : cardList[0];
    return Scaffold(
      backgroundColor: Color(0xFF171A29),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DelayedDisplay(
                delay: initialDelay,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Text(
                        'My Cards',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(1.0),
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                      child: GestureDetector(
                        onTap: () {
                          scan();
                        },
                        child: Text(
                          'Add Card',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              cardList.isEmpty
                  ? DelayedDisplay(
                      delay: Duration(seconds: initialDelay.inSeconds + 1),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 40.0, right: 40.0, top: 110.0),
                        child: Text(
                          'You don\'t have cards. Add new card',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    )
                  : new Swiper(
                      itemCount: cardList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return cardList[index];
                      },
                      itemWidth: 300.0,
                      itemHeight: 350.0,
                      layout: SwiperLayout.TINDER,
                      onIndexChanged: (val) {
                        setState(() {
                          cardAmount = cardList[val!];
                        });
                      },
                      onTap: (val) {
                        var selectedCard = cardList[val];

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CardScanImgDetail(
                              frontImg: selectedCard.frontImg,
                              backImg: selectedCard.backImg,
                            ),
                          ),
                        );
                      },
                    ),
              DelayedDisplay(
                delay: Duration(seconds: initialDelay.inSeconds + 2),
                child: Center(
                  child: Text(
                    cardList.isEmpty ? "" : cardAmount.amount,
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              DelayedDisplay(
                delay: Duration(seconds: initialDelay.inSeconds + 3),
                child: Container(
                  padding: EdgeInsets.only(
                      left: 40.0,
                      right: 40.0,
                      top: MediaQuery.of(context).size.height * 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cardList.isEmpty
                            ? 'No recent activities'
                            : 'Recent Activities',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(1.0),
                        ),
                      ),
                      SizedBox(height: 40.0),
                      cardList.isEmpty
                          ? Container()
                          : Activities(
                              img: 'spotify.png',
                              name: 'Spotify',
                              descp: 'Music Platform',
                              amount: cardList.isEmpty
                                  ? ''
                                  : cardAmount.amountSpent[0],
                            ),
                      cardList.isEmpty
                          ? Container()
                          : Activities(
                              img: 'drop.png',
                              name: 'DropBox',
                              descp: 'Cloud services',
                              amount: cardList.isEmpty
                                  ? ''
                                  : cardAmount.amountSpent[1],
                            ),
                      cardList.isEmpty
                          ? Container()
                          : Activities(
                              img: 'nike.png',
                              name: 'Nike',
                              descp: 'Clothing Brand',
                              amount: cardList.isEmpty
                                  ? ''
                                  : cardAmount.amountSpent[2],
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Activities extends StatelessWidget {
  final String img;
  final String name;
  final String descp;
  final String amount;

  const Activities({
    Key? key,
    required this.img,
    required this.name,
    required this.descp,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 14.0),
      child: Row(
        children: [
          Image.asset(
            'assets/images/$img',
            width: 50,
            height: 50,
          ),
          SizedBox(width: 20.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
              SizedBox(height: 5),
              Text(
                descp,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.25),
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            '- \$$amount',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class CardGlass extends StatelessWidget {
  final double cardWidth;
  final String cardType;
  final String cardNumber;
  final String cardDate;
  final String amount;
  final List<String> amountSpent;
  final Uint8List frontImg;
  final Uint8List backImg;

  const CardGlass({
    Key? key,
    required this.cardWidth,
    required this.cardType,
    required this.cardNumber,
    required this.cardDate,
    required this.amount,
    required this.amountSpent,
    required this.frontImg,
    required this.backImg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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
    );
  }
}
