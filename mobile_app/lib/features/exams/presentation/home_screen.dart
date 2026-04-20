import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'exam_bloc.dart';
import '../../ads/presentation/banner_ad_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/custom_search.dart';
import '../../../core/widgets/helper/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ExamBloc>().add(GetExamsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExamEase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: BlocListener<ExamBloc, ExamState>(
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
        child: BlocBuilder<ExamBloc, ExamState>(
          builder: (context, state) {
            final filteredExams = state.exams.where((exam) {
              return exam.title.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
            }).toList();

            if (state.isLoading && state.exams.isEmpty) {
              return GridView.builder(
                padding: EdgeInsets.all(Responsive.s(16)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: Responsive.s(16),
                  mainAxisSpacing: Responsive.s(16),
                  childAspectRatio: 1.2,
                ),
                itemCount: 6,
                itemBuilder: (context, index) =>
                    const ShimmerLoading.rectangular(height: 120),
              );
            } else if (state.errorMessage != null && state.exams.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: Responsive.s(60),
                      color: Colors.red,
                    ),
                    SizedBox(height: Responsive.s(16)),
                    Text(
                      'Failed to load exams',
                      style: TextStyle(
                        fontSize: Responsive.s(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Responsive.s(8)),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ExamBloc>().add(GetExamsRequested()),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            } else {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(Responsive.s(16)),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomSearchBar(
                            hintText: 'Search exams...',
                            onSearch: (val) {
                              setState(() {
                                searchQuery = val;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: Responsive.s(8)),
                        IconButton(
                          onPressed: () =>
                              _showExamFilter(context, state.exams),
                          icon: const Icon(Icons.filter_list),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue.withValues(alpha: 0.1),
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
                  const BannerAdWidget(placement: 'BANNER_HOME'),
                  Expanded(
                    child: filteredExams.isEmpty
                        ? const Center(child: Text('No exams found'))
                        : GridView.builder(
                            padding: EdgeInsets.all(Responsive.s(16)),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: Responsive.s(16),
                                  mainAxisSpacing: Responsive.s(16),
                                  childAspectRatio: 1.2,
                                ),
                            itemCount: filteredExams.length,
                            itemBuilder: (context, index) {
                              final exam = filteredExams[index];
                              return Hero(
                                tag: 'exam-${exam.id}',
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      Responsive.s(16),
                                    ),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                      Responsive.s(16),
                                    ),
                                    onTap: () {
                                      context.go(
                                        '/home/modules/${exam.id}?title=${Uri.encodeComponent(exam.title)}',
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        Responsive.s(16.0),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.school_outlined,
                                            size: Responsive.s(40),
                                            color: Colors.blue,
                                          ),
                                          SizedBox(height: Responsive.s(12)),
                                          Text(
                                            exam.title,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: Responsive.s(14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  void _showExamFilter(BuildContext context, List<dynamic> exams) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(Responsive.s(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Exam',
                style: TextStyle(
                  fontSize: Responsive.s(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Responsive.s(16)),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.description,
                        color: Colors.blue,
                      ),
                      title: Text(exam.title),
                      onTap: () {
                        Navigator.pop(context);
                        context.go(
                          '/home/modules/${exam.id}?title=${Uri.encodeComponent(exam.title)}',
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
