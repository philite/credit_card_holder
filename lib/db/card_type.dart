import 'package:flutter/material.dart';

enum CardType { masterCard, visa, amex }

List<Color> getColorGradientsByCardType(CardType type) {
  switch (type) {
    case CardType.masterCard:
      return [
        const Color(0xff6a31d5),
        const Color(0xff6b38d8),
        const Color(0xff6c48e1),
        const Color(0xff6d56e8),
        const Color(0xff6f66f0),
        const Color(0xff7173f6)
      ];
    case CardType.visa:
      return [
        const Color(0xff637ae3),
        const Color(0xff5e8ce0),
        const Color(0xff5ca3de),
        const Color(0xff5fbfda),
        const Color(0xff65d5d8),
        const Color(0xff6ce6d9)
      ];
    case CardType.amex:
      return [
        const Color(0xffe35da0),
        const Color(0xffe46099),
        const Color(0xffe66692),
        const Color(0xffe97185),
        const Color(0xffec7681),
        const Color(0xffef7e7a),
      ];
  }
}

CardType cardTypeFromString(String text) {
  return CardType.values.firstWhere((element) => element.name == text);
}
