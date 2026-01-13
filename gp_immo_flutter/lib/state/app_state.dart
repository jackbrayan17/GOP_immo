import 'package:flutter/foundation.dart';

import '../data/app_repository.dart';
import '../models/app_models.dart';
import '../services/location_service.dart';
import '../services/logger_service.dart';
import '../services/notification_service.dart';
import '../services/preferences_service.dart';
import '../utils/auth_utils.dart';

class AppState extends ChangeNotifier {
  AppState({
    AppRepository? repository,
    PreferencesService? preferences,
    LocationService? locationService,
    NotificationService? notificationService,
    LoggerService? loggerService,
  })  : _repository = repository ?? AppRepository(),
        _preferences = preferences ?? PreferencesService(),
        _locationService = locationService ?? LocationService(),
        _notificationService = notificationService ?? NotificationService.instance,
        _logger = loggerService ?? LoggerService.instance;

  final AppRepository _repository;
  final PreferencesService _preferences;
  final LocationService _locationService;
  final NotificationService _notificationService;
  final LoggerService _logger;

  bool initialized = false;
  bool loading = false;
  bool authLoading = false;
  String? errorMessage;

  int navIndex = 0;
  bool showOwner = true;
  String? _currentUserId;

  String? locationLabel;
  DateTime? locationUpdatedAt;
  bool locationLoading = false;

  List<AppUser> users = [];
  List<Property> properties = [];
  List<Contract> contracts = [];
  List<Payment> payments = [];
  List<Mission> missions = [];
  List<Report> reports = [];
  List<Message> messages = [];

  bool get hasError => errorMessage != null;
  bool get isAuthenticated => _currentUserId != null;
  bool get canToggleRole => !isAuthenticated;

  Future<void> init() async {
    if (initialized) return;
    loading = true;
    notifyListeners();

    try {
      await _repository.init();
      await _repository.seedIfNeeded();
      await _repository.ensureAuthData();
      navIndex = await _preferences.loadNavIndex();
      if (navIndex < 0 || navIndex > 3) {
        navIndex = 0;
      }
      showOwner = await _preferences.loadShowOwner();
      await _notificationService.init();
      await reload();
      await _restoreSession();
      initialized = true;
      errorMessage = null;
    } catch (error, stackTrace) {
      _logger.error('Init failed', error, stackTrace);
      errorMessage = 'Erreur lors du demarrage.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> reload() async {
    try {
      users = await _repository.fetchUsers();
      properties = await _repository.fetchProperties();
      contracts = await _repository.fetchContracts();
      payments = await _repository.fetchPayments();
      missions = await _repository.fetchMissions();
      reports = await _repository.fetchReports();
      messages = await _repository.fetchMessages();
      errorMessage = null;
    } catch (error, stackTrace) {
      _logger.error('Reload failed', error, stackTrace);
      errorMessage = 'Erreur lors du chargement des donnees.';
    } finally {
      notifyListeners();
    }
  }

  AppUser get owner {
    return users.firstWhere(
      (user) => user.role == UserRole.owner,
      orElse: () => users.isNotEmpty ? users.first : _fallbackUser,
    );
  }

  AppUser get providerLead {
    return users.firstWhere(
      (user) => user.role == UserRole.provider,
      orElse: () => users.isNotEmpty ? users.first : _fallbackUser,
    );
  }

  AppUser get currentUser {
    final sessionId = _currentUserId;
    if (sessionId != null) {
      return userById(sessionId);
    }
    return showOwner ? owner : providerLead;
  }

  AppUser get client {
    return users.firstWhere(
      (user) => user.role == UserRole.client,
      orElse: () => _fallbackClient,
    );
  }

  List<AppUser> get providers {
    return users
        .where((user) => user.role == UserRole.provider && user.marketplaceVisible)
        .toList();
  }

  List<AppUser> get allProviders {
    return users.where((user) => user.role == UserRole.provider).toList();
  }

  List<String> get specializations {
    final values = providers.map((user) => user.specialization).where((s) => s.isNotEmpty).toSet();
    final list = values.toList();
    list.sort();
    return list;
  }

  Future<void> _restoreSession() async {
    final savedUserId = await _preferences.loadCurrentUserId();
    if (savedUserId == null) return;
    if (!users.any((user) => user.id == savedUserId)) {
      await _preferences.clearCurrentUserId();
      _currentUserId = null;
      return;
    }
    _currentUserId = savedUserId;
    await _applyRoleView(userById(savedUserId));
  }

  Future<void> _applyRoleView(AppUser user) async {
    if (user.role == UserRole.owner) {
      showOwner = true;
      await _preferences.saveShowOwner(true);
    } else if (user.role == UserRole.provider) {
      showOwner = false;
      await _preferences.saveShowOwner(false);
    } else {
      showOwner = true;
      await _preferences.saveShowOwner(true);
    }
  }

  List<Message> messagesForContact(String contactId, {String? currentUserId}) {
    final currentId = currentUserId ?? currentUser.id;
    final results = messages.where((message) {
      return (message.senderId == currentId && message.receiverId == contactId) ||
          (message.receiverId == currentId && message.senderId == contactId);
    }).toList();
    results.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return results;
  }

  List<ConversationPreview> get conversations {
    final map = <String, Message>{};
    for (final message in messages) {
      if (message.senderId != currentUser.id && message.receiverId != currentUser.id) {
        continue;
      }
      final contactId = message.senderId == currentUser.id ? message.receiverId : message.senderId;
      final existing = map[contactId];
      if (existing == null || message.createdAt.isAfter(existing.createdAt)) {
        map[contactId] = message;
      }
    }
    final list = map.entries
        .map(
          (entry) => ConversationPreview(
            contactId: entry.key,
            lastMessage: entry.value.content,
            lastUpdated: entry.value.createdAt,
          ),
        )
        .toList();
    list.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return list;
  }

  AppUser userById(String userId) {
    for (final user in users) {
      if (user.id == userId) return user;
    }
    return _fallbackContact;
  }

  List<AppUser> get suggestions {
    final contactedIds = conversations.map((c) => c.contactId).toSet();
    return providers.where((provider) => !contactedIds.contains(provider.id)).toList();
  }

  Future<void> setNavIndex(int index) async {
    _logger.info('Navigation index set to $index');
    navIndex = index;
    notifyListeners();
    await _preferences.saveNavIndex(index);
  }

  Future<void> setShowOwner(bool value) async {
    if (!canToggleRole) return;
    _logger.info('Role view set to ${value ? 'owner' : 'provider'}');
    showOwner = value;
    notifyListeners();
    await _preferences.saveShowOwner(value);
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    authLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.authenticate(
        identifier: identifier,
        password: password,
      );
      if (user == null) {
        errorMessage = 'Identifiants invalides.';
        return false;
      }
      _currentUserId = user.id;
      await _preferences.saveCurrentUserId(user.id);
      await _applyRoleView(user);
      errorMessage = null;
      return true;
    } catch (error, stackTrace) {
      _logger.error('Login failed', error, stackTrace);
      errorMessage = error is AuthException ? error.message : 'Erreur de connexion.';
      return false;
    } finally {
      authLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String specialization = '',
  }) async {
    authLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.registerUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
        specialization: specialization,
      );
      users = [...users, user];
      _currentUserId = user.id;
      await _preferences.saveCurrentUserId(user.id);
      await _applyRoleView(user);
      errorMessage = null;
      return true;
    } catch (error, stackTrace) {
      _logger.error('Signup failed', error, stackTrace);
      errorMessage = error is AuthException ? error.message : 'Erreur lors de la creation du compte.';
      return false;
    } finally {
      authLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUserId = null;
    await _preferences.clearCurrentUserId();
    errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshLocation() async {
    locationLoading = true;
    notifyListeners();
    try {
      final position = await _locationService.getCurrentPosition();
      locationLabel = 'Lat ${position.latitude.toStringAsFixed(4)}, Lng ${position.longitude.toStringAsFixed(4)}';
      locationUpdatedAt = DateTime.now();
      errorMessage = null;
    } catch (error) {
      locationLabel = 'Localisation indisponible';
      errorMessage = 'Erreur de localisation. Verifiez les permissions.';
    } finally {
      locationLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendTestNotification() async {
    try {
      if (!_notificationService.isReady) {
        errorMessage = 'Notifications non disponibles sur cette plateforme.';
        notifyListeners();
        return;
      }
      await _notificationService.showNotification(
        title: 'GP Immo',
        body: 'Notification de test envoyee.',
      );
      errorMessage = null;
    } catch (error, stackTrace) {
      _logger.error('Notification failed', error, stackTrace);
      errorMessage = 'Erreur lors de la notification.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> addProperty(Property property) async {
    try {
      _logger.info('Adding property ${property.id}');
      await _repository.insertProperty(property);
      
      // Save media items associated with the property
      if (property.media.isNotEmpty) {
        for (final media in property.media) {
           await _repository.insertMedia(property.id, media);
        }
      }

      properties = [...properties, property];
      errorMessage = null;
      await _notificationService.showNotification(
        title: 'Nouveau bien',
        body: 'Le bien ${property.title} a ete ajoute.',
      );
    } catch (error, stackTrace) {
      _logger.error('Add property failed', error, stackTrace);
      errorMessage = 'Erreur lors de la creation du bien.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> addMedia(String propertyId, MediaItem media) async {
    try {
      _logger.info('Adding media ${media.id} to property $propertyId');
      await _repository.insertMedia(propertyId, media);
      properties = properties.map((property) {
        if (property.id != propertyId) return property;
        return Property(
          id: property.id,
          ownerId: property.ownerId,
          title: property.title,
          propertyType: property.propertyType,
          listingStatus: property.listingStatus,
          address: property.address,
          description: property.description,
          price: property.price,
          furnished: property.furnished,
          media: [...property.media, media],
        );
      }).toList();
      errorMessage = null;
    } catch (error, stackTrace) {
      _logger.error('Add media failed', error, stackTrace);
      errorMessage = 'Erreur lors de la sauvegarde du media.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> addContract(Contract contract) async {
    try {
      _logger.info('Adding contract ${contract.id}');
      await _repository.insertContract(contract);
      contracts = [...contracts, contract];
      errorMessage = null;
    } catch (error, stackTrace) {
      _logger.error('Add contract failed', error, stackTrace);
      errorMessage = 'Erreur lors de la creation du contrat.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> addPayment(Payment payment) async {
    try {
      _logger.info('Adding payment ${payment.id}');
      await _repository.insertPayment(payment);
      payments = [...payments, payment];
      errorMessage = null;
    } catch (error, stackTrace) {
      _logger.error('Add payment failed', error, stackTrace);
      errorMessage = 'Erreur lors de la creation du paiement.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> addMission(Mission mission) async {
    try {
      _logger.info('Adding mission ${mission.id}');
      await _repository.insertMission(mission);
      missions = [...missions, mission];
      errorMessage = null;
    } catch (error, stackTrace) {
      _logger.error('Add mission failed', error, stackTrace);
      errorMessage = 'Erreur lors de la creation de la mission.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> addReport(Report report) async {
    try {
      _logger.info('Adding report ${report.id}');
      await _repository.insertReport(report);
      reports = [...reports, report];
      errorMessage = null;
    } catch (error, stackTrace) {
      _logger.error('Add report failed', error, stackTrace);
      errorMessage = 'Erreur lors de la creation du rapport.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> sendMessage(Message message) async {
    try {
      _logger.info('Sending message ${message.id}');
      await _repository.insertMessage(message);
      final updated = [...messages, message];
      updated.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      messages = updated;
      errorMessage = null;
    } catch (error, stackTrace) {
      _logger.error('Send message failed', error, stackTrace);
      errorMessage = 'Erreur lors de l\'envoi du message.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateMarketplaceVisibility(String userId, bool visible) async {
    try {
      _logger.info('Updating user visibility $userId -> $visible');
      await _repository.updateUserMarketplaceVisibility(userId, visible);
      users = users.map((user) {
        if (user.id != userId) return user;
        return AppUser(
          id: user.id,
          name: user.name,
          role: user.role,
          email: user.email,
          phone: user.phone,
          specialization: user.specialization,
          marketplaceVisible: visible,
          rating: user.rating,
          passwordHash: user.passwordHash,
        );
      }).toList();
      errorMessage = null;
    } catch (error, stackTrace) {
      _logger.error('Update visibility failed', error, stackTrace);
      errorMessage = 'Erreur lors de la mise a jour du profil.';
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  static const AppUser _fallbackUser = AppUser(
    id: 'fallback',
    name: 'Utilisateur',
    role: UserRole.owner,
    email: '',
    phone: '',
    specialization: '',
    marketplaceVisible: false,
    rating: 0,
    passwordHash: '',
  );

  static const AppUser _fallbackClient = AppUser(
    id: 'fallback_client',
    name: 'Client',
    role: UserRole.client,
    email: '',
    phone: '',
    specialization: '',
    marketplaceVisible: false,
    rating: 0,
    passwordHash: '',
  );

  static const AppUser _fallbackContact = AppUser(
    id: 'unknown',
    name: 'Utilisateur inconnu',
    role: UserRole.owner,
    email: '',
    phone: '',
    specialization: '',
    marketplaceVisible: false,
    rating: 0,
    passwordHash: '',
  );
}
