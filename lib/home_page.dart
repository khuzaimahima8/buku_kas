import 'package:flutter/material.dart'; 
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("KAS PPBA", style: TextStyle(color: Colors.blue))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: const Text("Rp 5.000.000", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(LineChartData(lineBarsData: [
                LineChartBarData(spots: [const FlSpot(0, 3), const FlSpot(1, 4)], color: Colors.green),
              ])),
            )
          ],
        ),),
    );
  }
}