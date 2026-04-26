import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat")),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const ListTile(
          leading: Icon(Icons.arrow_downward, color: Colors.green),
          title: Text("Pemasukan"),
          trailing: Text("+ Rp 500.000"),
        ),
        ),
    );
  }
}