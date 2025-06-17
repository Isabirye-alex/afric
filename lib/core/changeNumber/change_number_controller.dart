import 'package:countries/countries.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../others/models/user_model.dart';
import '../../ui/registerUser/register_dialog.dart';
import '../../ui/registerUser/register_screen.dart';
import '../country/countries_controller.dart';
import '../database/register_user_to_db.dart';
import '../fetchDataFromApi/fetch_data_class.dart';

class UserController extends GetxController {
  final RxBool isLoading = true.obs;
  final country = Country();
  static UserController get instance => Get.find();
  late final TextEditingController phoneController = TextEditingController();
  var displayText = 'Loading...'.obs;

  @override
  void onInit() {
    super.onInit();
    loadPhoneNumber();
  }

  Future<void> loadPhoneNumber() async {
    try {
      final users = await UserDatabase.instance.getUsers();
      if (users.isNotEmpty) {
        final code = '+${users.first.code}';
        final number = users.first.phoneNumber;
        displayText.value = '$code $number';
      } else {
        displayText.value = 'Ready!';
      }
    } catch (e, stacktrace) {
      debugPrint('Error loading phone number: $e');
      debugPrint('Stack trace: $stacktrace');
      displayText.value = 'Ready!';
    }
  }

  void handleContactRegistration(BuildContext context) async {
    final countryController = Get.put(CountriesController());
    final phone = phoneController.text.trim();
    if (phone.isNotEmpty) {
      final user = UserView(
        id: 1,
        code: countryController.country.value?.phoneCode ?? '',
        phoneNumber: phone,
      );
      await UserDatabase.instance.insertOrUpdateUser(user);
      displayText.value = '+${user.code} ${user.phoneNumber}';
      Get.snackbar(
        'User saved successfully',
        'You can now continue',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 4),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      Navigator.of(context).pop();
    } else if (phone.isEmpty) {
      Get.snackbar(
        'Warning',
        'Enter a valid phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Phone number cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 4),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void checkUserStatus() async {
    List<UserView> users = await UserDatabase.instance.getUsers();

    // Check if any user has a non-empty phone number
    final hasPhone = users.any((u) => u.phoneNumber.trim().isNotEmpty);
    if (hasPhone) {
      Get.dialog(PopUpDialog(child: ViewWidget()), barrierDismissible: false);
    } else {
      Get.dialog(
        PopUpDialog(child: RegisterScreen()),
        barrierDismissible: false,
      );
    }
  }

  Future<void> updateUserPhoneNumber(BuildContext context) async {
    final countryController = Get.put(CountriesController());
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      Get.snackbar(
        'Warning',
        'Phone number cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Get existing user
    final users = await UserDatabase.instance.getUsers();
    if (users.isEmpty || users.first.phoneNumber.trim().isEmpty) {
      Get.snackbar(
        'Not Registered',
        'Please! First register a phone number to continue.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      phoneController.clear();
      Navigator.of(context).pop();
    }
    final user = UserView(
      id: users.first.id,
      code: countryController.country.value?.phoneCode ?? '',
      phoneNumber: phone,
    );
    try {
      await UserDatabase.instance.updateUser(user);
      displayText.value = '+${user.code} ${user.phoneNumber}'; // Update UI
      Get.snackbar(
        'Updated',
        'Phone number updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      phoneController.clear();
      Navigator.of(context).pop(); // Close dialog
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update number: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
