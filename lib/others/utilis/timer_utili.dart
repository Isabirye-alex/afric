import 'package:get/get.dart';
// This file contains a controller for managing a timer dialog in a Flutter application using GetX.
// It tracks when the dialog was opened and checks if the user is still within an allowed time limit.
// The timer is used to ensure that the dialog is only valid for a certain duration, preventing misuse or stale interactions.
class TimerDialogController extends GetxController {
  late DateTime _dialogOpenedAt;
  final int allowedDurationInSeconds = 30; // adjust as needed
// This is the allowed duration for the dialog to be valid, in seconds.
  // This controller manages the timer for a dialog, allowing it to be opened and checked for validity.

  void startTimer() {
    _dialogOpenedAt = DateTime.now();
  }
// This method starts the timer by recording the current time when the dialog is opened.
  /// Checks if the dialog is still within the allowed time limit.
  /// Returns true if the dialog is still valid, false otherwise.
  bool isWithinAllowedTime() {
    final elapsed = DateTime.now().difference(_dialogOpenedAt).inSeconds;
    return elapsed <= allowedDurationInSeconds;
  }
}
