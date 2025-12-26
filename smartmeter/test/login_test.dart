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
  
  // 1. Add a StreamController to control the Auth Stream manually
  late StreamController<Users?> authStreamController;

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
    
    authStreamController = StreamController<Users?>.broadcast();

    when(mockRepo.authStateChanges).thenAnswer((_) => authStreamController.stream);

    authProvider = AppAuthProvider(mockRepo);
  });

  tearDown(() {
    authStreamController.close();
  });

  group('Login Module Tests', () {

    test('Login Success: calls signIn and updates currentUser from stream', () async {
      when(mockRepo.signIn(any, any)).thenAnswer((_) async {});

      // Call login
      await authProvider.login('ai111111@student.uthm.edu.my', 'password123');

      // SIMULATE FIREBASE: "Push" the user into the stream
      authStreamController.add(tUser);
      
      // Wait for the stream listener in Provider to process the event
      await Future.delayed(Duration.zero);

      verify(mockRepo.signIn('ai111111@student.uthm.edu.my', 'password123')).called(1);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser?.uid, 'user_123');
    });

    test('Login Failure: currentUser remains null on error', () async {
      when(mockRepo.signIn(any, any))
          .thenThrow(Exception('Invalid email or password'));

      try {
        await authProvider.login('wrong@uni.edu', 'wrong_pass');
      // ignore: empty_catches
      } catch (e) {
      }

      verify(mockRepo.signIn('wrong@uni.edu', 'wrong_pass')).called(1);
      
      expect(authProvider.currentUser, isNull);
    });
  });

  group('Staff Login Tests', () {

    test('Staff Login: successfully identifies user as STAFF role', () async {
      when(mockRepo.signIn(any, any)).thenAnswer((_) async {});

      await authProvider.login('admin@uni.edu', 'adminPass');

      // SIMULATE FIREBASE: Push the STAFF user
      authStreamController.add(tStaffUser);
      
      // Wait for stream propagation
      await Future.delayed(Duration.zero);

      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser?.role, 'staff');
      expect(authProvider.currentUser?.uid, 'staff_999');
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