// lib/app/locator.dart
import 'package:get_it/get_it.dart';
import '../core/services/auth_router_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/firebase_service.dart';
// Add this import
import '../features/growth/services/growth_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register existing services
  locator.registerLazySingleton<FirebaseService>(() => FirebaseService());
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton(() => AuthRouterService());

  // Add GrowthService registration - this fixes the error
  locator.registerLazySingleton<GrowthService>(() => GrowthService());
}
