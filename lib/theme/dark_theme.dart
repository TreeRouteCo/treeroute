import 'package:flutter/material.dart';

import 'page_transition.dart';

ThemeData darkTheme() {
  return ThemeData.dark().copyWith(
    primaryColor: const Color.fromARGB(255, 0, 211, 95),
    useMaterial3: true,
    pageTransitionsTheme: pageTransitionsTheme,
    toggleableActiveColor: const Color.fromARGB(255, 0, 211, 95),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 0, 211, 95),
      brightness: Brightness.dark,
    ),
    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(backgroundColor: Color(0xff00a1d3)),
    textTheme: const TextTheme(
      headline1: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Color(0xffffffff),
      ),
      bodyText2: TextStyle(
        fontSize: 14,
        color: Color(0xffffffff),
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: const Color.fromARGB(255, 0, 211, 95),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(99999),
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color.fromARGB(255, 0, 211, 95),
    ),
    appBarTheme: AppBarTheme(
      color: ThemeData.dark().primaryColor,
      actionsIconTheme: const IconThemeData(
        color: Color.fromARGB(255, 0, 211, 95),
      ),
      iconTheme: const IconThemeData(
        color: Color.fromARGB(255, 0, 211, 95),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ThemeData.dark().primaryColor,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      color: const Color(0xff37383d),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          8,
        ),
      ),
    ),
    shadowColor: const Color(0xff494b52),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.resolveWith(
          (states) => RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) => const Color.fromARGB(255, 0, 211, 95),
        ),
        shadowColor: MaterialStateProperty.resolveWith(
          (states) => const Color(0xff494b52),
        ),
      ),
    ),
    backgroundColor: const Color(0xff494b52),
  );
}
