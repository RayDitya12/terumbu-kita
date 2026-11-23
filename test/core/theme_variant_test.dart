import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/theme/app_colors.dart';
import 'package:terumbu_kita/core/theme/app_theme.dart';

void main() {
  test('varian A memakai latar Foam dan kartu putih hangat', () {
    final theme = AppTheme.forVariant(TerumbuThemeVariant.a);
    expect(theme.scaffoldBackgroundColor, AppColors.foam);
    expect(theme.cardTheme.color, AppColors.warmWhite);
  });

  test('varian B memakai latar Deep Ocean dan kartu gelap', () {
    final theme = AppTheme.forVariant(TerumbuThemeVariant.b);
    expect(theme.scaffoldBackgroundColor, AppColors.deepOcean);
    expect(theme.cardTheme.color, AppColors.darkCard);
  });

  test('konstanta varian tema default adalah A', () {
    expect(kTerumbuThemeVariant, TerumbuThemeVariant.a);
  });
}
