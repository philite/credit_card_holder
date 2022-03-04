import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../db/card_type.dart';
import '../db/credit_card.dart';
import '../main.dart';
import '../util/string_util.dart';
import 'input_formatter/character_separator_input_formatter.dart';

class UpdateCreditCardRoute extends StatefulWidget {
  final int cardId;

  const UpdateCreditCardRoute({Key? key, required this.cardId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => UpdateCreditCardState();
}

class UpdateCreditCardState extends State<UpdateCreditCardRoute> {
  bool _isLoading = true;
  var logger = Logger();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();

  late CreditCard card;

  late String _selectedType;
  late DateTime _selectedDate;

  @override
  void initState() {
    loadCard();
    super.initState();
  }

  void loadCard() async {
    setState(() {
      _isLoading = true;
    });

    await App.database.then((db) async {
      card = await db.getCardById(widget.cardId);
      _selectedType = card.type.name;
      cardNumberController.text = card.cardNumber;
      _selectedDate = card.expireDate;
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Update Credit Card"),
        ),
        body: _bodyOnStateChange());
  }

  Widget _bodyOnStateChange() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    } else {
      return _loadedForm();
    }
  }

  Widget _loadedForm() {
    return SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(padding: EdgeInsets.all(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 20, 20, 20),
                      child: const Text("Card Type"),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 40, 20),
                      child: _dropdownButton(),
                    )
                  ],
                ),
                _cardNumberTextForm(),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                      const Text("Expire Date"),
                      Text(formatExpireDate(_selectedDate)),
                      _expireDateForm(),
                    ],
                  ),
                ),
                const Padding(padding: EdgeInsets.all(20)),
                Center(
                  child: ElevatedButton(
                      onPressed: () async {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Updating Data')),
                          );
                          await App.database.then((db) {
                            db.updateCardById(CreditCard(
                                id: card.id,
                                cardNumber: cardNumberController.text,
                                expireDate: _selectedDate,
                                type: cardTypeFromString(_selectedType)));
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Update")),
                )
              ],
            )));
  }

  Widget _dropdownButton() {
    return DropdownButton<String>(
      items: <String>[
        CardType.masterCard.name,
        CardType.visa.name,
        CardType.amex.name
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() => _selectedType = newValue!);
      },
      value: _selectedType,
    );
  }

  Widget _cardNumberTextForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
      child: TextFormField(
        decoration: const InputDecoration(label: Text("Card Number")),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(16),
          CharacterSeparatorInputFormatter(4, " ")
        ],
        validator: (String? value) {
          // fixme filter already added card?
          // fixme validate expire date
          // let it the student complete it.
          return (value != null && value.length == 16) ? 'Invalid card' : null;
        },
        controller: cardNumberController,
      ),
    );
  }

  Widget _expireDateForm() {
    // https://pub.dev/packages/month_picker_dialog/install
    return ElevatedButton(
        onPressed: () {
          showMonthPicker(context: context, initialDate: _selectedDate)
              .then((date) => {
                    if (date != null)
                      {
                        setState(() {
                          _selectedDate = date;
                        })
                      }
                  });
        },
        child: const Text("Pick expire date"));
  }
}
