import 'package:equatable/equatable.dart';
import '../domain/module_model.dart';
import '../../../core/network/api_response.dart';

class ModuleState extends Equatable {
  final List<ModuleModel> modules;
  final ModuleModel? selectedModule;
  final PaginationModel? pagination;
  final bool isLoading;
  final String? errorMessage;

  const ModuleState({
    this.modules = const [],
    this.selectedModule,
    this.pagination,
    this.isLoading = false,
    this.errorMessage,
  });

  factory ModuleState.initial() => const ModuleState();

  /// Uses a sentinel pattern so nullable fields can be explicitly set to null.
  ModuleState copyWith({
    List<ModuleModel>? modules,
    ModuleModel? selectedModule,
    Object? pagination = _sentinel,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    bool clearModules = false,
  }) {
    return ModuleState(
      modules: clearModules ? const [] : (modules ?? this.modules),
      selectedModule: selectedModule ?? this.selectedModule,
      pagination: identical(pagination, _sentinel)
          ? this.pagination
          : pagination as PaginationModel?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
    modules,
    selectedModule,
    pagination,
    isLoading,
    errorMessage,
  ];
}
