import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/app_config_repository.dart';
import '../models/app_config_model.dart';

// Events
abstract class AppConfigEvent extends Equatable {
  const AppConfigEvent();
  @override
  List<Object?> get props => [];
}

class AppConfigFetchStarted extends AppConfigEvent {}

// States
abstract class AppConfigState extends Equatable {
  const AppConfigState();
  @override
  List<Object?> get props => [];
}

class AppConfigInitial extends AppConfigState {}

class AppConfigLoading extends AppConfigState {}

class AppConfigSuccess extends AppConfigState {
  final AppConfigModel config;
  const AppConfigSuccess(this.config);
  @override
  List<Object?> get props => [config];
}

class AppConfigFailure extends AppConfigState {
  final String message;
  const AppConfigFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AppConfigMaintenance extends AppConfigState {
  final String message;
  const AppConfigMaintenance(this.message);
  @override
  List<Object?> get props => [message];
}

class AppConfigUpdateRequired extends AppConfigState {
  final String androidVersion;
  final String iosVersion;
  const AppConfigUpdateRequired(this.androidVersion, this.iosVersion);
  @override
  List<Object?> get props => [androidVersion, iosVersion];
}

// Bloc
class AppConfigBloc extends Bloc<AppConfigEvent, AppConfigState> {
  final AppConfigRepository repository;
  final String currentVersion = '0.1.0'; // Should match pubspec

  AppConfigBloc(this.repository) : super(AppConfigInitial()) {
    on<AppConfigFetchStarted>(_onFetchStarted);
  }

  Future<void> _onFetchStarted(
    AppConfigFetchStarted event,
    Emitter<AppConfigState> emit,
  ) async {
    emit(AppConfigLoading());
    try {
      final response = await repository.getAppConfig();
      if (response.status && response.data != null) {
        final config = response.data!;

        // Check for Maintenance
        if (config.maintenanceMode) {
          emit(AppConfigMaintenance(config.maintenanceMessage));
          return;
        }

        // Check for Force Update (Simplistic version check)
        if (config.forceUpdate && config.latestAppVersion != currentVersion) {
          emit(
            AppConfigUpdateRequired(
              config.latestAppVersion,
              config.latestAppVersion,
            ),
          );
          return;
        }

        emit(AppConfigSuccess(config));
      } else {
        emit(AppConfigFailure(response.message ?? 'Unknown error'));
      }
    } catch (e) {
      emit(AppConfigFailure(e.toString()));
    }
  }
}
