import 'package:get/get.dart';
import 'package:afri/others/utilis/timer_utili.dart';

class MockTimerDialogController extends GetxController
    implements TimerDialogController {
  bool _isValid = true;

  @override
  bool isWithinAllowedTime() => _isValid;

  @override
  void startTimer() {

  }

  @override
  int get allowedDurationInSeconds => 30; 

  void setValidity(bool value) => _isValid = value;
}
