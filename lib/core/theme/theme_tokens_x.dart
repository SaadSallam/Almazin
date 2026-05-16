import 'package:flutter/material.dart';

import 'almazin_theme_tokens.dart';

extension AlmazinThemeTokensX on BuildContext {
  AlmazinThemeTokens get almazinTokens {
    final tokens = Theme.of(this).extension<AlmazinThemeTokens>();
    assert(tokens != null, 'AlmazinThemeTokens missing from ThemeData.extensions');
    return tokens!;
  }
}
