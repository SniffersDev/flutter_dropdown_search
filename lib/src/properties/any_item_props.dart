import 'package:flutter/material.dart';

class AnyItemProps {
  ///show or hide "Any" item in single selection mode
  final bool showAnyItem;

  ///custom label for the "Any" item
  final String anyItemLabel;

  ///custom builder for the "Any" item
  final Widget Function(BuildContext context)? anyItemBuilder;

  const AnyItemProps({
    this.showAnyItem = false,
    this.anyItemLabel = 'Any',
    this.anyItemBuilder,
  });
}
