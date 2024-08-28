import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showLogOutDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Log out',
    content: 'Are you sure you want to log out',
    optionsBuilder: () => {
      'Log Out': true,
      'Cancel': false,
    },
  ).then(
    (value) => value ?? false,
  );
}
