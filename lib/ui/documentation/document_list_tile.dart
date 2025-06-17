import 'package:flutter/material.dart';

import '../../others/widgets/reusables/custom_shape.dart';
import '../../others/widgets/reusables/elevated_card.dart';
import '../../others/widgets/reusables/second_shape.dart';
import '../../others/widgets/reusables/tutorials_container.dart';

class DocBody extends StatelessWidget {
  const DocBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              CustomShape(),
              ElevatedCard(
                color: Colors.green,
                icon: Icons.message,
                text: 'SMS',
                text1: 'Tutorials',
                text2: 'API Reference',
              ),
              SizedBox(height: 14),
              ElevatedCard(
                color: Colors.red,
                icon: Icons.dialer_sip_outlined,
                text: 'USSD',
                text1: 'Tutorials',
                text2: 'API Reference',
              ),
              SizedBox(height: 14),
              ElevatedCard(
                color: Colors.amber,
                icon: Icons.quick_contacts_dialer_outlined,
                text: 'Voice',
                text1: 'Tutorials',
                text2: 'API Reference',
              ),
              SizedBox(height: 14),
              ElevatedCard(
                color: Colors.green,
                icon: Icons.money_sharp,
                text: 'Airtime',
                text1: 'Tutorials',
                text2: 'API Reference',
              ),
              SizedBox(height: 14),
              ElevatedCard(
                color: Colors.red,
                icon: Icons.lte_plus_mobiledata,
                text: 'Mobile Data',
                text1: 'Tutorials',
                text2: 'API Reference',
              ),
              SizedBox(height: 14),
              ElevatedCard(
                color: Colors.amber,
                icon: Icons.message_outlined,
                text: 'whatsapp',
                text1: 'Tutorials',
                text2: 'API Reference',
              ),
              SizedBox(height: 30),
              TutorialsContainer(),
              SecondShape(),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.green,
            ),
            child: Icon(Icons.question_answer, size: 30),
          ),
        ),
      ],
    );
  }
}
