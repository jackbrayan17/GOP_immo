enum UserRole {
  owner,
  provider,
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
    required this.phone,
    required this.specialization,
    required this.marketplaceVisible,
    required this.rating,
  });

  final String id;
  final String name;
  final UserRole role;
  final String phone;
  final String specialization;
  final bool marketplaceVisible;
  final double rating;

  String get roleLabel => role == UserRole.owner ? 'Proprietaire' : 'Prestataire';
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
