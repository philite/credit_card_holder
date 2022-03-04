import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:credit_card_holder/db/card_type.dart';
import 'package:credit_card_holder/db/credit_card.dart';
import 'package:credit_card_holder/util/string_util.dart';
import 'package:credit_card_holder/view/home/list_type.dart';
import 'package:credit_card_holder/view/edit_credit_card_route.dart';
import 'package:credit_card_holder/routes.dart';

import '../../main.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final double textSizedBoxWidth = 225;
  bool _isLoading = true;

  late List<CreditCard> allList;
  late List<CreditCard> masterList;
  late List<CreditCard> visaList;
  late List<CreditCard> amexList;
  var logger = Logger();

  @override
  void initState() {
    refreshCards();
    super.initState();
  }

  void refreshCards() async {
    // fixme (Slide): Remove this from first then add later
    setState(() {
      _isLoading = true;
    });

    var database = await App.database;
    allList = await database.getAllCards();
    masterList = await database.getCardsByType(CardType.masterCard);
    visaList = await database.getCardsByType(CardType.visa);
    amexList = await database.getCardsByType(CardType.amex);

    setState(() {
      _isLoading = false;
    });
  }

  // fixme:
  // 2. Firebase Login
  // 3. Move project to Github
  // 4. Install project on Dell laptop
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Credit Cards Holder"),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: "All"),
              Tab(text: "Master Card"),
              Tab(text: "Visa"),
              Tab(text: "Amex"),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _cardListView(context, _isLoading, ListType.all),
            _cardListView(context, _isLoading, ListType.masterCard),
            _cardListView(context, _isLoading, ListType.visa),
            _cardListView(context, _isLoading, ListType.amex),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            // Fixme: async and await is the most important thing in this page
            await Navigator.pushNamed(context, addCardRoute);
            refreshCards();
          },
        ),
      ),
    );
  }

  Widget _cardListView(BuildContext context, bool isLoading, ListType type) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    List<CreditCard> items;

    switch (type) {
      case ListType.all:
        items = allList;
        break;
      case ListType.masterCard:
        items = masterList;
        break;
      case ListType.visa:
        items = visaList;
        break;
      case ListType.amex:
        items = amexList;
        break;
    }

    if (items.isEmpty) {
      return const Center(
        child: Text("Add some credit card."),
      );
    }

    return Scrollbar(
      child: CarouselSlider.builder(
          itemCount: items.length,
          itemBuilder:
              (BuildContext context, int itemIndex, int pageViewIndex) =>
                  _card(items[itemIndex]),
          options: CarouselOptions(
              height: 450, initialPage: 0, enableInfiniteScroll: false)),
    );

    // return ListView.builder(
    //     scrollDirection: Axis.horizontal,
    //     itemCount: items.length,
    //     itemBuilder: (context, index) {
    //       return _creditCard(items[index]);
    //     });
  }

  Widget _card(CreditCard card) {
    var colorGradients = getColorGradientsByCardType(card.type);
    return InkWell(
      onLongPress: () async {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Delete this card?"),
                  actions: [
                    ElevatedButton(
                        onPressed: () async {
                          await App.database
                              .then((db) => db.deleteCreditCard(card));
                          refreshCards();
                          Navigator.pop(context);
                        },
                        child: const Text("Delete")),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"))
                  ],
                ));
      },
      onTap: () async {
        // fixme: Lecture => await is important
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UpdateCreditCardRoute(cardId: card.id)));
        // fixme: Lecture => refreshCards() is important
        // after it await for Update route to finish
        refreshCards();
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 30),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            gradient: LinearGradient(
              colors: colorGradients,
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Column(
              children: <Widget>[
                const Padding(padding: EdgeInsets.all(100)),
                whiteLeftAlignText("CARD NUMBER", textSizedBoxWidth),
                Container(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        width: textSizedBoxWidth,
                        child: Text(
                          formatCardNumber(card.cardNumber),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SanFrancisco',
                              letterSpacing: 1.5,
                              fontSize: 16,
                              wordSpacing: 8),
                        ))),
                const Padding(padding: EdgeInsets.all(10)),
                whiteLeftAlignText("EXPIRE DATE", textSizedBoxWidth),
                const Padding(padding: EdgeInsets.all(5)),
                whiteLeftAlignText(formatExpireDate(card.expireDate), textSizedBoxWidth)
              ],
            ),
          ),
        ),
      ),
    );
  }

  // fixme: Refactor
  Widget whiteLeftAlignText(String data, double width) {
    return SizedBox(
        //fixme: This uses the same value as above
        width: width,
        child: Text(
          data,
          style:
              const TextStyle(color: Colors.white, fontFamily: 'SanFrancisco'),
        ));
  }
}
