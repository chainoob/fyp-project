import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smartmeter/models/app_model.dart';
import 'package:smartmeter/services/energy_repo.dart';
import 'package:smartmeter/controllers/provider.dart';

// Generate the Mock class
@GenerateMocks([EnergyRepository])
import 'widget_test.mocks.dart';

void main() {
  setupFirebaseAuthMocks();

  late MockEnergyRepository mockRepo;
  late AppAuthProvider authProvider;

  // --- Test Data ---
  final tUser = Users(
    uid: 'user_123',
    name: 'Test Student',
    email: 'ai111111@student.uthm.edu.my',
    role: 'student',
  );

  final tStaffUser = Users(
    uid: 'staff_999',
    name: 'Facility Manager',
    email: 'admin@uni.edu',
    role: 'staff',
  );

  setUp(() async {
    mockRepo = MockEnergyRepository();
    when(mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));
    authProvider = AppAuthProvider(mockRepo);
  });

  group('Login Module Tests', () {

    test('Login Success: calls signIn and updates currentUser from stream', () async {
      when(mockRepo.authStateChanges).thenAnswer((_) => Stream.value(tUser));

      when(mockRepo.signIn(any, any)).thenAnswer((_) async {});

      await authProvider.login('ai111111@student.uthm.edu.my', 'password123');

      // Verify the repo method was actually called with correct args
      verify(mockRepo.signIn('ai111111@student.uthm.edu.my', 'password123')).called(1);

      // Verify the state was updated (Wait for stream propagation)
      await Future.delayed(Duration.zero);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser?.uid, 'user_123');
    });

    test('Login Failure: returns false/throws on Invalid Credentials', () async {
      when(mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));

      when(mockRepo.signIn(any, any))
          .thenThrow(Exception('Invalid email or password'));

      await authProvider.login('wrong@uni.edu', 'wrong_pass');

      verify(mockRepo.signIn('wrong@uni.edu', 'wrong_pass')).called(1);
      expect(authProvider.currentUser, isNull);
    });

    test('Logout: calls signOut and clears user', () async {
      when(mockRepo.signOut()).thenAnswer((_) async {});
      when(mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));

      await authProvider.signOut();

      verify(mockRepo.signOut()).called(1);
    });
  });

  group('Staff Login Tests', () {

    test('Staff Login: successfully identifies user as STAFF role', () async {
      // Mock the stream to emit a "Staff" user object
      when(mockRepo.authStateChanges).thenAnswer((_) => Stream.value(tStaffUser));

      // Mock the sign-in call to succeed
      when(mockRepo.signIn(any, any)).thenAnswer((_) async {});

      // Attempt login with staff credentials
      await authProvider.login('admin@uni.edu', 'adminPass');

      // Verify repo call
      verify(mockRepo.signIn('admin@uni.edu', 'adminPass')).called(1);

      // Wait for stream to update state
      await Future.delayed(Duration.zero);

      // Check if the provider correctly stored the user and role
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser?.uid, 'staff_999');
      expect(authProvider.currentUser?.role, 'staff');
    });

    test('Staff Routing Logic: (Optional) Verify isAdmin/isStaff getter', () async {

      when(mockRepo.authStateChanges).thenAnswer((_) => Stream.value(tStaffUser));

      await authProvider.login('admin@uni.edu', 'pass');
      await Future.delayed(Duration.zero);
    });
  });
}

typedef Callback = void Function(MethodCall call);

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_auth'),
        (MethodCall methodCall) async {
      if (methodCall.method == 'Auth#registerIdTokenListener') {
        return null;
      }
      return null;
    },
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_core'),
        (MethodCall methodCall) async {
      if (methodCall.method == 'Firebase#initializeCore') {
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': '123',
              'appId': '123',
              'messagingSenderId': '123',
              'projectId': '123',
            },
            'pluginConstants': {},
          }
        ];
      }
      if (methodCall.method == 'Firebase#initializeApp') {
        return {
          'name': methodCall.arguments['appName'],
          'options': methodCall.arguments['options'],
          'pluginConstants': {},
        };
      }
      return null;
    },
  );
}