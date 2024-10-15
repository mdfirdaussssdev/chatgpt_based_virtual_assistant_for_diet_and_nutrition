import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showPasswordresetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
      context: context,
      title: 'Password Reset',
      content:
          'We have now sent you a password reset link. Please check email for more information.',
      optionsBuilder: () => {
            'OK': null,
          });
}
