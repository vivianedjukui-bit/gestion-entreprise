import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/business.dart';
import '../models/stock_item.dart';
import '../models/transaction_entry.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'gestion_entreprise.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE businesses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        colorHex TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE stock_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        businessId INTEGER NOT NULL,
        name TEXT NOT NULL,
        qty INTEGER NOT NULL,
        unitPrice INTEGER NOT NULL,
        FOREIGN KEY (businessId) REFERENCES businesses (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        businessId INTEGER NOT NULL,
        type TEXT NOT NULL,
        label TEXT NOT NULL,
        amount INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (businessId) REFERENCES businesses (id)
      )
    ''');

    await _seedDemoData(db);
  }

  Future<void> _seedDemoData(Database db) async {
    final b1 = await db.insert('businesses', {'name': 'Boutique Accessoires', 'colorHex': '#C9962C'});
    final b2 = await db.insert('businesses', {'name': 'Salon de Coiffure', 'colorHex': '#3E8C5D'});
    final b3 = await db.insert('businesses', {'name': 'Restaurant Chez Awa', 'colorHex': '#B23A2E'});

    await db.insert('stock_items', {'businessId': b1, 'name': 'Coques iPhone', 'qty': 42, 'unitPrice': 1500});
    await db.insert('stock_items', {'businessId': b1, 'name': 'Câbles USB-C', 'qty': 60, 'unitPrice': 800});
    await db.insert('stock_items', {'businessId': b2, 'name': 'Tissages', 'qty': 15, 'unitPrice': 3500});
    await db.insert('stock_items', {'businessId': b3, 'name': 'Sacs de riz (50kg)', 'qty': 4, 'unitPrice': 32000});

    final now = DateTime.now();
    await db.insert('transactions', {
      'businessId': b1, 'type': 'sale', 'label': '3 coques + 2 câbles',
      'amount': 6100, 'date': now.subtract(const Duration(days: 1)).toIso8601String()
    });
    await db.insert('transactions', {
      'businessId': b1, 'type': 'expense', 'label': 'Réassort câbles',
      'amount': 24000, 'date': now.subtract(const Duration(days: 2)).toIso8601String()
    });
    await db.insert('transactions', {
      'businessId': b2, 'type': 'sale', 'label': 'Tresses + soin',
      'amount': 8000, 'date': now.toIso8601String()
    });
    await db.insert('transactions', {
      'businessId': b3, 'type': 'sale', 'label': 'Ventes du midi',
      'amount': 27500, 'date': now.toIso8601String()
    });
  }

  // ---------- Businesses ----------
  Future<List<Business>> getBusinesses() async {
    final db = await database;
    final rows = await db.query('businesses', orderBy: 'id');
    return rows.map((r) => Business.fromMap(r)).toList();
  }

  Future<int> insertBusiness(Business b) async {
    final db = await database;
    return db.insert('businesses', b.toMap()..remove('id'));
  }

  // ---------- Stock ----------
  Future<List<StockItem>> getStock(int businessId) async {
    final db = await database;
    final rows = await db.query(
      'stock_items',
      where: 'businessId = ?',
      whereArgs: [businessId],
      orderBy: 'id DESC',
    );
    return rows.map((r) => StockItem.fromMap(r)).toList();
  }

  Future<int> insertStockItem(StockItem item) async {
    final db = await database;
    return db.insert('stock_items', item.toMap()..remove('id'));
  }

  // ---------- Transactions (ventes / dépenses) ----------
  Future<List<TransactionEntry>> getTransactions(int businessId, {EntryType? type}) async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      where: type == null ? 'businessId = ?' : 'businessId = ? AND type = ?',
      whereArgs: type == null ? [businessId] : [businessId, type == EntryType.sale ? 'sale' : 'expense'],
      orderBy: 'date DESC',
    );
    return rows.map((r) => TransactionEntry.fromMap(r)).toList();
  }

  Future<int> insertTransaction(TransactionEntry entry) async {
    final db = await database;
    return db.insert('transactions', entry.toMap()..remove('id'));
  }
}
