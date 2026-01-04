import '../models/app_models.dart';
import '../utils/auth_utils.dart';

class MockData {
  static final String _defaultPasswordHash = hashPassword('gopimmo123');

  static final AppUser owner = AppUser(
    id: 'u_owner',
    name: 'Aminata Diallo',
    role: UserRole.owner,
    email: 'aminata@gopimmo.local',
    phone: '77 123 45 67',
    specialization: '',
    marketplaceVisible: false,
    rating: 0,
    passwordHash: _defaultPasswordHash,
  );

  static final AppUser providerLead = AppUser(
    id: 'u_provider_1',
    name: 'Malick Sane',
    role: UserRole.provider,
    email: 'malick@gopimmo.local',
    phone: '70 909 11 02',
    specialization: 'Plomberie',
    marketplaceVisible: true,
    rating: 4.8,
    passwordHash: _defaultPasswordHash,
  );

  static final AppUser clientLead = AppUser(
    id: 'u_client_1',
    name: 'Awa Sarr',
    role: UserRole.client,
    email: 'awa@gopimmo.local',
    phone: '77 553 12 45',
    specialization: '',
    marketplaceVisible: false,
    rating: 0,
    passwordHash: _defaultPasswordHash,
  );

  static final List<AppUser> users = [
    owner,
    providerLead,
    AppUser(
      id: 'u_provider_2',
      name: 'Coumba Diop',
      role: UserRole.provider,
      email: 'coumba@gopimmo.local',
      phone: '76 441 88 09',
      specialization: 'Carrelage',
      marketplaceVisible: true,
      rating: 4.6,
      passwordHash: _defaultPasswordHash,
    ),
    AppUser(
      id: 'u_provider_3',
      name: 'Ibrahima Ba',
      role: UserRole.provider,
      email: 'ibrahima@gopimmo.local',
      phone: '77 330 01 44',
      specialization: 'Electricite',
      marketplaceVisible: true,
      rating: 4.7,
      passwordHash: _defaultPasswordHash,
    ),
    AppUser(
      id: 'u_provider_4',
      name: 'Sarah Ndiaye',
      role: UserRole.provider,
      email: 'sarah@gopimmo.local',
      phone: '78 552 12 90',
      specialization: 'Menuiserie',
      marketplaceVisible: true,
      rating: 4.5,
      passwordHash: _defaultPasswordHash,
    ),
    AppUser(
      id: 'u_provider_5',
      name: 'Khadija Fall',
      role: UserRole.provider,
      email: 'khadija@gopimmo.local',
      phone: '70 211 92 12',
      specialization: 'Peinture',
      marketplaceVisible: true,
      rating: 4.4,
      passwordHash: _defaultPasswordHash,
    ),
    clientLead,
  ];

  static final List<Property> properties = [
    Property(
      id: 'p_1',
      ownerId: owner.id,
      title: 'Residence Baobab',
      propertyType: 'Appartement meuble',
      listingStatus: 'Location',
      address: 'Sacre Coeur, Dakar',
      description: 'T3 lumineux, balcon, cuisine equipee.',
      price: 380000,
      furnished: true,
      media: const [
        MediaItem(id: 'm1', kind: MediaKind.image, label: 'Facade.jpg'),
        MediaItem(id: 'm2', kind: MediaKind.image, label: 'Salon.jpg'),
        MediaItem(id: 'm3', kind: MediaKind.video, label: 'Visite.mp4'),
      ],
    ),
    Property(
      id: 'p_2',
      ownerId: owner.id,
      title: 'Studio Medina',
      propertyType: 'Studio en location',
      listingStatus: 'Location',
      address: 'Medina, Dakar',
      description: 'Studio compact proche marche, eau chaude.',
      price: 175000,
      furnished: false,
      media: const [
        MediaItem(id: 'm4', kind: MediaKind.image, label: 'Cuisine.jpg'),
        MediaItem(id: 'm5', kind: MediaKind.image, label: 'Chambre.jpg'),
      ],
    ),
    Property(
      id: 'p_3',
      ownerId: owner.id,
      title: 'Immeuble Plateau',
      propertyType: 'Immeuble',
      listingStatus: 'Vente',
      address: 'Plateau, Dakar',
      description: 'Immeuble R+3 avec local commercial.',
      price: 125000000,
      furnished: false,
      media: const [
        MediaItem(id: 'm6', kind: MediaKind.image, label: 'Facade_2.jpg'),
        MediaItem(id: 'm7', kind: MediaKind.file, label: 'Plan.pdf'),
      ],
    ),
  ];

  static final List<Contract> contracts = [
    Contract(
      id: 'c1',
      propertyId: 'p_1',
      tenantName: 'Abdou Mbaye',
      status: ContractStatus.active,
      rent: 380000,
      startDate: DateTime(2025, 8, 1),
      endDate: DateTime(2026, 7, 31),
    ),
    Contract(
      id: 'c2',
      propertyId: 'p_2',
      tenantName: 'Mariama Kane',
      status: ContractStatus.draft,
      rent: 175000,
      startDate: DateTime(2025, 12, 1),
      endDate: DateTime(2026, 11, 30),
    ),
  ];

  static final List<Payment> payments = [
    Payment(
      id: 'pay1',
      propertyId: 'p_1',
      amount: 380000,
      paymentType: PaymentType.rent,
      status: PaymentStatus.paid,
      dueDate: DateTime(2025, 11, 5),
    ),
    Payment(
      id: 'pay2',
      propertyId: 'p_2',
      amount: 175000,
      paymentType: PaymentType.rent,
      status: PaymentStatus.pending,
      dueDate: DateTime(2025, 11, 10),
    ),
    Payment(
      id: 'pay3',
      propertyId: 'p_1',
      amount: 95000,
      paymentType: PaymentType.provider,
      status: PaymentStatus.late,
      dueDate: DateTime(2025, 10, 28),
    ),
  ];

  static final List<Mission> missions = [
    Mission(
      id: 'mis1',
      propertyId: 'p_1',
      ownerId: owner.id,
      status: 'Remise en etat plomberie',
    ),
    Mission(
      id: 'mis2',
      propertyId: 'p_3',
      ownerId: owner.id,
      status: 'Audit electricite',
    ),
  ];

  static final List<Report> reports = [
    Report(
      id: 'r1',
      propertyId: 'p_1',
      summary: 'Changement robinetterie cuisine et test fuite.',
      createdAt: DateTime(2025, 10, 20, 14, 30),
    ),
    Report(
      id: 'r2',
      propertyId: 'p_3',
      summary: 'Inspection colonnes electriques, RAS.',
      createdAt: DateTime(2025, 10, 15, 9, 10),
    ),
  ];

  static final List<Message> messages = [
    Message(
      id: 'm1',
      senderId: owner.id,
      receiverId: providerLead.id,
      content: 'Bonjour, pouvez-vous intervenir sur la plomberie ?',
      kind: MessageKind.text,
      createdAt: DateTime(2025, 10, 12, 9, 15),
      hasAttachment: false,
    ),
    Message(
      id: 'm2',
      senderId: providerLead.id,
      receiverId: owner.id,
      content: 'Oui, je peux passer demain matin. Je joins un devis.',
      kind: MessageKind.quote,
      createdAt: DateTime(2025, 10, 12, 10, 2),
      hasAttachment: true,
    ),
    Message(
      id: 'm3',
      senderId: owner.id,
      receiverId: providerLead.id,
      content: 'Parfait, validez le devis et envoyez le rapport.',
      kind: MessageKind.text,
      createdAt: DateTime(2025, 10, 12, 10, 10),
      hasAttachment: false,
    ),
    Message(
      id: 'm4',
      senderId: providerLead.id,
      receiverId: owner.id,
      content: 'Travaux termines. Rapport en piece jointe.',
      kind: MessageKind.proof,
      createdAt: DateTime(2025, 10, 13, 16, 20),
      hasAttachment: true,
    ),
  ];

  static final List<ConversationPreview> conversations = [
    ConversationPreview(
      contactId: providerLead.id,
      lastMessage: 'Travaux termines. Rapport en piece jointe.',
      lastUpdated: DateTime(2025, 10, 13, 16, 20),
    ),
    ConversationPreview(
      contactId: 'u_provider_2',
      lastMessage: 'Je peux faire un devis carrelage cette semaine.',
      lastUpdated: DateTime(2025, 10, 9, 11, 5),
    ),
    ConversationPreview(
      contactId: 'u_provider_3',
      lastMessage: 'Disponible pour une inspection avant fin du mois.',
      lastUpdated: DateTime(2025, 10, 7, 9, 40),
    ),
  ];

  static final List<AppUser> suggestions = [
    users[3],
    users[4],
    users[5],
  ];

  static final List<String> specializations = [
    'Plomberie',
    'Menuiserie',
    'Carrelage',
    'Electricite',
    'Peinture',
    'Climatisation',
  ];

  static List<AppUser> providers() {
    return users
        .where((user) => user.role == UserRole.provider && user.marketplaceVisible)
        .toList();
  }

  static AppUser userById(String id) {
    return users.firstWhere((user) => user.id == id);
  }

  static Property propertyById(String id) {
    return properties.firstWhere((property) => property.id == id);
  }

  static List<Message> messagesFor(String contactId, String currentUserId) {
    final results = messages.where((message) {
      return (message.senderId == currentUserId && message.receiverId == contactId) ||
          (message.receiverId == currentUserId && message.senderId == contactId);
    }).toList();
    results.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return results;
  }
}
