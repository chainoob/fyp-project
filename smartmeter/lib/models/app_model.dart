import 'package:cloud_firestore/cloud_firestore.dart';

// --- USER MODEL ---
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String role; // 'student' or 'staff'
  final String? studentId;
  final String? dormBlock;
  final String? department;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.studentId,
    this.dormBlock,
    this.department,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      name: data['displayName'] ?? 'Unknown',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      studentId: data['studentId'],
      dormBlock: data['dormBlock'],
      department: data['department'],
    );
  }
}

// --- APPLIANCE MODEL ---
class Appliance {
  final String id;
  final String name;
  final String type;
  final int wattage;
  final String status; // 'pending', 'active', 'rejected'
  final String? room;
  final DateTime? verificationDate;

  const Appliance({
    required this.id,
    required this.name,
    required this.type,
    required this.wattage,
    this.status = 'pending',
    this.room,
    this.verificationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'wattage': wattage,
      'status': status,
      'room': room,
      'verificationDate': verificationDate,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Appliance.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appliance(
      id: doc.id,
      name: data['name'] ?? 'Unknown Device',
      type: data['type'] ?? 'other',
      wattage: data['wattage'] ?? 0,
      status: data['status'] ?? 'pending',
      room: data['room'],
      verificationDate: (data['verificationDate'] as Timestamp?)?.toDate(),
    );
  }
}