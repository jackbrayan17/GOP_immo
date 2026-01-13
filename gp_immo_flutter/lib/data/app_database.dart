import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_factory.dart';
import '../utils/auth_utils.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<Database> _open() async {
    databaseFactory = databaseFactoryImpl();

    final path = await _databasePath();
    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute(_createUsers);
        await db.execute(_createProperties);
        await db.execute(_createMedia);
        await db.execute(_createContracts);
        await db.execute(_createPayments);
        await db.execute(_createMissions);
        await db.execute(_createReports);
        await db.execute(_createMessages);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN email TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN email_normalized TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN phone_normalized TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN password_hash TEXT');
          await db.execute('UPDATE users SET email = \'\' WHERE email IS NULL');
          await db.execute(
            'UPDATE users SET email_normalized = LOWER(email) WHERE email_normalized IS NULL',
          );
          await db.execute(
            'UPDATE users SET phone_normalized = REPLACE(REPLACE(phone, \' \', \'\'), \'-\', \'\') '
            'WHERE phone_normalized IS NULL',
          );
          final defaultHash = hashPassword('gopimmo123');
          await db.update(
            'users',
            {'password_hash': defaultHash},
            where: 'password_hash IS NULL OR password_hash = \'\'',
          );
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE media ADD COLUMN path TEXT');
        }
      },
    );
  }

  Future<String> _databasePath() async {
    if (kIsWeb) {
      return 'gp_immo.db';
    }
    final directory = await getApplicationDocumentsDirectory();
    return p.join(directory.path, 'gp_immo.db');
  }

  static const String _createUsers = '''
CREATE TABLE users(
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  email TEXT,
  email_normalized TEXT,
  phone TEXT,
  phone_normalized TEXT,
  specialization TEXT,
  marketplace_visible INTEGER NOT NULL,
  rating REAL NOT NULL,
  password_hash TEXT NOT NULL
)
''';

  static const String _createProperties = '''
CREATE TABLE properties(
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL,
  title TEXT NOT NULL,
  property_type TEXT NOT NULL,
  listing_status TEXT NOT NULL,
  address TEXT,
  description TEXT,
  price REAL NOT NULL,
  furnished INTEGER NOT NULL
)
''';

  static const String _createMedia = '''
CREATE TABLE media(
  id TEXT PRIMARY KEY,
  property_id TEXT NOT NULL,
  kind TEXT NOT NULL,
  label TEXT NOT NULL,
  path TEXT
)
''';

  static const String _createContracts = '''
CREATE TABLE contracts(
  id TEXT PRIMARY KEY,
  property_id TEXT NOT NULL,
  tenant_name TEXT NOT NULL,
  status TEXT NOT NULL,
  rent REAL NOT NULL,
  start_date TEXT NOT NULL,
  end_date TEXT
)
''';

  static const String _createPayments = '''
CREATE TABLE payments(
  id TEXT PRIMARY KEY,
  property_id TEXT NOT NULL,
  amount REAL NOT NULL,
  payment_type TEXT NOT NULL,
  status TEXT NOT NULL,
  due_date TEXT NOT NULL
)
''';

  static const String _createMissions = '''
CREATE TABLE missions(
  id TEXT PRIMARY KEY,
  property_id TEXT NOT NULL,
  owner_id TEXT NOT NULL,
  status TEXT NOT NULL
)
''';

  static const String _createReports = '''
CREATE TABLE reports(
  id TEXT PRIMARY KEY,
  property_id TEXT NOT NULL,
  summary TEXT NOT NULL,
  created_at TEXT NOT NULL
)
''';

  static const String _createMessages = '''
CREATE TABLE messages(
  id TEXT PRIMARY KEY,
  sender_id TEXT NOT NULL,
  receiver_id TEXT NOT NULL,
  content TEXT NOT NULL,
  kind TEXT NOT NULL,
  created_at TEXT NOT NULL,
  has_attachment INTEGER NOT NULL
)
''';
}
