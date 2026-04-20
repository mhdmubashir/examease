import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ───────────────────── Events ─────────────────────

abstract class NetworkEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Check current network status once.
class NetworkCheckRequested extends NetworkEvent {}

/// Internal event fired when connectivity changes.
class _NetworkStatusChanged extends NetworkEvent {
  final List<ConnectivityResult> results;
  _NetworkStatusChanged(this.results);

  @override
  List<Object?> get props => [results];
}

// ───────────────────── States ─────────────────────

abstract class NetworkState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NetworkInitial extends NetworkState {}

class NetworkConnected extends NetworkState {}

class NetworkDisconnected extends NetworkState {}

// ───────────────────── BLoC ─────────────────────

/// Monitors device connectivity and emits connected/disconnected states.
///
/// Uses connectivity_plus to listen for real-time changes.
/// Subscribes in the constructor so it starts monitoring immediately.
class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkBloc({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(NetworkInitial()) {
    on<NetworkCheckRequested>(_onCheckRequested);
    on<_NetworkStatusChanged>(_onStatusChanged);

    // Start listening to connectivity changes immediately
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) => add(_NetworkStatusChanged(results)),
    );

    // Also check current status
    add(NetworkCheckRequested());
  }

  Future<void> _onCheckRequested(
    NetworkCheckRequested event,
    Emitter<NetworkState> emit,
  ) async {
    final results = await _connectivity.checkConnectivity();
    _emitFromResults(results, emit);
  }

  void _onStatusChanged(
    _NetworkStatusChanged event,
    Emitter<NetworkState> emit,
  ) {
    _emitFromResults(event.results, emit);
  }

  void _emitFromResults(
    List<ConnectivityResult> results,
    Emitter<NetworkState> emit,
  ) {
    final hasConnection = results.any(
      (r) => r != ConnectivityResult.none,
    );

    if (hasConnection) {
      emit(NetworkConnected());
    } else {
      emit(NetworkDisconnected());
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
