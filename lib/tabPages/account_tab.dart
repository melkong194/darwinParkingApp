import 'package:flutter/material.dart';

class AccountTabPage extends StatefulWidget {
  const AccountTabPage({Key? key}) : super(key: key);

  @override
  State<AccountTabPage> createState() => _AccountTabPageState();
}

class _AccountTabPageState extends State<AccountTabPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Account'),
    );
  }
}
