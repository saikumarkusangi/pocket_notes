import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/network/connectivity_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  service.startMonitoringConnection();
  return service.statusStream;
});
