import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:treeroute/widgets/common/snackbar.dart';

import '../../providers/providers.dart';
import '../account/account_sheet.dart';

class UserCircle extends StatefulHookConsumerWidget {
  const UserCircle({super.key});

  @override
  ConsumerState<UserCircle> createState() => _UserCircleState();
}

class _UserCircleState extends ConsumerState<UserCircle> {
  var loggedIn = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userState = ref.watch(userProvider);

    if (userState.profile != null && !loggedIn) {
      /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        progressSnackbar(
          context,
          "Welcome back, "
          "${userState.profile?.firstName ?? authState.session?.user.email}",
          const Icon(
            Icons.face_rounded,
            color: Colors.white,
          ),
        );
      });
      loggedIn = true;*/
    } else if (userState.profile == null &&
        !userState.loading &&
        userState.user != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Beamer.of(context).beamToNamed('/edit-profile/${userState.user?.id}');
      });
    } else if (authState.session == null && loggedIn) {
      loggedIn = false;
    }

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
          if (userState.loading) {
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
