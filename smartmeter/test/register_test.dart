import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smartmeter/services/energy_repo.dart';
import 'package:smartmeter/controllers/provider.dart';
// Generate mocks
@GenerateMocks([EnergyRepository])
import 'widget_test.mocks.dart';

void main() {
  late MockEnergyRepository mockRepo;
  late AppAuthProvider authProvider;

  // --- Test Data ---
  const tEmail = 'newstudent@uthm.edu.my';
  const tPassword = 'securePassword123';
  final tAdditionalData = {
    'name': 'New Student',
    'studentId': 'AI200555',
    'role': 'student',
    'photoUrl': 'https://example.com/photo.jpg',
  };

  setUp(() {
    mockRepo = MockEnergyRepository();

    when(mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));

    authProvider = AppAuthProvider(mockRepo);
  });

  group('Registration Module Tests', () {

    test('Sign Up Success: calls repo.register with correct data', () async {

      when(mockRepo.register(any, any, any)).thenAnswer((_) async {});

      await authProvider.signUp(
        email: tEmail,
        password: tPassword,
        additionalData: tAdditionalData,
      );

      // Verify repo was called exactly once
      verify(mockRepo.register(tEmail, tPassword, tAdditionalData)).called(1);

      // Verify loading state is reset (isLoading should be false after finish)
      expect(authProvider.isLoading, false);
    });

    test('Sign Up Failure: rethrows exception on repo error', () async {
      when(mockRepo.register(any, any, any))
          .thenThrow(Exception('Email already in use'));

      expect(
            () => authProvider.signUp(
          email: tEmail,
          password: tPassword,
          additionalData: tAdditionalData,
        ),
        throwsException,
      );

      // Verify loading state is reset even after failure
      verify(mockRepo.register(tEmail, tPassword, tAdditionalData)).called(1);
    });

    test('Sign Up Loading State: verify logic toggles isLoading', () async {
      final completer = Completer<void>();
      when(mockRepo.register(any, any, any)).thenAnswer((_) => completer.future);

      final future = authProvider.signUp(
          email: tEmail,
          password: tPassword,
          additionalData: tAdditionalData
      );

      expect(authProvider.isLoading, true);

      completer.complete();
      await future;

      expect(authProvider.isLoading, false);
    });

  });
}