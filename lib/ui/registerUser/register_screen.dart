import 'package:countries/countries.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/changeNumber/change_number_controller.dart';
import '../../core/country/countries_controller.dart';
import '../../others/utilis/constants/text_constants.dart';

//Declaration of Country Widget as a StatelessWidget to display the country picker,country flag, and the phone number input field
// This widget is used in the registration screen to allow users to select their country and enter their phone number
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final countriesController = Get.put(CountriesController());
    final controller = Get.put(UserController());
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(8.0),
              children: <Widget>[
                Heading(),
                IntroductionParagraphs(),
                SizedBox(height: 10),
                CountryCodeAndFlag(countriesController: countriesController),
                SizedBox(height: 10),
                TCsParagraph(),
                CancelAndProceedWidget(controller: controller),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// This widget contains the cancel and proceed buttons for the registration process.
// It uses the UserController to handle the registration logic when the user clicks on the "PROCEED" button.
// The "CANCEL" button simply closes the dialog without any action.
class CancelAndProceedWidget extends StatelessWidget {
  const CancelAndProceedWidget({super.key, required this.controller});

  final UserController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text('CANCEL', style: TextStyle(color: Colors.blue)),
        ),
        TextButton(
          onPressed: () {
            controller.handleContactRegistration(context);
          },
          child: Text("PROCEED"),
        ),
      ],
    );
  }
}
// This widget displays the terms and conditions paragraph.
class TCsParagraph extends StatelessWidget {
  const TCsParagraph({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(Texts.paragraph3, style: TextStyle(color: Colors.grey));
  }
}
// This widget displays the country code and flag, allowing users to select their country and enter their phone number.
// It uses the CountriesController to manage the selected country and display the corresponding flag and phone code
class CountryCodeAndFlag extends StatelessWidget {
  const CountryCodeAndFlag({super.key, required this.countriesController});

  final CountriesController countriesController;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    return Obx(() {
      final selectedCountry = countriesController.country.value;
      if (selectedCountry == null) {
        return Text("Select a country");
      }
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            // Country picker
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: () =>
                    countriesController.showCountryPickerDialog(context),
                child: Obx(() {
                  final selectedCountry = countriesController.country.value;

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        if (selectedCountry != null) ...[
                          CountryFlagWidget(selectedCountry, width: 30),
                          // SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "+${selectedCountry.phoneCode}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              selectedCountry.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else
                          Text("Select"),
                        Spacer(),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  );
                }),
              ),
            ),

            SizedBox(width: 10),

            //Phone number input
            Expanded(
              flex: 7,
              child: TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
//
class IntroductionParagraphs extends StatelessWidget {
  const IntroductionParagraphs({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            Texts.paragraph,
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          Text(
            Texts.paragraph2,
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
// This widget displays the heading of the registration screen.
class Heading extends StatelessWidget {
  const Heading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 24),
      child: Row(
        children: [
          Text('at', style: TextStyle(fontSize: 70)),
          Container(height: 30, width: 3, color: Colors.grey),
          Text('Sandbox', style: TextStyle(fontSize: 50)),
        ],
      ),
    );
  }
}
