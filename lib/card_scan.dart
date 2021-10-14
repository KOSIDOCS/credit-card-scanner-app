import 'dart:math';
import 'dart:ui';

import 'package:blinkcard_flutter/microblink_scanner.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_tv/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GlassSlider extends StatefulWidget {
  const GlassSlider({Key? key}) : super(key: key);

  @override
  _GlassSliderState createState() => _GlassSliderState();
}

class _GlassSliderState extends State<GlassSlider> {
  final Duration initialDelay = Duration(seconds: 1);
  // String _resultString = "";
  // String _fullDocumentFirstImageBase64 = "";
  // String _fullDocumentSecondImageBase64 = "";

  List<CardGlass> cardList = [];

  Future<void> scan() async {
    List<RecognizerResult> results;
    String license = "";
    var amount = new Random().nextInt(40);

    Recognizer recognizer = BlinkCardRecognizer();
    OverlaySettings settings = BlinkCardOverlaySettings();

    // set your license
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      license = dotenv.get('LICENCE');
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      license = dotenv.get('LICENCE');
    }

    try {
      // perform scan and gather results
      results = await MicroblinkScanner.scanWithCamera(
          RecognizerCollection([recognizer]), settings, license);
      if (results.length == 0) return;
      for (var result in results) {
        if (result is BlinkCardRecognizerResult) {
          // _resultString = getCardResultString(result); //to get combined strings

          var getResults = getCardResultArray(result);

          var type = detectCCType(getResults[0]);

          print('This is card number ' + getResults[0]);

          var newCard = CardGlass(
            cardWidth: 220.0,
            cardType: 'VISA',
            cardNumber: getResults[0].replaceRange(0, 14, '**** '),
            cardDate: getResults[6],
            amount: '\$$amount,000.00',
            amountSpent: ['58.00', '40.00', '90.00'],
            currType: type,
          );

          setState(() {
            // _resultString = _resultString; //to get combined strings
            cardList.add(newCard);
            // _fullDocumentFirstImageBase64 =
            //     result.firstSideFullDocumentImage ?? "";
            // _fullDocumentSecondImageBase64 =
            //     result.secondSideFullDocumentImage ?? "";
          });

          print(cardList[0].cardNumber);

          return;
        }
      }
    } on PlatformException {
      // handle exception
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
                    ),
              DelayedDisplay(
                delay: Duration(seconds: initialDelay.inSeconds + 2),
                child: Center(
                  child: Text(
                    cardList.isEmpty ? "" : cardAmount.amount,
                    // 'me',
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
  final CreditCardType currType;

  const CardGlass({
    Key? key,
    required this.cardWidth,
    required this.cardType,
    required this.cardNumber,
    required this.cardDate,
    required this.amount,
    required this.amountSpent,
    required this.currType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            blurRadius: 16,
            spreadRadius: 16,
            color: Colors.black.withOpacity(0.1),
          )
        ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20.0,
              sigmaY: 20.0,
            ),
            child: Container(
                // width: 360,
                width: cardWidth,
                height: 250,
                decoration: BoxDecoration(
                    // 233dc7
                    // color: Colors.white.withOpacity(0.2),
                    //color: Color(0xFF333F7B).withOpacity(0.2),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomCenter,
                      stops: [
                        0.24,
                        0.6,
                        1.3,
                        // 0.9,
                      ],
                      colors: [
                        Color(0xFF20273C),
                        Color(0xFF333F7B),
                        Color(0xFF20273C),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      width: 1.5,
                      // color: Colors.white.withOpacity(0.2),
                      color: Color(0xFF333F7B).withOpacity(0.2),
                    )),
                child: Padding(
                  padding: EdgeInsets.all(29.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // cardType,
                            _buildIcon(currType)[1],
                            style: TextStyle(
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(1.0),
                            ),
                          ),
                          // Icon(
                          //   FeatherIcons.wifi,
                          //   color: Colors.white.withOpacity(0.45),
                          // )
                          _buildIcon(currType)[0]
                        ],
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cardNumber,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20.0,
                                  color: Colors.white.withOpacity(0.85))),
                        ],
                      ),
                      SizedBox(height: 6.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cardDate,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.75))),
                        ],
                      )
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  List _buildIcon(CreditCardType currType) {
    switch (currType) {
      case CreditCardType.visa:
        return [
          Icon(
            FontAwesomeIcons.ccVisa,
            size: 30.0,
            color: Color(0xffffffff),
          ),
          'VISA',
        ];
      case CreditCardType.amex:
        return [
          Icon(
            FontAwesomeIcons.ccAmex,
            size: 30.0,
            color: Color(0xffffffff),
          ),
          'Amex'
        ];

      case CreditCardType.maestro:
      case CreditCardType.mastercard:
        return [
          Icon(
            FontAwesomeIcons.ccMastercard,
            size: 30.0,
            color: Color(0xffffffff),
          ),
          'MASTER'
        ];

      case CreditCardType.discover:
        return [
          Icon(
            FontAwesomeIcons.ccDiscover,
            size: 30.0,
            color: Color(0xffffffff),
          ),
          'Discover'
        ];

      case CreditCardType.dinersclub:
        return [
          Icon(
            FontAwesomeIcons.ccDinersClub,
            size: 30.0,
            color: Color(0xffffffff),
          ),
          'DinersClub'
        ];

      case CreditCardType.jcb:
        return [
          Icon(
            FontAwesomeIcons.ccJcb,
            size: 30.0,
            color: Color(0xffffffff),
          ),
          'JCB'
        ];

      // Don't have icons for the rest
      default:
        return [
          Container(
            color: Color(0x00000000),
          ),
          'Unkwon'
        ];
    }
  }
}
