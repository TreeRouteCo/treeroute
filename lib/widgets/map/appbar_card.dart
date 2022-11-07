import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../common/logo.dart';

class AppBarCard extends ConsumerWidget {
  const AppBarCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(15),
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              BrandIcon(width: 30),
              SizedBox(width: 10),
              Text("TreeRoute", style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
