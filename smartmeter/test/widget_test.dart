import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smartmeter/models/app_model.dart';
import 'package:smartmeter/services/energy_repo.dart';
import 'package:smartmeter/controllers/provider.dart';

// Generate mocks
@GenerateMocks([EnergyRepository])
import 'widget_test.mocks.dart';

void main() {
  late MockEnergyRepository mockRepo;
  late ApplianceProvider applianceProvider;

  // Test Data
  final tAppliance = Appliance(
      id: 'app_1',
      ownerId: 'test_uid_123',
      name: 'Gaming PC',
      type: 'computer',
      wattage: 500,
      status: 'pending',
      room: 'A-101'
  );

  setUp(() {
    mockRepo = MockEnergyRepository();
    applianceProvider = ApplianceProvider(mockRepo);
  });

  group('ApplianceProvider Tests', () {

    // Test subscribeToUser
    test('subscribeToUser: loads appliances from repository stream', () async {
      when(mockRepo.getAppliancesStream(any))
          .thenAnswer((_) => Stream.value([tAppliance]));

      applianceProvider.subscribeToUser('user_123');

      await Future.delayed(Duration.zero);

      verify(mockRepo.getAppliancesStream('user_123')).called(1);
      expect(applianceProvider.appliances.length, 1);
      expect(applianceProvider.appliances.first.name, 'Gaming PC');
    });

    //Test subscribeToQueue (for Staff)
    test('subscribeToQueue: loads pending appliances', () async {
      when(mockRepo.getPendingVerificationStream())
          .thenAnswer((_) => Stream.value([tAppliance]));

      applianceProvider.subscribeToQueue();
      await Future.delayed(Duration.zero);

      verify(mockRepo.getPendingVerificationStream()).called(1);
      expect(applianceProvider.appliances.isNotEmpty, true);
    });

    //Test add
    test('add: creates object and calls repo', () async {
      when(mockRepo.addAppliance(any, any)).thenAnswer((_) async {});

      await applianceProvider.add(
          'user_123',
          'New AC',
          'ac',
          1000,
          'Room B'
      );

      verify(mockRepo.addAppliance(
          'user_123',
          any
      )).called(1);
    });

    //Test approve
    test('approve: calls updateApplianceStatus with "active"', () async {
      when(mockRepo.updateApplianceStatus(any, any, any)).thenAnswer((_) async {});

      await applianceProvider.approve('user_123', 'app_1');

      verify(mockRepo.updateApplianceStatus(
          'user_123',
          'app_1',
          'active'
      )).called(1);
    });

    //Test reject
    test('reject: calls updateApplianceStatus with "rejected"', () async {
      when(mockRepo.updateApplianceStatus(any, any, any)).thenAnswer((_) async {});

      await applianceProvider.reject('user_123', 'app_1');

      verify(mockRepo.updateApplianceStatus(
          'user_123',
          'app_1',
          'rejected'
      )).called(1);
    });
  });
}
