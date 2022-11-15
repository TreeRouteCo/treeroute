// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

void successSnackbar(BuildContext context, String text, Widget? icon) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      dismissDirection: DismissDirection.vertical,
      content: Row(
        children: [
          icon ??
              const Icon(
                Icons.check_rounded,
                color: Colors.white,
              ),
          const SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: const Color(0xff1BCA4C),
    ),
  );
}

void errorSnackbar(BuildContext context, String text, Widget? icon) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      dismissDirection: DismissDirection.horizontal,
      content: Row(
        children: [
          icon ??
              const Icon(
                Icons.error_rounded,
                color: Colors.white,
              ),
          const SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Theme.of(context).errorColor,
    ),
  );
}

void progressSnackbar(BuildContext context, String text, Widget? icon) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      dismissDirection: DismissDirection.horizontal,
      content: Row(
        children: [
          icon ??
              SizedBox(
                width: ((Theme.of(context).iconTheme.size ?? 24)),
                height: ((Theme.of(context).iconTheme.size ?? 24)),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
          const SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: const Color(0xff424242),
      duration: const Duration(seconds: 1),
    ),
  );
}

Future<void> doTaskOnSnackbar(BuildContext context, Function func) async {
  ScaffoldMessenger.of(context).clearSnackBars();
  progressSnackbar(context, "Loading...", null);
  try {
    await func();
    ScaffoldMessenger.of(context).clearSnackBars();
    successSnackbar(context, "Success!", null);
  } catch (e) {
    ScaffoldMessenger.of(context).clearSnackBars();
    errorSnackbar(context, e.toString(), null);
  }
}
