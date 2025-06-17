import 'package:flutter/material.dart';

void showRegisterDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withAlpha(70),
    builder: (BuildContext context) {
      return const PopUpDialog();
    },
  );
}

class PopUpDialog extends StatelessWidget {
  const PopUpDialog({super.key, this.child});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            // maxHeight: 400
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: child,
        ),
      ),
    );
  }
}
