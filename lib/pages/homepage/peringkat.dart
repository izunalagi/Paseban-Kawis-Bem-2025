import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';

class PeringkatPage extends StatefulWidget {
  const PeringkatPage({super.key});

  @override
  State<PeringkatPage> createState() => _PeringkatPageState();
}

class _PeringkatPageState extends State<PeringkatPage> {
  String selectedKuis = 'Semua Kuis';

  final List<Map<String, dynamic>> leaderboard = [
    {
      "name": "Izuna Aja",
      "score": 100,
      "icon": Icons.emoji_events,
      "color": Colors.orange,
    },
    {
      "name": "Kiarra",
      "score": 95,
      "icon": Icons.military_tech,
      "color": Colors.green,
    },
    {
      "name": "Rara",
      "score": 90,
      "icon": Icons.military_tech,
      "color": Colors.red,
    },
    {"name": "Hades", "score": 85},
    {"name": "Cato", "score": 80},
    {"name": "Ares", "score": 75},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Peringkat'),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                const Text(
                  '🏆 Peringkat',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Lihat posisi anda di papan peringkat',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey[200],
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: DropdownButtonFormField<String>(
              value: selectedKuis,
              items: ['Semua Kuis', 'Kuis 1', 'Kuis 2']
                  .map(
                    (kuis) => DropdownMenuItem(value: kuis, child: Text(kuis)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedKuis = value!;
                });
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final user = leaderboard[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        "${index + 1}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: Text(user["name"][0]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          user["name"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (user.containsKey("icon"))
                        Icon(user["icon"], color: user["color"], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "${user["score"]}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
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
