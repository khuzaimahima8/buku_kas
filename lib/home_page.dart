import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final double saldo;
  final List<Map<String, dynamic>> riwayat;

  const HomePage({super.key, required this.saldo, required this.riwayat});

  @override
  Widget build(BuildContext context) {
    //menghitung total pemasukkan
    double totalmasuk = riwayat
    .where((item) => item['tipe'] == 'masuk')
    .fold(0, (sum, item) => sum + item['jumlah']);

    //menghitung total pengeluaran
    double totalkeluar = riwayat
    .where((item) => item['tipe'] == 'keluar')
    .fold(0, (sum, item) => sum + item['jumlah']);

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Kartu Saldo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text("Total Saldo Seluruhnya", style: TextStyle(color: Colors.white70)),
                    Text("Rp ${saldo.toStringAsFixed(0)}", 
                         style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              //barisan rekap (pemasukan & pengeluaran)
              Row(
                children: [
                  //kotak pemasukan
                  Expanded(child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Column(
                      children: [
                        const Text("pemasukan", style: TextStyle(color: Colors.green, fontSize: 12)),
                        Text("Rp ${totalmasuk.toStringAsFixed(0)}",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(width: 10),
                  //kotak pengeluaran
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Column(
                        children: [
                          const Text("pegeluaran", style: TextStyle(color: Colors.red, fontSize: 12)),
                          Text("Rp ${totalkeluar.toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                    )
                  )
                ],
              ),
              
              // Area Grafik Sederhana
              Align(alignment: Alignment.centerLeft, child: const Text("Grafik Pengeluaran", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              Container(
                height: 150,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: riwayat.isEmpty 
                    ? [const Center(child: Text("Belum ada data"))] 
                    : riwayat.map((data) {
                        return Container(
                          width: 20,
                          height: (data['jumlah'] / 100000) * 50, // Logika tinggi batang grafik
                          color: Colors.green,
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
