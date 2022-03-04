import 'package:flutter/material.dart';
import 'package:credit_card_holder/db/database.dart';
import 'package:credit_card_holder/view/home/home_view.dart';
import 'package:credit_card_holder/view/add_credit_card_route.dart';
import 'package:credit_card_holder/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);
  static Future<SqlDatabase> database = SqlDatabase.createInstance();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credit Card Holder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
      routes: {
        homeRoute: (context) => const HomeView(),
        addCardRoute: (context) => const AddCreditCardRoute(),
      },
    );
  }
}
