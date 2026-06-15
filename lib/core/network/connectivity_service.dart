import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../errors/exceptions.dart' as app_exceptions;

enum ConnectivityStatus { online, offline }

class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
    bool startMonitoring = true,
  }) : _connectivity = connectivity ?? Connectivity() {
    if (startMonitoring) {
      startMonitoringConnection();
    }
  }

  final Connectivity _connectivity;
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  ConnectivityStatus? _lastStatus;

  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  ConnectivityStatus? get lastKnownStatus => _lastStatus;

  bool get isMonitoring => _connectivitySubscription != null;

  Future<bool> get isConnected async =>
      await checkStatus() == ConnectivityStatus.online;

  Future<bool> get isDisconnected async =>
      await checkStatus() == ConnectivityStatus.offline;

  Future<ConnectivityStatus> checkStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _mapConnectivityResults(results);
    } catch (_) {
      return ConnectivityStatus.offline;
    }
  }

  Future<void> requireConnection() async {
    if (await isDisconnected) {
      throw app_exceptions.NetworkException(message: 'No internet connection');
    }
  }

  void startMonitoringConnection() {
    if (isMonitoring) {
      return;
    }

    unawaited(refreshStatus());
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) => _emitStatus(_mapConnectivityResults(results)),
    );
  }

  Future<void> stopMonitoringConnection() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  Future<ConnectivityStatus> refreshStatus() async {
    final status = await checkStatus();
    _emitStatus(status);
    return status;
  }

  ConnectivityStatus _mapConnectivityResults(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }

    return ConnectivityStatus.online;
  }

  void _emitStatus(ConnectivityStatus status) {
    if (_lastStatus == status || _statusController.isClosed) {
      return;
    }

    _lastStatus = status;
    _statusController.add(status);
  }

  Future<void> dispose() async {
    await stopMonitoringConnection();
    await _statusController.close();
  }
}
