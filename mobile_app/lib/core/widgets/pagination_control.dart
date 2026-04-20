import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/widgets/helper/responsive.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final VoidCallback onNextPage;
  final VoidCallback onPrevPage;
  final TextStyle? textStyle;
  final double? iconSize;
  final bool? isNeedDecoration;
  final double? paddingVertical;
  final double? paddingHorizontal;
  final bool? isNeedToShowTotelText;
  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.totalPages,
    required this.onNextPage,
    required this.onPrevPage,
    this.textStyle,
    this.iconSize,
    this.isNeedDecoration = true,
    this.paddingVertical,
    this.paddingHorizontal,
    this.isNeedToShowTotelText = false,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages == 0) {
      return const SizedBox.shrink(); // No pagination if there are no pages
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: Responsive.getContainerSize(18)),
      decoration: isNeedDecoration == true
          ? BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: Responsive.getContainerSize(
                iconSize != null ? iconSize! : 18,
              ),
            ),
            onPressed: currentPage != 1 ? onPrevPage : null,
            color: currentPage > 1 ? Colors.blue : Colors.grey,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.getContainerSize(
                paddingHorizontal != null ? paddingHorizontal! : 16,
              ),
              vertical: Responsive.getContainerSize(
                paddingVertical != null ? paddingVertical! : 8,
              ),
            ),
            child: Text(
              isNeedToShowTotelText == true
                  ? 'Page $currentPage of $totalPages ($totalItems)'
                  : 'Page $currentPage of $totalPages ($totalItems)',
              style: textStyle != null
                  ? textStyle
                  : TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              size: Responsive.getContainerSize(
                iconSize != null ? iconSize! : 18,
              ),
            ),
            onPressed: currentPage != totalPages ? onNextPage : null,
            color: currentPage < totalPages ? Colors.blue : Colors.grey,
          ),
        ],
      ),
    );
  }
}
