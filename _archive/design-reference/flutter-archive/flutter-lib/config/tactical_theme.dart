/// Tactical Theme Configuration for OneMind OS v2
/// Based on the original OneMind OS design system
/// Supports both dark (tactical) and light (professional) themes
library;

import 'package:flutter/material.dart';

/// Theme mode enum
enum AppThemeMode {
  light,
  dark,
  solarpunk,
}

/// Core color system - Dark Theme (Tactical)
class TacticalColorsDark {
  // Backgrounds
  static const Color background = Color(0xFF000000); // Pure black
  static const Color surface = Color(0xFF0A0A0A); // Elevated surface
  static const Color card = Color(0xFF111111); // Card backgrounds
  static const Color elevated = Color(0xFF1A1A1A); // Modals, dropdowns
  static const Color input = Color(0xFF0D0D0D); // Input fields

  // Primary Accent (Red - Zeus signature)
  static const Color primary = Color(0xFFE63946); // Main accent
  static const Color primaryDim = Color(0xFFB82D3A); // Pressed state
  static const Color primaryGlow = Color(0xFFFF4D5A); // Hover/focus effect
  static const Color primaryMuted = Color(0x26E63946); // 15% opacity
  static const Color critical = Color(0xFFFF6B6B); // Important actions

  // Secondary Accent (Cyan - Legacy from v2)
  static const Color cyan = Color(0xFF00D9FF); // Cyan accent
  static const Color cyanDim = Color(0xFF00A8CC); // Dim cyan
  static const Color cyanGlow = Color(0xFF33E0FF); // Bright cyan

  // Status Colors
  static const Color success = Color(0xFF22C55E); // Green - operational
  static const Color warning = Color(0xFFF59E0B); // Amber - maintenance
  static const Color error = Color(0xFFEF4444); // Red - critical
  static const Color info = Color(0xFF3B82F6); // Blue - information
  static const Color inactive = Color(0xFF4B5563); // Gray - disabled

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // Bright white
  static const Color textSecondary = Color(0xFFD1D5DB); // Labels
  static const Color textMuted = Color(0xFF9CA3AF); // Hints
  static const Color textDim = Color(0xFF6B7280); // Subtle hints
  static const Color textDisabled = Color(0xFF4B5563); // Disabled text

  // Border & Divider Colors
  static const Color border = Color(0xFF1F2937); // Standard border
  static const Color borderBright = Color(0xFF374151); // Brighter border
  static const Color divider = Color(0xFF1F2937); // Dividers

  // Agent Category Colors
  static const Color categoryCode = Color(0xFF3B82F6); // Blue
  static const Color categoryResearch = Color(0xFF8B5CF6); // Purple
  static const Color categoryCreative = Color(0xFFEC4899); // Pink
  static const Color categoryProductivity = Color(0xFF10B981); // Green
  static const Color categoryIoT = Color(0xFF06B6D4); // Cyan
}

/// Core color system - Light Theme (Professional)
class TacticalColorsLight {
  // Backgrounds
  static const Color background = Color(0xFFF8F9FA); // Light gray background
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color card = Color(0xFFFFFFFF); // White cards
  static const Color elevated = Color(0xFFFAFAFA); // Slightly off-white
  static const Color input = Color(0xFFFFFFFF); // White input fields

  // Primary Accent (Softer red for light mode)
  static const Color primary = Color(0xFFDC3545); // Softer red
  static const Color primaryDim = Color(0xFFB02A37); // Pressed state
  static const Color primaryGlow = Color(0xFFE85463); // Hover/focus effect
  static const Color primaryMuted = Color(0x1ADC3545); // 10% opacity
  static const Color critical = Color(0xFFE74C3C); // Important actions

  // Secondary Accent (Cyan)
  static const Color cyan = Color(0xFF0891B2); // Darker cyan for contrast
  static const Color cyanDim = Color(0xFF06748C); // Dim cyan
  static const Color cyanGlow = Color(0xFF0EA5E9); // Bright cyan

  // Status Colors
  static const Color success = Color(0xFF16A34A); // Green - operational
  static const Color warning = Color(0xFFEA580C); // Orange - maintenance
  static const Color error = Color(0xFFDC2626); // Red - critical
  static const Color info = Color(0xFF2563EB); // Blue - information
  static const Color inactive = Color(0xFF94A3B8); // Gray - disabled

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Almost black
  static const Color textSecondary = Color(0xFF4B5563); // Dark gray
  static const Color textMuted = Color(0xFF6B7280); // Medium gray
  static const Color textDim = Color(0xFF9CA3AF); // Light gray
  static const Color textDisabled = Color(0xFFD1D5DB); // Very light gray

  // Border & Divider Colors
  static const Color border = Color(0xFFE5E7EB); // Light border
  static const Color borderBright = Color(0xFFD1D5DB); // Slightly darker border
  static const Color divider = Color(0xFFE5E7EB); // Dividers

  // Agent Category Colors
  static const Color categoryCode = Color(0xFF2563EB); // Blue
  static const Color categoryResearch = Color(0xFF7C3AED); // Purple
  static const Color categoryCreative = Color(0xFFDB2777); // Pink
  static const Color categoryProductivity = Color(0xFF059669); // Green
  static const Color categoryIoT = Color(0xFF0891B2); // Cyan
}

/// Core color system - Solarpunk Theme (Tactical Solarpunk)
class TacticalColorsSolarpunk {
  // Backgrounds
  static const Color background = Color(0xFF0A1810); // Deep forest night
  static const Color surface = Color(0xFF122820); // Elevated moss surface
  static const Color card = Color(0xFF1A3328); // Rich forest floor
  static const Color elevated = Color(0xFF234030); // Highlighted natural elements
  static const Color input = Color(0xFF15281E); // Input fields with earthy depth

  // Primary Accent (Amber Energy)
  static const Color primary = Color(0xFFFFB703); // Warm amber/golden energy
  static const Color primaryDim = Color(0xFFD99000); // Pressed state
  static const Color primaryGlow = Color(0xFFFFC933); // Hover/focus effect
  static const Color primaryMuted = Color(0x26FFB703); // 15% opacity
  static const Color critical = Color(0xFFFF9500); // Important actions

  // Secondary Accent (Living Green)
  static const Color moss = Color(0xFF52B788); // Life indicator
  static const Color mossDim = Color(0xFF2D6A4F); // Dimmed moss
  static const Color mossGlow = Color(0xFF74C69D); // Bright growth effect
  static const Color jade = Color(0xFF40916C); // Alternative green accent

  // Status Colors
  static const Color success = Color(0xFF52B788); // Healthy growth green
  static const Color warning = Color(0xFFF4A460); // Sandy/desert warning
  static const Color error = Color(0xFFE07A5F); // Terracotta alert
  static const Color info = Color(0xFF81B29A); // Sage information
  static const Color inactive = Color(0xFF5C6F64); // Stone gray

  // Text Colors
  static const Color textPrimary = Color(0xFFF0F4F0); // Soft white with green tint
  static const Color textSecondary = Color(0xFFC8D5C8); // Light sage
  static const Color textMuted = Color(0xFF9AAF9A); // Muted moss
  static const Color textDim = Color(0xFF6B7F6B); // Dim forest
  static const Color textDisabled = Color(0xFF4A5F4A); // Disabled stone

  // Border & Divider Colors
  static const Color border = Color(0xFF2D4438); // Subtle natural border
  static const Color borderBright = Color(0xFF3A5544); // Brighter organic edge
  static const Color divider = Color(0xFF2D4438); // Natural separation

  // Agent Category Colors
  static const Color categoryCode = Color(0xFF6A8CAF); // Stone blue
  static const Color categoryResearch = Color(0xFF9A7BB0); // Lavender sage
  static const Color categoryCreative = Color(0xFFD98A8A); // Rose clay
  static const Color categoryProductivity = Color(0xFF52B788); // Living moss
  static const Color categoryIoT = Color(0xFF81B29A); // Jade tech
}

/// Active color system based on current theme
class TacticalColors {
  static AppThemeMode _currentTheme = AppThemeMode.light;

  static void setTheme(AppThemeMode mode) {
    _currentTheme = mode;
  }

  static AppThemeMode get currentTheme => _currentTheme;

  // Backgrounds
  static Color get background {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.background;
      case AppThemeMode.light:
        return TacticalColorsLight.background;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.background;
    }
  }

  static Color get surface {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.surface;
      case AppThemeMode.light:
        return TacticalColorsLight.surface;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.surface;
    }
  }

  static Color get card {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.card;
      case AppThemeMode.light:
        return TacticalColorsLight.card;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.card;
    }
  }

  static Color get elevated {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.elevated;
      case AppThemeMode.light:
        return TacticalColorsLight.elevated;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.elevated;
    }
  }

  static Color get input {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.input;
      case AppThemeMode.light:
        return TacticalColorsLight.input;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.input;
    }
  }

  // Primary Accent
  static Color get primary {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.primary;
      case AppThemeMode.light:
        return TacticalColorsLight.primary;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.primary;
    }
  }

  static Color get primaryDim {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.primaryDim;
      case AppThemeMode.light:
        return TacticalColorsLight.primaryDim;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.primaryDim;
    }
  }

  static Color get primaryGlow {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.primaryGlow;
      case AppThemeMode.light:
        return TacticalColorsLight.primaryGlow;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.primaryGlow;
    }
  }

  static Color get primaryMuted {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.primaryMuted;
      case AppThemeMode.light:
        return TacticalColorsLight.primaryMuted;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.primaryMuted;
    }
  }

  static Color get critical {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.critical;
      case AppThemeMode.light:
        return TacticalColorsLight.critical;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.critical;
    }
  }

  // Secondary Accent
  static Color get cyan {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.cyan;
      case AppThemeMode.light:
        return TacticalColorsLight.cyan;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.moss; // Maps to moss for solarpunk
    }
  }

  static Color get cyanDim {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.cyanDim;
      case AppThemeMode.light:
        return TacticalColorsLight.cyanDim;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.mossDim; // Maps to mossDim for solarpunk
    }
  }

  static Color get cyanGlow {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.cyanGlow;
      case AppThemeMode.light:
        return TacticalColorsLight.cyanGlow;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.mossGlow; // Maps to mossGlow for solarpunk
    }
  }

  // Status Colors
  static Color get success {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.success;
      case AppThemeMode.light:
        return TacticalColorsLight.success;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.success;
    }
  }

  static Color get warning {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.warning;
      case AppThemeMode.light:
        return TacticalColorsLight.warning;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.warning;
    }
  }

  static Color get error {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.error;
      case AppThemeMode.light:
        return TacticalColorsLight.error;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.error;
    }
  }

  static Color get info {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.info;
      case AppThemeMode.light:
        return TacticalColorsLight.info;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.info;
    }
  }

  static Color get inactive {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.inactive;
      case AppThemeMode.light:
        return TacticalColorsLight.inactive;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.inactive;
    }
  }

  // Text Colors
  static Color get textPrimary {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.textPrimary;
      case AppThemeMode.light:
        return TacticalColorsLight.textPrimary;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.textPrimary;
    }
  }

  static Color get textSecondary {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.textSecondary;
      case AppThemeMode.light:
        return TacticalColorsLight.textSecondary;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.textSecondary;
    }
  }

  static Color get textMuted {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.textMuted;
      case AppThemeMode.light:
        return TacticalColorsLight.textMuted;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.textMuted;
    }
  }

  static Color get textDim {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.textDim;
      case AppThemeMode.light:
        return TacticalColorsLight.textDim;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.textDim;
    }
  }

  static Color get textDisabled {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.textDisabled;
      case AppThemeMode.light:
        return TacticalColorsLight.textDisabled;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.textDisabled;
    }
  }

  // Border & Divider Colors
  static Color get border {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.border;
      case AppThemeMode.light:
        return TacticalColorsLight.border;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.border;
    }
  }

  static Color get borderBright {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.borderBright;
      case AppThemeMode.light:
        return TacticalColorsLight.borderBright;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.borderBright;
    }
  }

  static Color get divider {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.divider;
      case AppThemeMode.light:
        return TacticalColorsLight.divider;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.divider;
    }
  }

  // Agent Category Colors
  static Color get categoryCode {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.categoryCode;
      case AppThemeMode.light:
        return TacticalColorsLight.categoryCode;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.categoryCode;
    }
  }

  static Color get categoryResearch {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.categoryResearch;
      case AppThemeMode.light:
        return TacticalColorsLight.categoryResearch;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.categoryResearch;
    }
  }

  static Color get categoryCreative {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.categoryCreative;
      case AppThemeMode.light:
        return TacticalColorsLight.categoryCreative;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.categoryCreative;
    }
  }

  static Color get categoryProductivity {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.categoryProductivity;
      case AppThemeMode.light:
        return TacticalColorsLight.categoryProductivity;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.categoryProductivity;
    }
  }

  static Color get categoryIoT {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return TacticalColorsDark.categoryIoT;
      case AppThemeMode.light:
        return TacticalColorsLight.categoryIoT;
      case AppThemeMode.solarpunk:
        return TacticalColorsSolarpunk.categoryIoT;
    }
  }

  static Color get accent => cyan;
}

/// Tactical decoration presets
class TacticalDecoration {
  /// Standard card decoration
  static BoxDecoration card({
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 1,
  }) {
    final radius = TacticalColors.currentTheme == AppThemeMode.solarpunk
        ? 16.0
        : 12.0;

    return BoxDecoration(
      color: backgroundColor ?? TacticalColors.card,
      border: Border.all(
        color: borderColor ?? TacticalColors.border,
        width: borderWidth,
      ),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Elevated card with subtle glow
  static BoxDecoration cardElevated({
    Color? backgroundColor,
    Color? glowColor,
  }) {
    final radius = TacticalColors.currentTheme == AppThemeMode.solarpunk
        ? 16.0
        : 12.0;

    final shadowColor = TacticalColors.currentTheme == AppThemeMode.solarpunk
        ? TacticalColorsSolarpunk.primary.withValues(alpha: 0.1)
        : (glowColor ?? TacticalColors.primary).withValues(alpha: 0.1);

    return BoxDecoration(
      color: backgroundColor ?? TacticalColors.elevated,
      border: Border.all(
        color: TacticalColors.borderBright,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Status dot/indicator
  static BoxDecoration statusDot(Color color) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.5),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ],
    );
  }

  /// Status badge
  static BoxDecoration statusBadge(Color color) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.15),
      border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      borderRadius: BorderRadius.circular(6),
    );
  }

  /// Primary button (filled)
  static BoxDecoration buttonPrimary({
    Color? backgroundColor,
    bool isHovered = false,
  }) {
    final bgColor = backgroundColor ?? TacticalColors.primary;
    final radius = TacticalColors.currentTheme == AppThemeMode.solarpunk
        ? 12.0
        : 8.0;

    return BoxDecoration(
      color: isHovered ? TacticalColors.primaryGlow : bgColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: isHovered
          ? [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ]
          : null,
    );
  }

  /// Outline button
  static BoxDecoration buttonOutline({
    Color? borderColor,
    bool isHovered = false,
  }) {
    // Use moss green for solarpunk, primary for others
    final bColor = borderColor ??
        (TacticalColors.currentTheme == AppThemeMode.solarpunk
            ? TacticalColorsSolarpunk.moss
            : TacticalColors.primary);

    final radius = TacticalColors.currentTheme == AppThemeMode.solarpunk
        ? 12.0
        : 8.0;

    return BoxDecoration(
      color: isHovered ? bColor.withValues(alpha: 0.1) : Colors.transparent,
      border: Border.all(
        color: bColor,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Input field decoration
  static InputDecoration inputField({
    String? label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final radius = TacticalColors.currentTheme == AppThemeMode.solarpunk
        ? 10.0
        : 8.0;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(
        color: TacticalColors.textMuted,
        fontFamily: 'monospace',
      ),
      hintStyle: TextStyle(
        color: TacticalColors.textDim,
        fontFamily: 'monospace',
      ),
      filled: true,
      fillColor: TacticalColors.input,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: TacticalColors.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: TacticalColors.primary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: TacticalColors.error,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: TacticalColors.error,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Tactical text styles (dynamic based on theme)
class TacticalText {
  /// Screen title (large, uppercase, monospace)
  static TextStyle get screenTitle => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: TacticalColors.textPrimary,
        fontFamily: 'monospace',
        letterSpacing: 2,
      );

  /// Section header (small, uppercase, semi-bold)
  static TextStyle get sectionHeader => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: TacticalColors.textSecondary,
        fontFamily: 'monospace',
        letterSpacing: 1.5,
      );

  /// Card title
  static TextStyle get cardTitle => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: TacticalColors.textPrimary,
      );

  /// Card subtitle
  static TextStyle get cardSubtitle => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: TacticalColors.textSecondary,
      );

  /// Status label
  static TextStyle get statusLabel => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: TacticalColors.textPrimary,
        fontFamily: 'monospace',
        letterSpacing: 0.5,
      );

  /// Button label (uppercase)
  static TextStyle get buttonLabel => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: TacticalColors.textPrimary,
        fontFamily: 'monospace',
        letterSpacing: 1,
      );

  /// Stat value (large numbers)
  static TextStyle get statValue => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: TacticalColors.textPrimary,
        fontFamily: 'monospace',
      );

  /// Stat label
  static TextStyle get statLabel => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: TacticalColors.textMuted,
        fontFamily: 'monospace',
        letterSpacing: 0.5,
      );

  /// Body text large
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: TacticalColors.textPrimary,
      );

  /// Body text medium
  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TacticalColors.textPrimary,
      );

  /// Body text small
  static TextStyle get bodySmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: TacticalColors.textSecondary,
      );

  /// Label text
  static TextStyle get label => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: TacticalColors.textMuted,
      );
}

/// Spacing and sizing system (4px base grid)
class TacticalSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// Border radius system
class TacticalRadius {
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double full = 9999;
}

/// Organic border radius system for Solarpunk theme
class TacticalRadiusOrganic {
  static const double xs = 6;   // Increased from 4
  static const double sm = 8;   // Increased from 6
  static const double md = 12;  // Increased from 8
  static const double lg = 16;  // Increased from 12
  static const double xl = 20;  // Increased from 16
  static const double full = 9999;

  /// Get appropriate radius based on current theme
  static double getCardRadius() {
    return TacticalColors.currentTheme == AppThemeMode.solarpunk
        ? lg  // 16px for organic feel
        : TacticalRadius.lg;  // 12px for tactical
  }

  static double getButtonRadius() {
    return TacticalColors.currentTheme == AppThemeMode.solarpunk
        ? md  // 12px for organic
        : TacticalRadius.md;  // 8px for tactical
  }

  static double getInputRadius() {
    return TacticalColors.currentTheme == AppThemeMode.solarpunk
        ? sm  // 8px for organic
        : TacticalRadius.md;  // 8px (same)
  }
}

/// Animation durations
class TacticalDuration {
  static const Duration instant = Duration(milliseconds: 50);
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 400);
}

/// Animation curves
class TacticalCurves {
  static const Curve standard = Curves.easeOutCubic;
  static const Curve smooth = Curves.fastOutSlowIn;
  static const Curve spring = Curves.elasticOut;
}

/// Animation helpers for Tactical themes
class TacticalAnimations {
  /// Create a breathing pulse animation controller
  /// Used for status indicators in solarpunk theme
  static AnimationController breathingPulse({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    )..repeat(reverse: true);
  }

  /// Create a breathing pulse animation for scale
  static Animation<double> breathingScale(AnimationController controller) {
    return Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  /// Create a breathing pulse animation for opacity
  static Animation<double> breathingOpacity(AnimationController controller) {
    return Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  /// Check if current theme uses breathing animations
  static bool shouldAnimate() {
    return TacticalColors.currentTheme == AppThemeMode.solarpunk;
  }
}
