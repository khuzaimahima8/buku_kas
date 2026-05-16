import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget{
  //ini adalah penampung data yang dikirim dari main.dart
  final List<Map<String, dynamic>> data;

  const RiwayatPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Transaksi")),
      //logika : jika data kosong tamplkan pesan, 'jika ada tampilkan List'
      body: data.isEmpty
      ? const Center(child: Text("Belum ada riwayat transaksi"))
      : ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index){
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.add,color: Colors.white),
          ),
          title: Text(data[index]['judul']),
          subtitle: const Text("Hari ini"),
          trailing: Text(
            "Rp ${data[index]['jumlah']}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green
            ),
          ),
        );
        })
    );
  }
}