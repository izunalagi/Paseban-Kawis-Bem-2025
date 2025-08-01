import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_card.dart';
import '../../pages/dashboard/kuis/main_kuis.dart';
import '../../pages/dashboard/modul/kelola_modul_page.dart';
import '../../pages/dashboard/user/main_user.dart';
import '../dashboard/kategori_modul/kelola_kategori_page.dart';
import 'package:provider/provider.dart';
import '../../../providers/category_modul_provider.dart';
import '../../../providers/modul_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/quiz_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<AuthProvider>(context, listen: false).fetchStatistik(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // HAPUS appBar di sini, biar tidak double
        backgroundColor: AppColors.backgroundLight,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hai, Admin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Kelola aplikasi dengan mudah',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Search Bar
              // const CustomSearchBar(hintText: 'Cari data...'),
              // const SizedBox(height: 24),

              // Statistics Cards
              const Text(
                'Statistik',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              if (authProv.statistikLoading)
                const Center(child: CircularProgressIndicator())
              else if (authProv.statistikError != null)
                Center(child: Text(authProv.statistikError!))
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Pengguna',
                        authProv.totalUser?.toString() ?? '-',
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total Modul',
                        authProv.totalModul?.toString() ?? '-',
                        Icons.book,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Kuis',
                        authProv.totalQuiz?.toString() ?? '-',
                        Icons.quiz,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pengguna Aktif',
                        authProv.userAktif?.toString() ?? '-',
                        Icons.trending_up,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // Management Section
              const Text(
                'Kelola Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              CustomCard(
                title: 'Kelola Pengguna',
                subtitle: 'Tambah, ubah, dan hapus data pengguna',
                icon: Icons.people_outline,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserPage()),
                  );
                },
              ),
              const SizedBox(height: 12),

              CustomCard(
                title: 'Kelola Modul',
                subtitle: 'Tambah, ubah, dan hapus modul pembelajaran',
                icon: Icons.library_books_outlined,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                            create: (_) => ModulProvider(),
                          ),
                          ChangeNotifierProvider(
                            create: (_) => CategoryModulProvider(),
                          ),
                        ],
                        child: const KelolaModulPage(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              CustomCard(
                title: 'Kelola Kategori',
                subtitle: 'Tambah, ubah, dan hapus kategori modul',
                icon: Icons.category_outlined,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (_) => CategoryModulProvider(),
                        child: const KelolaKategoriPage(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              CustomCard(
                title: 'Kelola Kuis',
                subtitle: 'Tambah, ubah, dan hapus soal kuis',
                icon: Icons.quiz_outlined,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (_) => QuizProvider(),
                        child: QuizPage(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
