import 'package:flutter/material.dart';
import 'home_page.dart';
import 'riwayat_page.dart';

void main() => runApp(const MaterialApp(
      home: MainNavigation(),
      debugShowCheckedModeBanner: false,
    ));

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> riwayatTransaksi = [];
  double totalSaldo = 5000000;

  final TextEditingController nominalController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  void simpanTransaksi() {
    if (nominalController.text.isEmpty || keteranganController.text.isEmpty) return;

    double inputNominal = double.tryParse(nominalController.text) ?? 0;
    DateTime sekarang = DateTime.now();

    setState(() {
      totalSaldo -= inputNominal; // Mengurangi saldo
      riwayatTransaksi.add({
        'judul': keteranganController.text,
        'jumlah': inputNominal,
        'tanggal': "${sekarang.day}/${sekarang.month}",
      });
      nominalController.clear();
      keteranganController.clear();
    });
    Navigator.pop(context); // Tutup pop-up setelah simpan
  }

  // Fungsi untuk memunculkan kotak input (Pop-up)
  void tampilkanFormInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Tambah Transaksi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextField(controller: keteranganController, decoration: const InputDecoration(labelText: "Keterangan")),
            TextField(controller: nominalController, decoration: const InputDecoration(labelText: "Nominal"), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: simpanTransaksi, child: const Text("Simpan")),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(saldo: totalSaldo, riwayat: riwayatTransaksi),
      RiwayatPage(data: riwayatTransaksi, onEdit: (i) {}),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: tampilkanFormInput,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home), onPressed: () => setState(() => _currentIndex = 0)),
            const SizedBox(width: 40), // Ruang untuk tombol +
            IconButton(icon: const Icon(Icons.history), onPressed: () => setState(() => _currentIndex = 1)),
          ],
        ),
      ),
    );
  }
}
