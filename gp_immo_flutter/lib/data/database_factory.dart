import 'package:sqflite/sqflite.dart';

import 'database_factory_stub.dart'
    if (dart.library.html) 'database_factory_web.dart';

DatabaseFactory databaseFactoryImpl() => databaseFactoryProvider();
