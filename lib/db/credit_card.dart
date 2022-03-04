import 'package:credit_card_holder/db/card_type.dart';
import 'package:credit_card_holder/db/database.dart';

class CreditCard {
  int id;
  String cardNumber;
  DateTime expireDate;
  CardType type;

  CreditCard(
      {this.id = 0,
      required this.cardNumber,
      required this.expireDate,
      required this.type});

  Map<String, dynamic> toMap() {
    return {
      'cardNumber': cardNumber,
      'expireDate': expireDate.toString(),
      'type': type.name
    };
  }

  static CreditCard fromMap(Map map) {
    return CreditCard(
        id: map[SqlDatabase.columnId],
        cardNumber: map[SqlDatabase.columnCardNumber],
        expireDate: DateTime.parse(map[SqlDatabase.columnExpireDate]),
        type: cardTypeFromString(map[SqlDatabase.columnType]));
  }

  @override
  String toString() {
    return 'CreditCard{id : $id, cardNumber: $cardNumber, expireDate: $expireDate, type: $type}';
  }
}
