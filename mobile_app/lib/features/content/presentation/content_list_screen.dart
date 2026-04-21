import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'content_bloc.dart';
import 'content_state.dart';
import '../domain/content_model.dart';
import '../../mock_tests/presentation/mock_test_screen.dart';
import '../../mock_tests/presentation/mock_test_bloc.dart';
import '../../../core/widgets/shimmer_loading.dart';
import 'content_viewer_screen.dart';
import '../../../core/widgets/custom_search.dart';
import '../../../core/widgets/pagination_control.dart';
import '../../../core/widgets/helper/responsive.dart';
import '../../../core/network/api_response.dart';
import '../../../core/widgets/custom_text_button.dart';

class ContentListScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const ContentListScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends State<ContentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  PaginationModel _pagination = PaginationModel.empty();

  static const _tabTypes = ['PDF', 'VIDEO', 'MOCK_TEST', 'NOTE'];
  static const _tabLabels = ['PDFs', 'Videos', 'Mock Tests', 'Notes'];
  static const _tabIcons = [
    Icons.picture_as_pdf_rounded,
    Icons.play_circle_fill_rounded,
    Icons.quiz_rounded,
    Icons.article_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTypes.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchContents();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    // Reset pagination for new tab
    _pagination = PaginationModel.empty();
    _fetchContents();
  }

  void _fetchContents() {
    context.read<ContentBloc>().add(
      FetchContentsRequested(
        widget.moduleId,
        pagination: _pagination.copyWith(
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          filter: [
            {'contentType': _tabTypes[_tabController.index]},
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    // Clear singleton app-level bloc data so it doesn't flash when re-opening
    context.read<ContentBloc>().add(ResetContentRequested());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelStyle: TextStyle(
            fontSize: Responsive.s(12),
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(fontSize: Responsive.s(12)),
          tabs: List.generate(_tabTypes.length, (i) {
            return Tab(
              icon: Icon(_tabIcons[i], size: Responsive.s(20)),
              text: _tabLabels[i],
            );
          }),
        ),
      ),
      body: BlocListener<ContentBloc, ContentState>(
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
        child: BlocBuilder<ContentBloc, ContentState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(Responsive.s(16)),
                  child: CustomSearchBar(
                    hintText:
                        'Search in ${_tabLabels[_tabController.index]}...',
                    onSearch: (val) {
                      _searchQuery = val;
                      _pagination = PaginationModel.empty();
                      _fetchContents();
                    },
                  ),
                ),
                Expanded(
                  child: _buildContentArea(state),
                ),
                if (state.pagination != null && state.pagination!.totalSize > 1)
                  PaginationControls(
                    currentPage: state.pagination!.page,
                    totalPages: state.pagination!.pageSize,
                    totalItems: state.pagination!.totalSize,
                    onNextPage: () {
                      _pagination = _pagination.copyWith(
                        page: state.pagination!.page + 1,
                      );
                      _fetchContents();
                    },
                    onPrevPage: () {
                      _pagination = _pagination.copyWith(
                        page: state.pagination!.page - 1,
                      );
                      _fetchContents();
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Unified content area that shows shimmer loading, error, 
  /// or the current tab's content.
  Widget _buildContentArea(ContentState state) {
    if (state.isLoading) {
      return _buildShimmer();
    }
    if (state.errorMessage != null && state.contents.isEmpty) {
      return _buildError(state.errorMessage!);
    }
    if (state.contents.isEmpty) {
      return _EmptyState(
        icon: _tabIcons[_tabController.index],
        label: 'No ${_tabLabels[_tabController.index].toLowerCase()} available yet',
      );
    }

    // Show content for current tab type
    final currentType = _tabTypes[_tabController.index];
    if (currentType == 'MOCK_TEST') {
      return _MockTestTab(
        items: state.contents,
        moduleId: widget.moduleId,
      );
    }
    return _ContentTab(
      items: state.contents,
      type: currentType,
      moduleId: widget.moduleId,
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: ShimmerLoading.rectangular(height: 72),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _fetchContents,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Generic Content Tab (PDFs, Videos, Notes) ─────────────────────────────────

class _ContentTab extends StatelessWidget {
  final List<ContentModel> items;
  final String type;
  final String moduleId;

  const _ContentTab({
    required this.items,
    required this.type,
    required this.moduleId,
  });

  IconData get _icon {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf_rounded;
      case 'VIDEO':
        return Icons.play_circle_fill_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  Color get _iconColor {
    switch (type) {
      case 'PDF':
        return Colors.red;
      case 'VIDEO':
        return Colors.blue;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(Responsive.s(16)),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: Responsive.s(8)),
      itemBuilder: (context, index) {
        final content = items[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.s(12)),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.s(16),
              vertical: Responsive.s(6),
            ),
            leading: Container(
              width: Responsive.s(40),
              height: Responsive.s(40),
              decoration: BoxDecoration(
                color: _iconColor.withAlpha(25),
                borderRadius: BorderRadius.circular(Responsive.s(10)),
              ),
              child: Icon(_icon, color: _iconColor, size: Responsive.s(22)),
            ),
            title: Text(
              content.title,
              style: TextStyle(
                fontSize: Responsive.s(14),
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              size: Responsive.s(20),
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ContentViewerScreen(
                    contentId: content.id,
                    contentTitle: content.title,
                    contentUrl: content.contentUrl,
                    contentType: content.contentType,
                    s3Key: content.s3Key,
                    metadata: content.metadata,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Mock Test Tab ─────────────────────────────────────────────────────────────

class _MockTestTab extends StatelessWidget {
  final List<ContentModel> items;
  final String moduleId;

  const _MockTestTab({required this.items, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(Responsive.s(16)),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: Responsive.s(10)),
      itemBuilder: (context, index) {
        final content = items[index];
        return _MockTestCard(
          content: content,
          onStart: () => _openMockTest(context, content),
        );
      },
    );
  }

  void _openMockTest(BuildContext context, ContentModel content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MockTestBloc>(),
          child: Scaffold(
            appBar: AppBar(
              title: Text(content.title),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            body: MockTestScreen(
              contentId: content.id,
              contentTitle: content.title,
            ),
          ),
        ),
      ),
    );
  }
}

class _MockTestCard extends StatelessWidget {
  final ContentModel content;
  final VoidCallback onStart;

  const _MockTestCard({required this.content, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.s(14)),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(Responsive.s(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: Responsive.s(42),
                  height: Responsive.s(42),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withAlpha(25),
                    borderRadius: BorderRadius.circular(Responsive.s(10)),
                  ),
                  child: Icon(
                    Icons.quiz_rounded,
                    color: Colors.deepPurple,
                    size: Responsive.s(22),
                  ),
                ),
                SizedBox(width: Responsive.s(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.title,
                        style: TextStyle(
                          fontSize: Responsive.s(15),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: Responsive.s(2)),
                      Text(
                        'Tap to start the test',
                        style: TextStyle(
                          fontSize: Responsive.s(12),
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.s(14)),
            CustomTextButton(
              text: 'Start Test',
              onPressed: onStart,
              icon: Icons.play_arrow_rounded,
              iconSize: Responsive.s(18),
              buttonColor: Colors.blue,
              height: Responsive.s(45),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmptyState({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: Responsive.s(56), color: Colors.grey[300]),
          SizedBox(height: Responsive.s(12)),
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.s(14),
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
