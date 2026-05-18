import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget{
  //ini adalah penampung data yang dikirim dari main.dart
  final List<Map<String, dynamic>> data;

  //tempat menampung perintah edit yang dikirim dari main.dart
  final Function(int) onEdit;

  const RiwayatPage({super.key, required this.data, required this.onEdit});

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
          //menampilkan keterangan/judul sesuai yang diketik
          title: Text(data[index]['judul'] ?? "Tanpa keterangan"),
          subtitle: Text(data[index]['tanggal'] ?? "Hari ini"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Rp ${data[index]['jumlah']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green
                ),
              ),
              const SizedBox(width: 10),
              //Tombol edit (ikon pensil)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => onEdit(index),//memicu fungsi edit berdasarkan nomor urut
                ),
            ],
          )
        );
        })
    );
  }
}