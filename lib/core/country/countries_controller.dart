import 'package:countries/countries.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CountriesController extends GetxController {
  static CountriesController get instance => Get.find();
  var country = Rxn<Country>();

  @override
  void onInit() {
    super.onInit();
    country.value = CountriesRepo.getCountryByPhoneCode('90');
  }

  void showCountryPickerDialog(BuildContext context) async {
    final selected = await showDialog<Country>(
      context: context,
      builder: (context) {
        String query = '';
        List<Country> filteredList = List.from(CountriesRepo.countryList)..sort((a, b)=>a.name.compareTo(b.name));
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search country...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    query = value.toLowerCase();
                    filteredList = CountriesRepo.countryList
                        .where(
                          (c) =>
                              c.name.toLowerCase().contains(query) ||
                              c.phoneCode.contains(query),
                        )
                        .toList();
                  });
                },
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 400,
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final c = filteredList[index];
                    return ListTile(
                      leading: CountryFlagWidget(c, width: 24),
                      title: Text(c.name),
                      subtitle: Text("+${c.phoneCode}"),
                      onTap: () {
                        Navigator.of(context).pop(c);
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
    if (selected != null) {
      country.value = selected;
    }
  }
}
