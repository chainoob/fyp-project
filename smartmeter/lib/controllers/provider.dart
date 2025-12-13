import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartmeter/models/app_model.dart';
import 'package:smartmeter/services/energy_repo.dart';

class AuthProvider extends ChangeNotifier{
  final EnergyRepository _repo;

  UserProfile? _currentUser;
  bool _isLoading = false;

  AuthProvider(this._repo) {
    _repo.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  UserProfile? get currentUser => _currentUser;
  bool get loggedIn => _currentUser != null;
  bool get isStaff => _currentUser?.role == 'staff';
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.signIn(email, password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repo.signOut();
  }

  Future<void> signUp({required String email, required String password, required Map<String, String> additionalData}) async {
    await _repo.register(email, password);
  }
}

class ApplianceProvider extends ChangeNotifier {
  final EnergyRepository _repo;
  List<Appliance> _appliances = [];
  StreamSubscription? _streamSub;

  ApplianceProvider(this._repo);

  List<Appliance> get appliances => _appliances;

  // Student: Listen to OWN devices
  void subscribeToUser(String userId) {
    _streamSub?.cancel();
    _streamSub = _repo.getAppliancesStream(userId).listen((data) {
      _appliances = data;
      notifyListeners();
    });
  }
  
  // Staff: Listen to GLOBAL pending queue
  void subscribeToQueue() {
    _streamSub?.cancel();
    _streamSub = _repo.getPendingVerificationStream().listen((data) {
      _appliances = data;
      notifyListeners();
    });
  }

  Future<void> add(String userId, String name, String type, int watts, String room) async {
    final app = Appliance(
      id: '',
      ownerId:'',
      name: name,
      type: type,
      wattage: watts,
      room: room,
      status: 'pending',
    );
    await _repo.addAppliance(userId, app);
  }

  Future<void> approve(String userId, String appId) async => 
      await _repo.updateApplianceStatus(userId, appId, 'active');

  Future<void> reject(String userId, String appId) async => 
      await _repo.updateApplianceStatus(userId, appId, 'rejected');

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}