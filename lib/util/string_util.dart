import 'package:logger/logger.dart';

String formatExpireDate(DateTime date) {
  String month;
  String year;
  if ("${date.month}".length < 2) {
    month = "0${date.month}";
  } else {
    month = "${date.month}";
  }

  year = date.year.toString().replaceRange(0, 2, "");
  return "$month/$year";
}

String formatCardNumber(String cardNumber) {
  String result = "";
  List<String> subString = cardNumber.split(" ");
  for (int i = 0; i < subString.length - 1; i++) {
    subString[i] = subString[i].replaceRange(0, subString[i].length, "**** ");
    // Logger().d(subString[i]);
    result += subString[i];
  }
  result += subString[subString.length - 1];
  return result;
}
