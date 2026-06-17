import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 🟢 Library online baru
import 'home_page.dart';
import 'riwayat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🟢 KUNCI PENGHUBUNG ONLINE
  await Supabase.initialize(
    url: 'https://supabase.co', // ⬅️ Pastikan sesuai URL Anda
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jb3Z4emNuYmd0amJ5aHlqdHp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2OTc0NzcsImV4cCI6MjA5NzI3MzQ3N30.2oGZT5nDUJmh8vaykl2PqMvS6YLVqwFbHQvMIJYropY',
  );

  runApp(const MyApp());
}

// Shortcut singkat untuk memanggil perintah Supabase di seluruh kode bawah
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Keuangan Online',
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
  double totalSaldo = 0; // 🟢 Set awal ke 0 sesuai database online
  bool isPemasukan = true;
  int? indexSedangDiedit;
  bool isLoading = true; // Indikator loading saat mengambil data dari internet

  final TextEditingController nominalController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  @override
  void initState() {
    super.initState();
    muatDataOnline(); // 🟢 Otomatis ambil data dari server internet saat aplikasi dibuka
  }

  // 🟢 FUNGSI BACKEND ONLINE: Mengambil data dari server Singapura
  void muatDataOnline() async {
    try {
      setState(() => isLoading = true);

      // 1. Ambil data total saldo terakhir dari tabel 'saldo_online'
      final dataSaldo = await supabase.from('saldo_online').select('total_saldo').eq('id', 1).single();
      
      // 2. Ambil semua list transaksi dari tabel 'transaksi_online' diurutkan berdasarkan id terkecil
      final List<dynamic> dataTransaksi = await supabase.from('transaksi_online').select().order('id', ascending: true);

      setState(() {
        totalSaldo = (dataSaldo['total_saldo'] as num).toDouble();
        riwayatTransaksi = List<Map<String, dynamic>>.from(dataTransaksi);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error muat data: $e");
    }
  }

  // 🟢 FUNGSI BACKEND ONLINE: Menyimpan data baru atau edit ke server internet
  void simpanTransaksi() async {
    String judulInput = keteranganController.text.trim();
    String nominalInput = nominalController.text.trim();

    if (nominalInput.isEmpty || judulInput.isEmpty) return;

    double inputNominal = double.tryParse(nominalInput) ?? 0;
    double saldoBaru = totalSaldo;

    if (indexSedangDiedit == null) {
      // --- MODE TAMBAH BARU ONLINE ---
      DateTime sekarang = DateTime.now();
      String tanggalFormat = "${sekarang.day}/${sekarang.month}";

      if (isPemasukan) {
        saldoBaru += inputNominal;
      } else {
        saldoBaru -= inputNominal;
      }

      // Kirim data transaksi baru ke tabel internet
      await supabase.from('transaksi_online').insert({
        'judul': judulInput,
        'jumlah': inputNominal,
        'tipe': isPemasukan ? 'masuk' : 'keluar',
        'tanggal': tanggalFormat,
      });
    } else {
      // --- MODE EDIT DATA ONLINE ---
      int idTransaksi = riwayatTransaksi[indexSedangDiedit!]['id'];
      double nominalLama = riwayatTransaksi[indexSedangDiedit!]['jumlah'];
      String tipeLama = riwayatTransaksi[indexSedangDiedit!]['tipe'];

      // Netralkan kalkulasi saldo lama terlebih dahulu
      if (tipeLama == 'masuk') {
        saldoBaru -= nominalLama;
      } else {
        saldoBaru += nominalLama;
      }

      // Hitung dengan nominal hasil edit baru
      if (isPemasukan) {
        saldoBaru += inputNominal;
      } else {
        saldoBaru -= inputNominal;
      }

      // Update data transaksi spesifik di server berdasarkan ID uniknya
      await supabase.from('transaksi_online').update({
        'judul': judulInput,
        'jumlah': inputNominal,
        'tipe': isPemasukan ? 'masuk' : 'keluar',
      }).eq('id', idTransaksi);

      indexSedangDiedit = null;
    }

    // Perbarui angka total saldo di server internet agar sinkron
    await supabase.from('saldo_online').update({'total_saldo': saldoBaru}).eq('id', 1);

    // Ambil ulang data segar dari server untuk memperbarui tampilan layar
    muatDataOnline();

    nominalController.clear();
    keteranganController.clear();
    isPemasukan = true;

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

  // --- 🟢 FUNGSI BACKEND ONLINE: Menghapus data transaksi dari server internet ---
  void pemicuHapus(int index) async {
    int idTransaksi = riwayatTransaksi[index]['id'];
    double nominalHapus = riwayatTransaksi[index]['jumlah'];
    String tipeHapus = riwayatTransaksi[index]['tipe'];
    double saldoBaru = totalSaldo;

    // Hitung pengembalian saldo utama akibat data dihapus
    if (tipeHapus == 'masuk') {
      saldoBaru -= nominalHapus;
    } else {
      saldoBaru += nominalHapus;
    }

    // 1. Hapus baris data dari tabel internet berdasarkan ID-nya
    await supabase.from('transaksi_online').delete().eq('id', idTransaksi);

    // 2. Perbarui nominal total saldo terbaru ke server internet
    await supabase.from('saldo_online').update({'total_saldo': saldoBaru}).eq('id', 1);

    // Ambil ulang data segar dari server agar layar langsung terupdate otomatis
    muatDataOnline();
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
                    indexSedangDiedit == null ? "Tambah Transaksi Online" : "Edit Transaksi Online",
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
                      child: const Text("Simpan Ke Cloud", style: TextStyle(color: Colors.white)),
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
      HomePage(
        totalSaldo: totalSaldo,
        riwayatTransaksi: riwayatTransaksi,
      ),
      RiwayatPage(
        data: riwayatTransaksi,
         onEdit: pemicuEdit, 
         onHapus: pemicuHapus,
         ),
    ];

    return Scaffold(
      body: isLoading? const Center(
        child: CircularProgressIndicator(color: Colors.green))//animasi loading memutar saat sinkronisasi internt
        :pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index){
            setState(() {
              _currentIndex = index;
            });
          },
          items: const[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Riwayat'),
          ],
          ),
          floatingActionButton: _currentIndex== 0&& !isLoading?FloatingActionButton(
            onPressed: tampilkanFormInput,
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white),
             )
             :null,
    );
  }
  }