import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/widgets/helper/responsive.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? buttonColor;
  final Gradient? gradient;
  final bool isRounded;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final bool isLoading;

  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final bool isIconOnly;
  final bool isLiquidGlass;

  const CustomTextButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.buttonColor,
    this.gradient,
    this.isRounded = false,
    this.width,
    this.height,
    this.textStyle,
    this.isLoading = false,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.isIconOnly = false,
    this.isLiquidGlass = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      isRounded
          ? Responsive.getContainerSize(50)
          : Responsive.getContainerSize(8),
    );

    Widget _buildButtonContent() {
      if (isLoading) {
        return SizedBox(
          height: Responsive.getContainerSize(24),
          width: Responsive.getContainerSize(24),
          child: const CircularProgressIndicator(
            color: AppColors.background,
            strokeWidth: 2.0,
          ),
        );
      }

      if (isIconOnly && icon != null) {
        return Icon(
          icon,
          color: iconColor ?? AppColors.background,
          size: iconSize ?? Responsive.s(20),
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? AppColors.background,
              size: iconSize ?? Responsive.s(18),
            ),
            SizedBox(width: Responsive.s(6)),
          ],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style:
                    (textStyle ??
                    TextStyle(
                      fontSize: Responsive.s(15),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
                textAlign: TextAlign.left,
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ),
        ],
      );
    }

    final buttonChild = _buildButtonContent();
    // 🍎 Liquid Glass Button (Apple-style)
    if (isLiquidGlass) {
      return SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: borderRadius,
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                  width: 1,
                ),
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getContainerSize(16),
                    vertical: Responsive.getContainerSize(8),
                  ),
                ),
                child: buttonChild,
              ),
            ),
          ),
        ),
      );
    }

    // 🔹 Gradient version
    if (gradient != null) {
      return SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: gradient!,
            borderRadius: borderRadius,
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getContainerSize(16),
                vertical: Responsive.getContainerSize(8),
              ),
            ),
            child: buttonChild,
          ),
        ),
      );
    }

    // 🔹 Default solid color (no gradient)
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? Colors.blue,
          foregroundColor: AppColors.background,
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getContainerSize(16),
            vertical: Responsive.getContainerSize(8),
          ),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: buttonChild,
      ),
    );
  }
}
