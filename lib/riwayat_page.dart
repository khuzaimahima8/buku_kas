import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Function(int) onEdit;
  final Function(int) onHapus; // Tambahkan fungsi hapus di sini

  const RiwayatPage({
    super.key,
    required this.data,
    required this.onEdit,
    required this.onHapus, // Wajib diisi dari main.dart
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      body: data.isEmpty
          ? const Center(
              child: Text(
                'Belum ada riwayat transaksi.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final isMasuk = item['tipe'] == 'masuk';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMasuk ? Colors.green.withAlpha(30) : Colors.red.withAlpha(30),
                      child: Icon(
                        isMasuk ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isMasuk ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      item['judul'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(item['tanggal'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Teks Nominal Uang
                        Text(
                          '${isMasuk ? '+' : '-'} Rp ${item['jumlah'].toStringAsFixed(0)}',
                          style: TextStyle(
                            color: isMasuk ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tombol Edit (Pena)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => onEdit(index),
                        ),
                        // Tombol Hapus (Tong Sampah)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onHapus(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
