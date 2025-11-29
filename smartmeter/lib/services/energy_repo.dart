import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeter/models/app_model.dart';

// Abstract Interface
abstract class EnergyRepository {
  Stream<UserProfile?> get authStateChanges;
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Stream<List<Appliance>> getAppliancesStream(String userId); 
  Stream<List<Appliance>> getPendingVerificationStream(); 
  Future<void> addAppliance(String userId, Appliance app);
  Future<void> updateApplianceStatus(String userId, String appId, String status);
  Future<void> triggerDisaggregation(String userId, String billId);
}

// Concrete Implementation
class FirestoreRepository implements EnergyRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<UserProfile?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null; 
      return UserProfile.fromFirestore(doc);
    });
  }

  @override
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Stream<List<Appliance>> getAppliancesStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('appliances')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Appliance.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<Appliance>> getPendingVerificationStream() {
    return _db
        .collectionGroup('appliances')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Appliance.fromFirestore(doc)).toList());
  }

  @override
  Future<void> addAppliance(String userId, Appliance app) async {
    await _db.collection('users').doc(userId).collection('appliances').add(app.toMap());
  }

  @override
  Future<void> updateApplianceStatus(String userId, String appId, String status) async {
    await _db.collection('users').doc(userId).collection('appliances').doc(appId).update({
      'status': status,
      'verificationDate': status == 'active' ? FieldValue.serverTimestamp() : null,
    });
  }

  @override
  Future<void> triggerDisaggregation(String userId, String billId) async {
    await Future.delayed(const Duration(seconds: 1)); // Placeholder for API call
  }
}