import 'package:flutter/material.dart';
import '../properties/menu_props.dart';

Future<T?> showCustomMenu<T>(
    {required BuildContext context,
    required MenuProps menuModeProps,
    required Size targetSize,
    required Widget child,
    required ValueNotifier<RelativeRect> positionNotifier}) {
  final NavigatorState navigator = Navigator.of(context);
  return navigator.push(
    _PopupMenuRoute<T>(
      context: context,
      child: child,
      targetSize: targetSize,
      positionNotifier: positionNotifier,
      menuModeProps: menuModeProps,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
    ),
  );
}

// Positioning of the menu on the screen.
class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  final RelativeRect position;
  final BuildContext context;
  final Size targetSize;

  /// Padding from the target area when the dropdown menu is positioned above it.
  final double topPadding = 20.0;

  _PopupMenuRouteLayout(
    this.context,
    this.position,
    this.targetSize,
  );

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final parentRenderBox = context.findRenderObject() as RenderBox;
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double safeAreaTop = MediaQuery.of(context).padding.top;
    double safeAreaBottom = MediaQuery.of(context).padding.bottom;
    double totalSafeArea = safeAreaTop + safeAreaBottom;

    double availableHeightBelow = constraints.maxHeight - position.top - keyboardHeight - totalSafeArea;
    double availableHeightAbove = position.top - safeAreaTop - targetSize.height - topPadding;

    // Determine the maximum height available for the popup based on space above or below
    double maxHeight = availableHeightBelow >= availableHeightAbove ? availableHeightBelow : availableHeightAbove;

    // Ensure maxHeight does not go negative
    maxHeight = maxHeight > 0 ? maxHeight : constraints.maxHeight;

    return BoxConstraints.loose(
      Size(
        parentRenderBox.size.width - position.right - position.left,
        maxHeight,
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double availableHeightBelow = size.height - position.top - keyboardHeight;
    double availableHeightAbove = position.top;

    // Decide if we should show the popup above or below
    double y = availableHeightBelow >= childSize.height
        ? position.top
        : (availableHeightAbove >= childSize.height
            ? position.top - childSize.height - targetSize.height - topPadding
            : size.height - childSize.height - keyboardHeight - targetSize.height - topPadding);

    double x = position.left;
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return true;
  }
}

class _PopupMenuRoute<T> extends PopupRoute<T> {
  final MenuProps menuModeProps;
  final BuildContext context;
  final Widget child;
  final Size targetSize;
  final CapturedThemes capturedThemes;
  final ValueNotifier<RelativeRect> positionNotifier;

  _PopupMenuRoute(
      {required this.context,
      required this.menuModeProps,
      required this.capturedThemes,
      required this.targetSize,
      required this.child,
      required this.positionNotifier});

  @override
  Duration get transitionDuration => menuModeProps.animationDuration;

  @override
  bool get barrierDismissible => menuModeProps.barrierDismissible;

  @override
  Color? get barrierColor => menuModeProps.barrierColor;

  @override
  String? get barrierLabel => menuModeProps.barrierLabel;

  @override
  Animation<double>? get animation => menuModeProps.animation ?? super.animation;

  @override
  Curve get barrierCurve => menuModeProps.barrierCurve ?? super.barrierCurve;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final menu = Material(
      shape: menuModeProps.shape ?? popupMenuTheme.shape,
      color: menuModeProps.backgroundColor ?? popupMenuTheme.color,
      type: MaterialType.card,
      elevation: menuModeProps.elevation ?? popupMenuTheme.elevation ?? 8.0,
      clipBehavior: menuModeProps.clipBehavior,
      borderRadius: menuModeProps.borderRadius,
      animationDuration: menuModeProps.animationDuration,
      shadowColor: menuModeProps.shadowColor,
      borderOnForeground: menuModeProps.borderOnForeground,
      child: child,
    );

    return ValueListenableBuilder<RelativeRect>(
      valueListenable: positionNotifier,
      builder: (context, position, _) {
        return CustomSingleChildLayout(
          delegate: _PopupMenuRouteLayout(context, position, targetSize),
          child: capturedThemes.wrap(menu),
        );
      },
    );
  }
}
