import 'package:sqflite/sqflite.dart';

import '../data/app_database.dart';
import '../data/mock_data.dart';
import '../models/app_models.dart';
import '../services/logger_service.dart';
import '../utils/auth_utils.dart';

class AppRepository {
  AppRepository({
    AppDatabase? database,
    LoggerService? loggerService,
  })  : _database = database ?? AppDatabase.instance,
        _logger = loggerService ?? LoggerService.instance;

  final AppDatabase _database;
  final LoggerService _logger;

  Future<void> init() async {
    await _database.database;
  }

  Future<void> seedIfNeeded() async {
    final db = await _database.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users'),
    );
    if (count != null && count > 0) return;

    _logger.info('Seeding database with mock data');
    final batch = db.batch();

    for (final user in MockData.users) {
      batch.insert('users', user.toMap());
    }
    for (final property in MockData.properties) {
      batch.insert('properties', property.toMap());
      for (final media in property.media) {
        batch.insert('media', media.toMap(propertyId: property.id));
      }
    }
    for (final contract in MockData.contracts) {
      batch.insert('contracts', contract.toMap());
    }
    for (final payment in MockData.payments) {
      batch.insert('payments', payment.toMap());
    }
    for (final mission in MockData.missions) {
      batch.insert('missions', mission.toMap());
    }
    for (final report in MockData.reports) {
      batch.insert('reports', report.toMap());
    }
    for (final message in MockData.messages) {
      batch.insert('messages', message.toMap());
    }

    await batch.commit(noResult: true);
  }


  Future<void> ensureAuthData() async {
    const defaultPassword = 'gopimmo123';
    final db = await _database.database;
    await _ensureAuthColumns(db);
    final rows = await db.query('users');
    for (final row in rows) {
      final id = row['id'] as String;
      final email = (row['email'] as String?) ?? '';
      final emailNormalized = (row['email_normalized'] as String?) ?? '';
      final passwordHash = (row['password_hash'] as String?) ?? '';
      final phone = (row['phone'] as String?) ?? '';
      final phoneNormalized = (row['phone_normalized'] as String?) ?? '';
      final updates = <String, Object?>{};
      if (email.trim().isEmpty) {
        updates['email'] = '$id@gopimmo.local';
      }
      if (emailNormalized.trim().isEmpty) {
        final source = (updates['email'] as String?) ?? email;
        updates['email_normalized'] = normalizeEmail(source);
      }
      if (phoneNormalized.trim().isEmpty && phone.isNotEmpty) {
        updates['phone_normalized'] = normalizePhone(phone);
      }
      if (passwordHash.trim().isEmpty) {
        updates['password_hash'] = hashPassword(defaultPassword);
      }
      if (updates.isNotEmpty) {
        await db.update('users', updates, where: 'id = ?', whereArgs: [id]);
      }
    }
  }

  Future<void> _ensureAuthColumns(Database db) async {
    final info = await db.rawQuery('PRAGMA table_info(users)');
    final columns = info
        .map((row) => (row['name'] as String?)?.toLowerCase())
        .whereType<String>()
        .toSet();

    await _addColumnIfMissing(db, columns, 'email', 'TEXT');
    await _addColumnIfMissing(db, columns, 'email_normalized', 'TEXT');
    await _addColumnIfMissing(db, columns, 'phone_normalized', 'TEXT');
    await _addColumnIfMissing(db, columns, 'password_hash', 'TEXT');
  }

  Future<void> _addColumnIfMissing(
    Database db,
    Set<String> columns,
    String name,
    String type,
  ) async {
    if (columns.contains(name.toLowerCase())) return;
    await db.execute('ALTER TABLE users ADD COLUMN $name $type');
  }

  Future<AppUser?> authenticate({
    required String identifier,
    required String password,
  }) async {
    await ensureAuthData();
    final trimmed = identifier.trim();
    if (trimmed.isEmpty || password.isEmpty) {
      throw AuthException('Veuillez renseigner vos identifiants.');
    }
    final normalizedEmail = normalizeEmail(trimmed);
    final normalizedPhone = normalizePhone(trimmed);
    final isEmail = trimmed.contains('@');
    final db = await _database.database;
    final rows = await db.query(
      'users',
      where: isEmail
          ? 'email_normalized = ? OR email = ?'
          : 'phone_normalized = ? OR phone = ?',
      whereArgs: isEmail ? [normalizedEmail, trimmed] : [normalizedPhone, trimmed],
    );
    if (rows.isEmpty) {
      return null;
    }
    for (final map in rows) {
      final storedHash = (map['password_hash'] as String?) ?? '';
      if (verifyPassword(password, storedHash)) {
        return AppUser.fromMap(map);
      }
    }
    return null;
  }

  Future<AppUser> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String specialization = '',
  }) async {
    await ensureAuthData();
    final trimmedName = name.trim();
    final trimmedEmail = normalizeEmail(email);
    final trimmedPhone = phone.trim();
    final trimmedPassword = password.trim();
    if (trimmedName.isEmpty || trimmedEmail.isEmpty || trimmedPhone.isEmpty) {
      throw AuthException('Nom, email et telephone sont requis.');
    }
    if (!trimmedEmail.contains('@')) {
      throw AuthException('Email invalide.');
    }
    if (normalizePhone(trimmedPhone).length < 6) {
      throw AuthException('Telephone invalide.');
    }
    if (trimmedPassword.length < 6) {
      throw AuthException('Le mot de passe doit contenir au moins 6 caracteres.');
    }
    if (role == UserRole.provider && specialization.trim().isEmpty) {
      throw AuthException('Specialisation requise pour les prestataires.');
    }
    final db = await _database.database;
    final existing = await db.query(
      'users',
      where: 'email_normalized = ? OR phone_normalized = ? OR email = ? OR phone = ?',
      whereArgs: [
        trimmedEmail,
        normalizePhone(trimmedPhone),
        trimmedEmail,
        trimmedPhone,
      ],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw AuthException('Un compte existe deja avec cet email ou telephone.');
    }
    final user = AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: trimmedName,
      role: role,
      email: trimmedEmail,
      phone: trimmedPhone,
      specialization: role == UserRole.provider ? specialization.trim() : '',
      marketplaceVisible: role == UserRole.provider,
      rating: 0,
      passwordHash: hashPassword(trimmedPassword),
    );
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
    return user;
  }

  Future<List<AppUser>> fetchUsers() async {
    try {
      final db = await _database.database;
      final rows = await db.query('users');
      return rows.map(AppUser.fromMap).toList();
    } catch (error, stackTrace) {
      _logger.error('Failed to fetch users', error, stackTrace);
      rethrow;
    }
  }

  Future<List<Property>> fetchProperties() async {
    try {
      final db = await _database.database;
      final propertyRows = await db.query('properties');
      final mediaRows = await db.query('media');

      final mediaByProperty = <String, List<MediaItem>>{};
      for (final row in mediaRows) {
        final propertyId = row['property_id'] as String;
        final media = MediaItem.fromMap(row);
        mediaByProperty.putIfAbsent(propertyId, () => []).add(media);
      }

      return propertyRows
          .map(
            (row) => Property.fromMap(
              row,
              media: mediaByProperty[row['id'] as String] ?? const [],
            ),
          )
          .toList();
    } catch (error, stackTrace) {
      _logger.error('Failed to fetch properties', error, stackTrace);
      rethrow;
    }
  }

  Future<List<Contract>> fetchContracts() async {
    try {
      final db = await _database.database;
      final rows = await db.query('contracts');
      return rows.map(Contract.fromMap).toList();
    } catch (error, stackTrace) {
      _logger.error('Failed to fetch contracts', error, stackTrace);
      rethrow;
    }
  }

  Future<List<Payment>> fetchPayments() async {
    try {
      final db = await _database.database;
      final rows = await db.query('payments');
      return rows.map(Payment.fromMap).toList();
    } catch (error, stackTrace) {
      _logger.error('Failed to fetch payments', error, stackTrace);
      rethrow;
    }
  }

  Future<List<Mission>> fetchMissions() async {
    try {
      final db = await _database.database;
      final rows = await db.query('missions');
      return rows.map(Mission.fromMap).toList();
    } catch (error, stackTrace) {
      _logger.error('Failed to fetch missions', error, stackTrace);
      rethrow;
    }
  }

  Future<List<Report>> fetchReports() async {
    try {
      final db = await _database.database;
      final rows = await db.query('reports');
      return rows.map(Report.fromMap).toList();
    } catch (error, stackTrace) {
      _logger.error('Failed to fetch reports', error, stackTrace);
      rethrow;
    }
  }

  Future<List<Message>> fetchMessages() async {
    try {
      final db = await _database.database;
      final rows = await db.query('messages', orderBy: 'created_at ASC');
      return rows.map(Message.fromMap).toList();
    } catch (error, stackTrace) {
      _logger.error('Failed to fetch messages', error, stackTrace);
      rethrow;
    }
  }

  Future<void> insertProperty(Property property) async {
    final db = await _database.database;
    await db.insert('properties', property.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertMedia(String propertyId, MediaItem item) async {
    final db = await _database.database;
    await db.insert(
      'media',
      item.toMap(propertyId: propertyId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertContract(Contract contract) async {
    final db = await _database.database;
    await db.insert('contracts', contract.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertPayment(Payment payment) async {
    final db = await _database.database;
    await db.insert('payments', payment.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertMission(Mission mission) async {
    final db = await _database.database;
    await db.insert('missions', mission.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertReport(Report report) async {
    final db = await _database.database;
    await db.insert('reports', report.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertMessage(Message message) async {
    final db = await _database.database;
    await db.insert('messages', message.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateUserMarketplaceVisibility(String userId, bool visible) async {
    final db = await _database.database;
    await db.update(
      'users',
      {'marketplace_visible': visible ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

}
