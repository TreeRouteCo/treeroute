import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/providers/providers.dart';

import 'login_sheet.dart';

class AccountSheet extends StatefulHookConsumerWidget {
  const AccountSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountSheetState();
}

class _AccountSheetState extends ConsumerState<AccountSheet> {
  @override
  Widget build(BuildContext context) {
    var authProv = ref.read(authProvider.notifier);
    var authState = ref.watch(authProvider);
    //var userProv = ref.read(userProvider.notifier);
    var userState = ref.watch(userProvider);

    if (authState.session == null) {
      return const LoginSheet();
    }

    // Add first and last name for full name

    var fullName = '${userState.profile?.firstName ?? ''} '
        '${userState.profile?.lastName ?? ''}';

    if (fullName.trim().isEmpty) {
      fullName = "No name set";
    }

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 10),
                Text(
                  'Account',
                  style: Theme.of(context).textTheme.headline5,
                ),
                Expanded(child: Container()),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.tertiary,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.account_circle_outlined,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 100,
                        ),
                      ),
                      if (userState.profile?.verified ?? false)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            child: Icon(
                              Icons.verified,
                              color: Theme.of(context).colorScheme.onSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                      // Mod Icon
                      if (userState.profile?.modCampuses != null)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            child: Icon(
                              Icons.shield_outlined,
                              color: Theme.of(context).colorScheme.onSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                      // Admin Icon
                      if (userState.profile?.admin ?? false)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            child: Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Theme.of(context).colorScheme.onSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        fullName,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userState.profile?.username ?? "No username set",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        authState.session!.user.email!,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                authProv.logOut();
                Navigator.pop(context);
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
