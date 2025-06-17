import 'package:flutter/material.dart';

import 'document_list_tile.dart';

class Doc extends StatelessWidget {
  const Doc({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('at', style: TextStyle(fontSize: 50, color: Colors.white)),
            Container(
              width: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  'Devs',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
          ],
        ),

        actions: [
          Container(
            margin: EdgeInsets.all(10),
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              // color: Colors.white,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Sign In',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.orange[600],
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu, color: Colors.white),
            );
          },
        ),
      ),
      drawer: DocDrawer(),
      body: DocBody(),
    );
  }
}

class DocDrawer extends StatelessWidget {
  const DocDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          DrawerTile(text: 'LEARN', icon: Icons.school),
          DrawerTile(text: 'Tutorials'),
          SizedBox(height: 20),
          DrawerTile(text: 'API REFERENCE', icon: Icons.menu_book_rounded),
          DrawerTile(text: 'Authentication'),
          DrawerTile(text: 'Request Headers'),
          ExpandTile(text1: 'SMS', text2: 'Overview', text3: 'SENDING'),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            trailing: Icon(Icons.arrow_forward_ios_rounded),
            title: Text('USSD'),
          ),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            trailing: Icon(Icons.arrow_forward_ios_rounded),
            title: Text('Voice'),
          ),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            trailing: Icon(Icons.arrow_forward_ios_rounded),
            title: Text('Airtime'),
          ),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            trailing: Icon(Icons.arrow_forward_ios_rounded),
            title: Text('Mobile Data'),
          ),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            title: Text('Application'),
          ),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            trailing: Icon(Icons.arrow_forward_ios_rounded),
            title: Text('Whatsapp'),
          ),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            title: Text('Notifications'),
          ),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            title: Text('Indempotent Requests'),
          ),
          SizedBox(height: 20),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            leading: Icon(Icons.settings),
            title: Text('TOOLS'),
          ),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            title: Text('Simulator'),
          ),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            title: Text('Postman Collections'),
          ),
          SizedBox(height: 20),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            leading: Icon(Icons.live_help),
            title: Text('SUPPORT'),
          ),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            title: Text('Slack'),
          ),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            title: Text('Github'),
          ),
          ListTile(
            visualDensity: VisualDensity(vertical: -4),
            title: Text('Help Center'),
          ),
        ],
      ),
    );
  }
}

class ExpandTile extends StatelessWidget {
  const ExpandTile({
    super.key,
    required this.text1,
    this.icon,
    this.text2,
    this.text3,
    this.text4,
    this.text5,
    this.text6,
    this.text7,
  });
  final String text1;
  final IconData? icon;
  final String? text2;
  final String? text3;
  final String? text4;
  final String? text5;
  final String? text6;
  final String? text7;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      childrenPadding: EdgeInsets.zero,
      visualDensity: VisualDensity(vertical: -4),
      title: Text(text1),
      initiallyExpanded: false,
      children: [
        ListTile(
          visualDensity: VisualDensity(vertical: -4),
          title: Text(
            text2 ?? '',
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
        ListTile(
          visualDensity: VisualDensity(vertical: -4),
          title: Text(
            text3 ?? '',
            style: TextStyle(fontWeight: FontWeight.w100),
          ),
        ),
      ],
    );
  }
}

class DrawerTile extends StatelessWidget {
  const DrawerTile({super.key, this.icon, required this.text});
  final IconData? icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity(vertical: -4),
      contentPadding: EdgeInsets.only(left: 15),
      leading: Icon(icon),
      title: Text(text),
    );
  }
}
