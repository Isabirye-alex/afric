import 'package:get/get.dart';
import 'package:afri/others/utilis/timer_utili.dart';
// This file contains a mock implementation of the TimerDialogController for testing purposes.
class MockTimerDialogController extends GetxController
    implements TimerDialogController {
  bool _isValid = true;
// This boolean indicates whether the timer is valid or not.
  @override
  bool isWithinAllowedTime() => _isValid;
// This method checks if the timer is still valid based on the _isValid flag.
  @override
  void startTimer() {

  }
// This method is overridden but does not perform any action in the mock implementation.
// It is used to simulate the behavior of starting a timer without actually implementing it.
  @override
  int get allowedDurationInSeconds => 30; 
// This is the allowed duration for the dialog to be valid, in seconds.
// This getter returns the allowed duration for the timer, which is set to 30 seconds in
  void setValidity(bool value) => _isValid = value;
}
