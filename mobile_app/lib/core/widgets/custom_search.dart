import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/widgets/helper/responsive.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final Function()? onClear;
  final TextEditingController? controller;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? hintColor;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final BoxShadow? boxShadow;
  final IconButton? suffixIcon;
  final TextStyle? hintStyle;

  final bool isNeedSubmit;

  const CustomSearchBar({
    Key? key,
    this.hintText = 'Search...',
    required this.onSearch,
    this.onClear,
    this.controller,
    this.backgroundColor = AppColors.background,
    this.iconColor = Colors.black54,
    this.textColor = Colors.black87,
    this.hintColor = Colors.black38,
    this.height,
    this.borderRadius,
    this.padding,
    this.contentPadding,
    this.boxShadow,
    this.suffixIcon,
    this.hintStyle,
    this.isNeedSubmit = false,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _showClearButton = _controller.text.isNotEmpty;
        });

        if (!widget.isNeedSubmit) {
          widget.onSearch(_controller.text);
        }
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _showClearButton = false;
    });
    if (widget.onClear != null) {
      widget.onClear!();
    } else if (!widget.isNeedSubmit) {
      widget.onSearch('');
    }
  }

  void _onSubmitPressed() {
    widget.onSearch(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final searchHeight = widget.height ?? Responsive.s(48);
    final radius = widget.borderRadius ?? Responsive.s(12);

    return Container(
      height: searchHeight,
      padding:
          widget.padding ?? EdgeInsets.symmetric(horizontal: Responsive.s(8.0)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(51)),
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: widget.boxShadow != null
            ? [widget.boxShadow!]
            : [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 2.0)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.s(8.0)),
            child: Icon(
              Icons.search,
              color: widget.iconColor,
              size: Responsive.s(20.0),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(
                color: widget.textColor,
                fontSize: Responsive.s(16.0),
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle:
                    widget.hintStyle ??
                    TextStyle(
                      color: widget.hintColor,
                      fontSize: Responsive.s(16.0),
                    ),
                border: InputBorder.none,
                contentPadding:
                    widget.contentPadding ??
                    EdgeInsets.symmetric(
                      vertical: Responsive.s(12),
                      horizontal: 1.0,
                    ),
              ),
              textAlignVertical: TextAlignVertical.center,
              onSubmitted: widget.isNeedSubmit
                  ? (_) => _onSubmitPressed()
                  : null,
            ),
          ),
          if (widget.suffixIcon != null) widget.suffixIcon!,
          if (_showClearButton)
            GestureDetector(
              onTap: _clearSearch,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.s(8.0)),
                child: Icon(
                  Icons.clear,
                  color: widget.iconColor,
                  size: Responsive.s(20.0),
                ),
              ),
            ),
          if (widget.isNeedSubmit && _controller.text.isNotEmpty)
            GestureDetector(
              onTap: _onSubmitPressed,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.s(12.0),
                  vertical: Responsive.s(8.0),
                ),
                margin: EdgeInsets.only(left: Responsive.s(4.0)),
                decoration: BoxDecoration(
                  color: widget.iconColor?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Responsive.s(8.0)),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: widget.iconColor,
                  size: Responsive.s(20.0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
