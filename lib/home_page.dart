import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final double totalSaldo;
  final List<Map<String, dynamic>> riwayatTransaksi;

  const HomePage({
    super.key,
    required this.totalSaldo,
    required this.riwayatTransaksi,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard Keuangan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- KOTAK INFORMASI SALDO UTAMA ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Saldo Anda",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rp ${totalSaldo.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // --- JUDUL SUB-MENU ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Aktivitas Terbaru",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${riwayatTransaksi.length} Transaksi",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          // --- DAFTAR RINGKASAN TRANSAKSI SINGKAT ---
          Expanded(
            child: riwayatTransaksi.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada transaksi saat ini.\nKlik tombol + untuk menambah.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: riwayatTransaksi.length > 5 ? 5 : riwayatTransaksi.length,
                    itemBuilder: (context, index) {
                      // Menampilkan dari transaksi yang paling baru di atas
                      final transaksi = riwayatTransaksi[riwayatTransaksi.length - 1 - index];
                      final bool isMasuk = transaksi['tipe'] == 'masuk';

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isMasuk ? Colors.green.withAlpha(30) : Colors.red.withAlpha(30),
                            child: Icon(
                              isMasuk ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isMasuk ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(
                            transaksi['judul'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(transaksi['tanggal'] ?? ''),
                          trailing: Text(
                            "${isMasuk ? '+' : '-'} Rp ${transaksi['jumlah'].toStringAsFixed(0)}",
                            style: TextStyle(
                              color: isMasuk ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
