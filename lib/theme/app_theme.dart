
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
// Cores lilás e branco
static const Color primary = Color(0xFF9B8AE8);
static const Color secondary = Color(0xFFC8BDF5);
static const Color background = Color(0xFFF8F6FF);
static const Color surface = Color(0xFFFFFFFF);
static const Color textPrimary = Color(0xFF30264A);
static const Color textSecondary = Color(0xFF817694);
static const Color success = Color(0xFF6EAA8A);
static const Color warning = Color(0xFFE6B866);
static const Color danger = Color(0xFFD97991);
static const Color border = Color(0xFFE7E0F5);
static const Color accent = Color(0xFFB3A2F0);

// Cores das categorias
static const Color exam = Color(0xFF9B8AE8);
static const Color task = Color(0xFFB3A2F0);
static const Color goal = Color(0xFF8174C9);

static ThemeData get lightTheme {
return ThemeData(
useMaterial3: true,
colorScheme: ColorScheme.fromSeed(
seedColor: primary,
primary: primary,
secondary: secondary,
surface: surface,
error: danger,
),
scaffoldBackgroundColor: background,
textTheme: GoogleFonts.interTextTheme().copyWith(
headlineLarge: GoogleFonts.inter(
fontSize: 28,
fontWeight: FontWeight.bold,
color: textPrimary,
),
headlineMedium: GoogleFonts.inter(
fontSize: 22,
fontWeight: FontWeight.w600,
color: textPrimary,
),
titleLarge: GoogleFonts.inter(
fontSize: 18,
fontWeight: FontWeight.w600,
color: textPrimary,
),
titleMedium: GoogleFonts.inter(
fontSize: 16,
fontWeight: FontWeight.w600,
color: textPrimary,
),
bodyLarge: GoogleFonts.inter(
fontSize: 16,
color: textPrimary,
),
bodyMedium: GoogleFonts.inter(
fontSize: 14,
color: textSecondary,
),
bodySmall: GoogleFonts.inter(
fontSize: 12,
color: textSecondary,
),
),
appBarTheme: AppBarTheme(
backgroundColor: surface,
elevation: 0,
centerTitle: true,
iconTheme: const IconThemeData(color: primary),
titleTextStyle: GoogleFonts.inter(
fontSize: 18,
fontWeight: FontWeight.w600,
color: textPrimary,
),
),
elevatedButtonTheme: ElevatedButtonThemeData(
style: ElevatedButton.styleFrom(
backgroundColor: primary,
foregroundColor: Colors.white,
elevation: 0,
padding: const EdgeInsets.symmetric(
horizontal: 24,
vertical: 14,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
textStyle: GoogleFonts.inter(
fontSize: 16,
fontWeight: FontWeight.w600,
),
),
),
outlinedButtonTheme: OutlinedButtonThemeData(
style: OutlinedButton.styleFrom(
foregroundColor: primary,
side: const BorderSide(color: primary),
padding: const EdgeInsets.symmetric(
horizontal: 24,
vertical: 14,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
),
inputDecorationTheme: InputDecorationTheme(
filled: true,
fillColor: surface,
contentPadding: const EdgeInsets.symmetric(
horizontal: 16,
vertical: 14,
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(color: border),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(color: border),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(
color: primary,
width: 2,
),
),
errorBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(color: danger),
),
labelStyle: GoogleFonts.inter(color: textSecondary),
hintStyle: GoogleFonts.inter(color: textSecondary),
),
cardTheme: CardThemeData(
color: surface,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
side: const BorderSide(color: border),
),
),
floatingActionButtonTheme:
const FloatingActionButtonThemeData(
backgroundColor: primary,
foregroundColor: Colors.white,
elevation: 2,
),
bottomNavigationBarTheme:
const BottomNavigationBarThemeData(
backgroundColor: surface,
selectedItemColor: primary,
unselectedItemColor: textSecondary,
type: BottomNavigationBarType.fixed,
elevation: 8,
),
checkboxTheme: CheckboxThemeData(
fillColor: WidgetStateProperty.resolveWith((states) {
if (states.contains(WidgetState.selected)) {
return primary;
}
return Colors.transparent;
}),
side: const BorderSide(color: secondary),
),
switchTheme: SwitchThemeData(
thumbColor: WidgetStateProperty.resolveWith((states) {
if (states.contains(WidgetState.selected)) {
return Colors.white;
}
return textSecondary;
}),
trackColor: WidgetStateProperty.resolveWith((states) {
if (states.contains(WidgetState.selected)) {
return primary;
}
return border;
}),
),
dividerTheme: const DividerThemeData(
color: border,
thickness: 1,
),
);
}
}