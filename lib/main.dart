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
  //daftar transaksi sementara (masih di memori HP)
  List<Map<String, dynamic>> riwayatTransaksi = [];
  double totalSaldo = 5000000; //saldo awal sesuai gambar kamu

  //constroler untuk mengambil teks dari inputan
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  final List<Widget> _page = [const HomePage(), const RiwayatPage()];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page[_currentIndex],
      //Tombol Tambah Transaksi Di Tengah
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormTambah(context),
        backgroundColor: const Color(0xFF2962FF),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.home_rounded,
                  color: _currentIndex == 0 ? Colors.blue : Colors.grey),
                  onPressed: () => setState(() => _currentIndex = 0),
                  ),
                  const SizedBox(width: 40), //Ruang untuk tombol +
                  IconButton(
                    icon: Icon(Icons.receipt_long_rounded,
                    color: _currentIndex == 1 ? Colors.blue: Colors.grey),
                    onPressed: () => setState(() => _currentIndex =1),
                    ),
              ],
            ),
          ),
        ),
    );
  }


//popup from tambah(crud)
void _showFormTambah(BuildContext context){
  showModalBottomSheet(context: context, 
  isScrollControlled: true,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  builder: (context) => Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context). viewInsets.bottom,
      left: 20, right: 20, top: 20
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300],borderRadius: BorderRadius.circular(10))),
        const SizedBox(height: 20),
        const Text("Tambah Transaksi Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(
          controller: nominalController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "Nominal", prefixText: "Rp", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
        const SizedBox(height: 15),
        TextField(decoration: InputDecoration(labelText: "Keterangan", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              setState((){
                //1. ambil angka dari inputan
                double nominal = double.parse(nominalController.text);
                 
                 //2. update saldo utama
                 totalSaldo += nominal;
                
                //3. masukkan data ke daftar riwayat
                riwayatTransaksi.add({
                  'judul' : keteranganController.text,
                  'jumlah' : nominal,
                  'tanggal' : 'Hari ini',
                });
                //4. bersikan form agar kosong saat dibuka lagi
                nominalController.clear();
                keteranganController.clear();

                //5. tutup popup panel bawah
                Navigator.pop(context);
              });
            },
              child: const Text("Simpan Transaksi"))
             ),
        const SizedBox(height: 30)
      ],
    ),
    ),
    );
}
}