import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/ad_model.dart';
import '../domain/get_ads_usecase.dart';

// Events
abstract class AdEvent extends Equatable {
  const AdEvent();
  @override
  List<Object?> get props => [];
}

class FetchAdsRequested extends AdEvent {
  final String placement;
  const FetchAdsRequested(this.placement);
  @override
  List<Object?> get props => [placement];
}

// States
abstract class AdState extends Equatable {
  const AdState();
  @override
  List<Object?> get props => [];
}

class AdInitial extends AdState {}

class AdLoading extends AdState {}

class AdLoaded extends AdState {
  final List<AdModel> ads;
  const AdLoaded(this.ads);
  @override
  List<Object?> get props => [ads];
}

class AdFailure extends AdState {
  final String message;
  const AdFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AdBloc extends Bloc<AdEvent, AdState> {
  final GetAdsUseCase getAdsUseCase;

  AdBloc(this.getAdsUseCase) : super(AdInitial()) {
    on<FetchAdsRequested>(_onFetchAdsRequested);
  }

  Future<void> _onFetchAdsRequested(
    FetchAdsRequested event,
    Emitter<AdState> emit,
  ) async {
    emit(AdLoading());
    try {
      final response = await getAdsUseCase(event.placement);
      if (response.status && response.data != null) {
        emit(AdLoaded(response.data!));
      } else {
        emit(AdFailure(response.message ?? 'Failed to fetch ads'));
      }
    } catch (e) {
      emit(AdFailure(e.toString()));
    }
  }
}
