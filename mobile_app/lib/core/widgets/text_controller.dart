import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/widgets/helper/responsive.dart';

class TextController extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool? obscureText;
  final String obscuringCharacter;
  final String hintText;
  final Widget? prefixIcon;
  final FormFieldValidator? validator;
  final IconButton? suffixIcon;
  final String? errorText;
  final String? labelText;
  final Color? backgroundColor;
  final FocusNode? focusNode;
  final ValueChanged<String?>? onChanged;
  final bool readOnly;

  const TextController({
    Key? key,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    required this.hintText,
    this.prefixIcon,
    this.validator,
    this.suffixIcon,
    this.errorText,
    this.labelText,
    this.backgroundColor,
    this.onChanged,
    this.focusNode,
    this.readOnly = false,
  }) : super(key: key);

  @override
  _TextControllerState createState() => _TextControllerState();
}

class _TextControllerState extends State<TextController> {
  bool isObscure = true;
  bool isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    isObscure = widget.obscureText ?? false;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Padding(
            padding: EdgeInsets.only(
              left: Responsive.getContainerSize(4),
              bottom: Responsive.getContainerSize(8),
            ),
            child: Text(
              widget.labelText!,
              style: TextStyle(
                fontSize: Responsive.getFontSize(14),
                fontWeight: FontWeight.w600,
                color: isFocused ? AppColors.primaryBlue : Colors.black87,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(
              Responsive.getContainerSize(12),
            ),
            border: Border.all(
              color: isFocused
                  ? Colors.blue
                  : (widget.errorText != null
                        ? Colors.red.shade400
                        : Colors.grey.shade300),
              width: isFocused ? Responsive.s(1.5) : Responsive.s(1.0),
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.background.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: isObscure,
            obscuringCharacter: widget.obscuringCharacter,
            validator: widget.validator,
            onChanged: widget.onChanged,
            focusNode: _focusNode,
            readOnly: widget.readOnly,
            style: TextStyle(
              color: Colors.black87,
              fontSize: Responsive.getFontSize(15),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: Responsive.getContainerSize(16),
                horizontal: Responsive.getContainerSize(20),
              ),
              isDense: true,
              constraints: BoxConstraints(
                maxHeight: Responsive.getContainerSize(100),
                maxWidth: Responsive.screenWidth,
              ),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: Responsive.getFontSize(14),
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade500,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: Responsive.getContainerSize(12),
                        right: Responsive.getContainerSize(8),
                      ),
                      child: widget.prefixIcon,
                    )
                  : null,
              prefixIconConstraints: BoxConstraints(
                minWidth: Responsive.getContainerSize(40),
                minHeight: Responsive.getContainerSize(40),
              ),
              suffixIcon: widget.obscureText == true
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          isObscure = !isObscure;
                        });
                      },
                      icon: Icon(
                        isObscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: Responsive.getContainerSize(20),
                        color: isFocused ? Colors.blue : Colors.grey.shade600,
                      ),
                      splashRadius: Responsive.getContainerSize(20),
                    )
                  : widget.suffixIcon,
              suffixIconConstraints: BoxConstraints(
                minWidth: Responsive.getContainerSize(40),
                minHeight: Responsive.getContainerSize(40),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(
              top: Responsive.getContainerSize(6),
              left: Responsive.getContainerSize(12),
            ),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: Responsive.getFontSize(12),
              ),
            ),
          ),
      ],
    );
  }
}
