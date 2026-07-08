import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "services/chat_service.dart";
import "services/sirup_api_service.dart";
import "screens/home_screen.dart";

class LpseChatbotApp extends StatelessWidget {
  const LpseChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => SirupApiService()),
      ],
      child: MaterialApp(
        title: "LPSE Bulukumba",
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }

  static const _indigo = Color(0xFF4F46E5);
  static const _purple = Color(0xFF7C3AED);

  static ThemeData _baseTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: _indigo,
      brightness: brightness,
      primary: isDark ? const Color(0xFF818CF8) : _indigo,
      secondary: isDark ? const Color(0xFF14B8A6) : const Color(0xFF0D9488),
      tertiary: isDark ? const Color(0xFFA78BFA) : _purple,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: _textTheme(isDark, scheme),
      appBarTheme: AppBarTheme(
        centerTitle: false, elevation: 0, scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 2, indicatorColor: scheme.primaryContainer,
        backgroundColor: scheme.surface,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: scheme.primary);
          }
          return TextStyle(fontSize: 12, color: scheme.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(size: 22, color: scheme.primary);
          }
          return IconThemeData(size: 22, color: scheme.onSurfaceVariant);
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        hintStyle: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: scheme.primary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  static TextTheme _textTheme(bool isDark, ColorScheme scheme) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: scheme.onSurface),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: scheme.onSurface),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: scheme.onSurface),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: scheme.onSurface),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: scheme.onSurface),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: scheme.onSurface),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: scheme.onSurface),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: scheme.onSurface),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: scheme.onSurfaceVariant),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: scheme.onSurface),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant),
    );
  }

  ThemeData _buildLightTheme() => _baseTheme(Brightness.light);
  ThemeData _buildDarkTheme() => _baseTheme(Brightness.dark);
}
