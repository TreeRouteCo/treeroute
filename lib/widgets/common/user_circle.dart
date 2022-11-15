import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/widgets/common/snackbar.dart';

import '../../providers/providers.dart';
import '../account/account_sheet.dart';

class UserCircle extends HookConsumerWidget {
  const UserCircle({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userState = ref.watch(userProvider);
    return CircleAvatar(
      radius: 25,
      backgroundColor: Theme.of(context).cardColor,
      child: IconButton(
        icon: authState.session == null
            ? const Icon(Icons.login)
            : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.account_circle_outlined,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 30,
                ),
              ),
        onPressed: () {
          // open bottom sheet
          if (userState.userAccount == null) {
            progressSnackbar(
              context,
              "Hold on to your hat, loading your info",
              null,
            );
            return;
          }
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            builder: (context) => const AccountSheet(),
          );
        },
      ),
    );
  }
}
