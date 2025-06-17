import 'package:get/get.dart';

class TimerDialogController extends GetxController {
  late DateTime _dialogOpenedAt;
  final int allowedDurationInSeconds = 30; // adjust as needed

  void startTimer() {
    _dialogOpenedAt = DateTime.now();
  }

  bool isWithinAllowedTime() {
    final elapsed = DateTime.now().difference(_dialogOpenedAt).inSeconds;
    return elapsed <= allowedDurationInSeconds;
  }
}
