import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'module_bloc.dart';
import 'module_state.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../../payments/presentation/payment_bloc.dart';
import '../../ads/presentation/banner_ad_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/custom_search.dart';
import '../../../core/widgets/pagination_control.dart';
import '../../../core/widgets/helper/responsive.dart';
import '../../../core/network/api_response.dart';
import '../../../core/widgets/custom_text_button.dart';

class ModuleScreen extends StatefulWidget {
  final String examId;
  final String examTitle;

  const ModuleScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  String _searchQuery = '';
  String _accessType = 'ALL'; // ALL, FREE, PAID

  @override
  void initState() {
    super.initState();
    _fetchModules();
  }

  void _fetchModules() {
    final List<Map<String, dynamic>> filters = [];
    if (_accessType != 'ALL') {
      filters.add({'accessType': _accessType});
    }

    context.read<ModuleBloc>().add(
          FetchModulesRequested(
            widget.examId,
            pagination: PaginationModel.empty().copyWith(search: _searchQuery),
          ),
        );
  }

  @override
  void dispose() {
    // Clear singleton app-level bloc data so it doesn't flash when re-opening
    context.read<ModuleBloc>().add(ResetModuleRequested());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Module unlocked successfully!')),
              );
              // Refresh user to get updated purchasedItems
              context.read<AuthBloc>().add(AuthCheckRequested());
            } else if (state is PaymentFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text(widget.examTitle)),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final user = authState.user;
            final purchasedItems = user?.purchasedItems ?? [];

            return BlocListener<ModuleBloc, ModuleState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: BlocBuilder<ModuleBloc, ModuleState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(Responsive.s(16)),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomSearchBar(
                                hintText: 'Search modules...',
                                onSearch: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                    // _pagination = _pagination.copyWith(page: 1);
                                  });
                                  _fetchModules();
                                },
                              ),
                            ),
                            SizedBox(width: Responsive.s(8)),
                            IconButton(
                              onPressed: () => _showFilterBottomSheet(context),
                              icon: const Icon(Icons.filter_list),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.blue.withValues(
                                  alpha: 0.1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    Responsive.s(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const BannerAdWidget(placement: 'BANNER_EXAM'),
                      Expanded(
                        child: state.isLoading && state.modules.isEmpty
                            ? ListView.builder(
                                padding: EdgeInsets.all(Responsive.s(16)),
                                itemCount: 5,
                                itemBuilder: (context, index) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: Responsive.s(8.0),
                                  ),
                                  child: ShimmerLoading.rectangular(
                                    height: Responsive.s(80),
                                  ),
                                ),
                              )
                            : state.errorMessage != null &&
                                  state.modules.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: Responsive.s(60),
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: Responsive.s(16)),
                                    const Text(
                                      'Failed to load modules',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: Responsive.s(8)),
                                    ElevatedButton(
                                      onPressed: _fetchModules,
                                      child: const Text('Try Again'),
                                    ),
                                  ],
                                ),
                              )
                            : state.modules.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: Responsive.s(60),
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: Responsive.s(16)),
                                    const Text(
                                      'No modules found matching your criteria',
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.all(Responsive.s(16)),
                                itemCount: state.modules.length,
                                itemBuilder: (context, index) {
                                  final module = state.modules[index];
                                  final isUnlocked =
                                      module.isFree ||
                                      module.price == 0 ||
                                      module.accessType == 'FREE' ||
                                      purchasedItems.contains(module.id);

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        Responsive.s(12),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(
                                      bottom: Responsive.s(12),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(
                                        Responsive.s(12),
                                      ),
                                      title: Text(
                                        module.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: Responsive.s(16),
                                        ),
                                      ),
                                      subtitle: Text(
                                        module.description ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: Responsive.s(13),
                                        ),
                                      ),
                                      trailing: isUnlocked
                                          ? Icon(
                                              Icons.arrow_forward_ios,
                                              size: Responsive.s(16),
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.lock,
                                                  size: Responsive.s(16),
                                                  color: Colors.orange,
                                                ),
                                                Text(
                                                  '₹${module.price}',
                                                  style: TextStyle(
                                                    fontSize: Responsive.s(12),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                      onTap: () {
                                        if (isUnlocked) {
                                          context.go(
                                            '/home/modules/${widget.examId}/contents/${module.id}?title=${Uri.encodeComponent(module.title)}',
                                          );
                                        } else {
                                          _showUnlockDialog(
                                            context,
                                            module,
                                            user?.email ?? '',
                                            '',
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (state.pagination != null &&
                          state.pagination!.totalSize > 1)
                        PaginationControls(
                          currentPage: state.pagination!.page,
                          totalPages: state.pagination!.pageSize,
                          totalItems: state.pagination!.totalSize,
                          onNextPage: () {
                            // setState(() {
                            //   _pagination = _pagination.copyWith(
                            //     page: state.pagination!.page + 1,
                            //   );
                            // });
                            _fetchModules();
                          },
                          onPrevPage: () {
                            // setState(() {
                            //   _pagination = _pagination.copyWith(
                            //     page: state.pagination!.page - 1,
                            //   );
                            // });
                            _fetchModules();
                          },
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(Responsive.s(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Modules',
                    style: TextStyle(
                      fontSize: Responsive.s(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.s(20)),
                  Text(
                    'Access Type',
                    style: TextStyle(
                      fontSize: Responsive.s(14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: Responsive.s(10)),
                  Row(
                    children: [
                      _buildFilterChip('All', _accessType == 'ALL', () {
                        setModalState(() => _accessType = 'ALL');
                        setState(() {});
                      }),
                      SizedBox(width: Responsive.s(8)),
                      _buildFilterChip('Free', _accessType == 'FREE', () {
                        setModalState(() => _accessType = 'FREE');
                        setState(() {});
                      }),
                      SizedBox(width: Responsive.s(8)),
                      _buildFilterChip('Paid', _accessType == 'PAID', () {
                        setModalState(() => _accessType = 'PAID');
                        setState(() {});
                      }),
                    ],
                  ),
                  SizedBox(height: Responsive.s(30)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          // _pagination = _pagination.copyWith(page: 1);
                        });
                        _fetchModules();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: Responsive.s(12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.s(8)),
                        ),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                  SizedBox(height: Responsive.s(10)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.s(16),
          vertical: Responsive.s(8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Responsive.s(20)),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : Colors.blue.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showUnlockDialog(
    BuildContext context,
    dynamic module,
    String email,
    String phone,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unlock ${module.title}'),
        content: Text(
          'This module costs ₹${module.price}. Would you like to purchase it?',
        ),
        actions: [
          CustomTextButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
            buttonColor: Colors.transparent,
            textStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: Responsive.s(14),
              fontWeight: FontWeight.w600,
            ),
            width: Responsive.s(100),
          ),
          CustomTextButton(
            text: 'Unlock Now',
            onPressed: () {
              Navigator.pop(context);
              context.read<PaymentBloc>().add(
                PaymentStarted(
                  moduleId: module.id,
                  amount: module.price,
                  userEmail: email,
                  userPhone: phone,
                ),
              );
            },
            buttonColor: Colors.blue,
            width: Responsive.s(120),
          ),
        ],
      ),
    );
  }
}
