//import '../models/account.dart';

//import 'account_provider.dart';
//import 'auth_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/providers/user_provider.dart';

import 'auth_provider.dart';
import 'campus_provider.dart';
import 'location_provider.dart';
import 'routing_provider.dart';
import 'search_provider.dart';

/*final authProvider = StateNotifierProvider<Auth, AuthState>((ref) {
  return Auth(ref);
});

final accountProvider = StateNotifierProvider<AccountProvider, Account?>((ref) {
  return AccountProvider(ref);
});*/

final locationProvider =
    StateNotifierProvider.autoDispose<LocationProvider, LocationState>((ref) {
  return LocationProvider(ref);
});

final routingProvider =
    StateNotifierProvider<RoutingProvider, RouteState>((ref) {
  return RoutingProvider(ref);
});

final searchProvider =
    StateNotifierProvider<SearchProvider, SearchState>((ref) {
  return SearchProvider(ref);
});

final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  return AuthProvider(ref);
});

final userProvider = StateNotifierProvider<UserProvider, UserState>((ref) {
  return UserProvider(ref);
});

final campusProvider =
    StateNotifierProvider<CampusProvider, CampusState>((ref) {
  return CampusProvider(ref);
});
