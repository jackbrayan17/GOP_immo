enum UserRole {
  owner,
  provider,
  client,
}

enum MediaKind {
  image,
  video,
  file,
}

enum ContractStatus {
  draft,
  active,
  closed,
}

enum PaymentStatus {
  pending,
  paid,
  late,
}

enum PaymentType {
  rent,
  booking,
  provider,
}

enum MessageKind {
  text,
  quote,
  proof,
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.marketplaceVisible,
    required this.rating,
    required this.passwordHash,
  });

  final String id;
  final String name;
  final UserRole role;
  final String email;
  final String phone;
  final String specialization;
  final bool marketplaceVisible;
  final double rating;
  final String passwordHash;

  String get roleLabel {
    switch (role) {
      case UserRole.owner:
        return 'Proprietaire';
      case UserRole.provider:
        return 'Prestataire';
      case UserRole.client:
        return 'Client';
    }
  }

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      role: _userRoleFromDb(map['role'] as String),
      email: (map['email'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      specialization: (map['specialization'] as String?) ?? '',
      marketplaceVisible: _intToBool(map['marketplace_visible'] as int?),
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      passwordHash: (map['password_hash'] as String?) ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'email': email,
      'email_normalized': normalizeEmail(email),
      'phone': phone,
      'phone_normalized': normalizePhone(phone),
      'specialization': specialization,
      'marketplace_visible': _boolToInt(marketplaceVisible),
      'rating': rating,
      'password_hash': passwordHash,
    };
  }
}

class MediaItem {
  const MediaItem({
    required this.id,
    required this.kind,
    required this.label,
  });

  final String id;
  final MediaKind kind;
  final String label;

  factory MediaItem.fromMap(Map<String, Object?> map) {
    return MediaItem(
      id: map['id'] as String,
      kind: _mediaKindFromDb(map['kind'] as String),
      label: map['label'] as String,
    );
  }

  Map<String, Object?> toMap({required String propertyId}) {
    return {
      'id': id,
      'property_id': propertyId,
      'kind': kind.name,
      'label': label,
    };
  }
}

class Property {
  const Property({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.propertyType,
    required this.listingStatus,
    required this.address,
    required this.description,
    required this.price,
    required this.furnished,
    required this.media,
  });

  final String id;
  final String ownerId;
  final String title;
  final String propertyType;
  final String listingStatus;
  final String address;
  final String description;
  final double price;
  final bool furnished;
  final List<MediaItem> media;

  factory Property.fromMap(Map<String, Object?> map, {List<MediaItem> media = const []}) {
    return Property(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      title: map['title'] as String,
      propertyType: map['property_type'] as String,
      listingStatus: map['listing_status'] as String,
      address: (map['address'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      furnished: _intToBool(map['furnished'] as int?),
      media: media,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'property_type': propertyType,
      'listing_status': listingStatus,
      'address': address,
      'description': description,
      'price': price,
      'furnished': _boolToInt(furnished),
    };
  }
}

class Contract {
  const Contract({
    required this.id,
    required this.propertyId,
    required this.tenantName,
    required this.status,
    required this.rent,
    required this.startDate,
    this.endDate,
  });

  final String id;
  final String propertyId;
  final String tenantName;
  final ContractStatus status;
  final double rent;
  final DateTime startDate;
  final DateTime? endDate;

  factory Contract.fromMap(Map<String, Object?> map) {
    return Contract(
      id: map['id'] as String,
      propertyId: map['property_id'] as String,
      tenantName: map['tenant_name'] as String,
      status: _contractStatusFromDb(map['status'] as String),
      rent: (map['rent'] as num?)?.toDouble() ?? 0,
      startDate: _dateFromIso(map['start_date'] as String),
      endDate: _dateFromIsoNullable(map['end_date'] as String?),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'tenant_name': tenantName,
      'status': status.name,
      'rent': rent,
      'start_date': _dateToIso(startDate),
      'end_date': endDate == null ? null : _dateToIso(endDate!),
    };
  }
}

class Payment {
  const Payment({
    required this.id,
    required this.propertyId,
    required this.amount,
    required this.paymentType,
    required this.status,
    required this.dueDate,
  });

  final String id;
  final String propertyId;
  final double amount;
  final PaymentType paymentType;
  final PaymentStatus status;
  final DateTime dueDate;

  factory Payment.fromMap(Map<String, Object?> map) {
    return Payment(
      id: map['id'] as String,
      propertyId: map['property_id'] as String,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      paymentType: _paymentTypeFromDb(map['payment_type'] as String),
      status: _paymentStatusFromDb(map['status'] as String),
      dueDate: _dateFromIso(map['due_date'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'amount': amount,
      'payment_type': paymentType.name,
      'status': status.name,
      'due_date': _dateToIso(dueDate),
    };
  }
}

class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.kind,
    required this.createdAt,
    required this.hasAttachment,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageKind kind;
  final DateTime createdAt;
  final bool hasAttachment;

  factory Message.fromMap(Map<String, Object?> map) {
    return Message(
      id: map['id'] as String,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      content: map['content'] as String,
      kind: _messageKindFromDb(map['kind'] as String),
      createdAt: _dateFromIso(map['created_at'] as String),
      hasAttachment: _intToBool(map['has_attachment'] as int?),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'kind': kind.name,
      'created_at': _dateToIso(createdAt),
      'has_attachment': _boolToInt(hasAttachment),
    };
  }
}

class Report {
  const Report({
    required this.id,
    required this.propertyId,
    required this.summary,
    required this.createdAt,
  });

  final String id;
  final String propertyId;
  final String summary;
  final DateTime createdAt;

  factory Report.fromMap(Map<String, Object?> map) {
    return Report(
      id: map['id'] as String,
      propertyId: map['property_id'] as String,
      summary: map['summary'] as String,
      createdAt: _dateFromIso(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'summary': summary,
      'created_at': _dateToIso(createdAt),
    };
  }
}

class Mission {
  const Mission({
    required this.id,
    required this.propertyId,
    required this.ownerId,
    required this.status,
  });

  final String id;
  final String propertyId;
  final String ownerId;
  final String status;

  factory Mission.fromMap(Map<String, Object?> map) {
    return Mission(
      id: map['id'] as String,
      propertyId: map['property_id'] as String,
      ownerId: map['owner_id'] as String,
      status: map['status'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'owner_id': ownerId,
      'status': status,
    };
  }
}

class ConversationPreview {
  const ConversationPreview({
    required this.contactId,
    required this.lastMessage,
    required this.lastUpdated,
  });

  final String contactId;
  final String lastMessage;
  final DateTime lastUpdated;
}

UserRole _userRoleFromDb(String value) {
  return UserRole.values.firstWhere(
    (role) => role.name == value,
    orElse: () => UserRole.owner,
  );
}

MediaKind _mediaKindFromDb(String value) {
  return MediaKind.values.firstWhere(
    (kind) => kind.name == value,
    orElse: () => MediaKind.file,
  );
}

ContractStatus _contractStatusFromDb(String value) {
  return ContractStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => ContractStatus.draft,
  );
}

PaymentStatus _paymentStatusFromDb(String value) {
  return PaymentStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => PaymentStatus.pending,
  );
}

PaymentType _paymentTypeFromDb(String value) {
  return PaymentType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => PaymentType.rent,
  );
}

MessageKind _messageKindFromDb(String value) {
  return MessageKind.values.firstWhere(
    (kind) => kind.name == value,
    orElse: () => MessageKind.text,
  );
}

String normalizeEmail(String value) => value.trim().toLowerCase();

String normalizePhone(String value) => value.replaceAll(RegExp(r'\D'), '');

bool _intToBool(int? value) => value == 1;

int _boolToInt(bool value) => value ? 1 : 0;

String _dateToIso(DateTime date) => date.toIso8601String();

DateTime _dateFromIso(String value) => DateTime.parse(value);

DateTime? _dateFromIsoNullable(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.parse(value);
}
