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
  bool isPemasukan = true;

  final TextEditingController nominalController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  void simpanTransaksi() {
    if (nominalController.text.isEmpty || keteranganController.text.isEmpty) return;

    double inputNominal = double.tryParse(nominalController.text) ?? 0;
    DateTime sekarang = DateTime.now();

    setState(() {
      if (isPemasukan){
        totalSaldo += inputNominal; //menambah saldo jika pemasukan
      } else {
        totalSaldo -= inputNominal; //mengurangisaldo jika pengeluaran
      }
      riwayatTransaksi.add({
        'judul' : keteranganController.text,
        'jumlah' : inputNominal,
        'tipe' : isPemasukan ? 'masuk' : 'keluar', //tanda tipe tranaksi
        'tanggal' : "${sekarang.day}/${sekarang.month}",
      });
      nominalController.clear();
      keteranganController.clear();
      isPemasukan = true; //reset pilihan ke default setelah disimpan
    });
    Navigator.pop(context); // Tutup pop-up setelah simpan
  }

  // Fungsi untuk memunculkan kotak input (Pop-up)
  void tampilkanFormInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Tambah Transaksi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text("Pemasukan"),
                     selected: isPemasukan,
                     selectedColor: Colors.green.shade200,
                     onSelected: (val) => setModalState(() => isPemasukan = true),
                     ),
                     const SizedBox(width: 10),
                     ChoiceChip(
                      label: const Text("Pengeluaran"), 
                      selected: !isPemasukan,
                      selectedColor: Colors.red.shade200,
                      onSelected: (val) => setModalState(() => isPemasukan = false),
                      ),
                ],
              ),
              const SizedBox(height: 10),
          const SizedBox(height: 15),

          TextField(
            controller: keteranganController,
            decoration: const InputDecoration(
              labelText: "Keterangan",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),

          TextField(
            controller: nominalController,
            decoration: const InputDecoration(
              labelText: "Nominal",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: simpanTransaksi,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPemasukan ? Colors.green : Colors.red,
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
           ],
          ),
        ),
        )
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