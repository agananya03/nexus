import 'package:flutter/material.dart';
import 'app_toast.dart';

void showErrorSnackbar(BuildContext context, String message) {
  showAppToast(context, message, isError: true);
}
