import 'dart:async';

import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:credit_card_holder/db/card_type.dart';
import 'package:credit_card_holder/db/credit_card.dart';

typedef DatabaseRecord = List<Map<String, dynamic>>;

class SqlDatabase {
  static final _instance = SqlDatabase._();
  static late Database _database;

  static const String _tableCreditCard = "creditCardTable";
  static const columnId = "id";
  static const columnType = "type";
  static const columnExpireDate = "expireDate";
  static const columnCardNumber = "cardNumber";

  static const _createTable = "CREATE TABLE $_tableCreditCard("
      "$columnId INTEGER PRIMARY KEY AUTOINCREMENT,"
      "$columnType TEXT, $columnCardNumber TEXT, $columnExpireDate DATETIME)";

  SqlDatabase._();

  static Future<SqlDatabase> createInstance() async {
    await _init().then((db) => _database = db);
    return _instance;
  }

  static Future<Database> _init() async {
    return openDatabase(join(await getDatabasesPath(), 'credit_database.db'),
        version: 1, onCreate: _onCreate);
  }

  static void _onCreate(Database db, int newVersion) async {
    await db.execute(_createTable);
  }

  Future addCreditCard(CreditCard card) async {
    _database.insert(_tableCreditCard, card.toMap());
  }

  Future deleteCreditCard(CreditCard card) async {
    _database.delete(_tableCreditCard, where: "$columnId = ${card.id}");
  }

  Future<List<CreditCard>> getAllCards() async {
    var query = await _database.query(_tableCreditCard);
    List<CreditCard> items = List<CreditCard>.empty(growable: true);

    for (var element in query) {
      items.add(CreditCard.fromMap(element));
    }

    return items;
  }

  Future<List<CreditCard>> getCardsByType(CardType type) async {
    // Fixme (Slide): In example code, don't put '' in ${type.name}
    // Let the student know the error
    var query = await _database.query(_tableCreditCard,
        where: "$columnType = '${type.name}'");
    List<CreditCard> items = List<CreditCard>.empty(growable: true);

    for (var element in query) {
      items.add(CreditCard.fromMap(element));
    }

    return items;
  }

  Future<CreditCard> getCardById(int id) async {
    var query =
        await _database.query(_tableCreditCard, where: "$columnId = $id");
    return CreditCard.fromMap(query.first);
  }

  Future<void> updateCardById(CreditCard card) async {
    await _database.update(_tableCreditCard, card.toMap(),
        where: "$columnId = ${card.id}");
  }
}
