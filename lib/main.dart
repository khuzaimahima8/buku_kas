import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'riwayat_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Keuangan',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MainNavigation(),
    );
  }
}

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
  int? indexSedangDiedit;

  final TextEditingController nominalController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  @override
  void initState() {
    super.initState();
    muatDataPermanen();
  }

  void muatDataPermanen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      totalSaldo = prefs.getDouble('saldo_terakhir') ?? 5000000;
      String? riwayatString = prefs.getString('riwayat_terakhir');
      if (riwayatString != null) {
        riwayatTransaksi = List<Map<String, dynamic>>.from(json.decode(riwayatString));
      }
    });
  }

  void simpanTransaksi() async {
    String judulInput = keteranganController.text.trim();
    String nominalInput = nominalController.text.trim();

    if (nominalInput.isEmpty || judulInput.isEmpty) return;

    double inputNominal = double.tryParse(nominalInput) ?? 0;

    setState(() {
      if (indexSedangDiedit == null) {
        // --- MODE TAMBAH BARU ---
        DateTime sekarang = DateTime.now();

        if (isPemasukan) {
          totalSaldo += inputNominal;
        } else {
          totalSaldo -= inputNominal;
        }

        riwayatTransaksi.add({
          'judul': judulInput,
          'jumlah': inputNominal,
          'tipe': isPemasukan ? 'masuk' : 'keluar',
          'tanggal': "${sekarang.day}/${sekarang.month}",
        });
      } else {
        // --- MODE EDIT DATA ---
        double nominalLama = riwayatTransaksi[indexSedangDiedit!]['jumlah'];
        String tipeLama = riwayatTransaksi[indexSedangDiedit!]['tipe'];

        if (tipeLama == 'masuk') {
          totalSaldo -= nominalLama;
        } else {
          totalSaldo += nominalLama;
        }

        if (isPemasukan) {
          totalSaldo += inputNominal;
        } else {
          totalSaldo -= inputNominal;
        }

        riwayatTransaksi[indexSedangDiedit!] = {
          'judul': judulInput,
          'jumlah': inputNominal,
          'tipe': isPemasukan ? 'masuk' : 'keluar',
          'tanggal': riwayatTransaksi[indexSedangDiedit!]['tanggal'],
        };
        indexSedangDiedit = null;
      }

      nominalController.clear();
      keteranganController.clear();
      isPemasukan = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('saldo_terakhir', totalSaldo);
    await prefs.setString('riwayat_terakhir', json.encode(riwayatTransaksi));

    if (!mounted) return;
    Navigator.pop(context);
  }

  void pemicuEdit(int index) {
    setState(() {
      keteranganController.text = riwayatTransaksi[index]['judul'];
      nominalController.text = riwayatTransaksi[index]['jumlah'].toString();
      isPemasukan = riwayatTransaksi[index]['tipe'] == 'masuk';
      indexSedangDiedit = index;
      _currentIndex = 0;
    });
    tampilkanFormInput();
  }

  // --- 🟢 FUNGSI BARU: PROSES HAPUS DATA & UPDATE SALDO ---
  void pemicuHapus(int index) async {
    setState(() {
      double nominalHapus = riwayatTransaksi[index]['jumlah'];
      String tipeHapus = riwayatTransaksi[index]['tipe'];

      // Kembalikan saldo sebelum datanya dibuang
      if (tipeHapus == 'masuk') {
        totalSaldo -= nominalHapus;
      } else {
        totalSaldo += nominalHapus;
      }

      // Buang data dari daftar list
      riwayatTransaksi.removeAt(index);
    });

    // Perbarui memori penyimpanan internal HP
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('saldo_terakhir', totalSaldo);
    await prefs.setString('riwayat_terakhir', json.encode(riwayatTransaksi));
  }

  void tampilkanFormInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    indexSedangDiedit == null ? "Tambah Transaksi" : "Edit Transaksi",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("Pemasukan"),
                        selected: isPemasukan,
                        selectedColor: Colors.green.withAlpha(50),
                        onSelected: (bool selected) {
                          setState(() => isPemasukan = true);
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(width: 15),
                      ChoiceChip(
                        label: const Text("Pengeluaran"),
                        selected: !isPemasukan,
                        selectedColor: Colors.red.withAlpha(50),
                        onSelected: (bool selected) {
                          setState(() => isPemasukan = false);
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
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
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Nominal (Rp)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: simpanTransaksi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPemasukan ? Colors.green : Colors.red,
                      ),
                      child: const Text("Simpan", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      if (indexSedangDiedit != null) {
        setState(() {
          indexSedangDiedit = null;
          nominalController.clear();
          keteranganController.clear();
          isPemasukan = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage (
        totalSaldo: totalSaldo,
        riwayatTransaksi: riwayatTransaksi,
      ),
      RiwayatPage(
        data: riwayatTransaksi,
        onEdit: pemicuEdit,
        onHapus: pemicuHapus, // Hubungkan fungsi hapus ke halaman riwayat
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Riwayat'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: tampilkanFormInput,
              backgroundColor: Colors.green,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
