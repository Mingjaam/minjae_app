import 'package:flutter/material.dart';

class AppStyles {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Pretendard',
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: const IconThemeData(size: 15),
        unselectedIconTheme: const IconThemeData(size: 15),
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: 'Pretendard',
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: const IconThemeData(size: 20),
        unselectedIconTheme: const IconThemeData(size: 20),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // 앱바 스타일
  static const double appBarElevation = 1.0;

  // 캘린더 탭 스타일
  static const TextStyle calendarDayTextStyle = TextStyle(fontSize: 12);
  static const TextStyle calendarSelectedDayTextStyle = TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold);
  static const TextStyle calendarTodayTextStyle = TextStyle(fontSize: 12, color: Colors.blue);
  static const EdgeInsets calendarCellPadding = EdgeInsets.all(4);
  static const double calendarDotSize = 10.0;
  static const double calendarDotSpacing = 2.0;

  // 친구 탭 스타일
  static const TextStyle friendNameStyle = TextStyle(fontSize: 10);
  static const double friendAvatarSize = 50.0;
  static const EdgeInsets friendItemPadding = EdgeInsets.all(10);
  static const double friendGridSpacing = 10.0;
  static const double friendGridChildAspectRatio = 0.75;

  // 설정 탭 스타일
  static const TextStyle settingsTitleStyle = TextStyle(fontSize: 18);

  // 공통 스타일
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const double defaultBorderRadius = 4.0;
}

