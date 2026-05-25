import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final double saldo;
  final List<Map<String, dynamic>> riwayat;

  const HomePage({super.key, required this.saldo, required this.riwayat});

  @override
  Widget build(BuildContext context) {
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
              
              // Area Grafik Sederhana
              const Align(alignment: Alignment.centerLeft, child: Text("Grafik Pengeluaran", style: TextStyle(fontWeight: FontWeight.bold))),
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
