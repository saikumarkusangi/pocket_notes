import 'package:pocket_notes/core/network/connectivity_service.dart';

/// Always-online connectivity for sync tests.
class FakeConnectivityService extends ConnectivityService {
  FakeConnectivityService() : super(startMonitoring: false);

  @override
  Future<bool> get isConnected async => true;

  @override
  Future<bool> get isDisconnected async => false;

  @override
  Future<ConnectivityStatus> checkStatus() async => ConnectivityStatus.online;
}
