import 'package:flutter/material.dart';

import '../../../../core/theme/theme_tokens_x.dart';

class EmployeeAvatar extends StatelessWidget {
  const EmployeeAvatar({
    super.key,
    required this.initials,
    this.size = 40,
  });

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tokens.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: tokens.onPrimary,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
