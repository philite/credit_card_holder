// Adapt from: https://stackoverflow.com/questions/64386172/how-to-add-a-blank-space-after-every-4-characters-when-typing-in-textformfield
import 'package:flutter/services.dart';

class CharacterSeparatorInputFormatter extends TextInputFormatter {
  int separateEvery;
  String separateBy;

  CharacterSeparatorInputFormatter(this.separateEvery, this.separateBy);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,
      TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % separateEvery == 0 && nonZeroIndex != text.length) {
        buffer.write(separateBy);
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length)
    );
  }
}
