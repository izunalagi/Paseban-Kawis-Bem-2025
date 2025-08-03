import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_widget.dart';
import '../../services/modul_service.dart';
import '../../services/category_modul_service.dart';
import '../../models/modul_model.dart';
import '../../providers/quiz_provider.dart';
import 'modul_detail_page.dart';
import '../../services/quiz_service.dart';
import 'quiz_list_page.dart';
import 'quiz_detail_page.dart';
import 'chatbot_page.dart';
// import '../../widgets/custom__button_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<dynamic> _modulList = [];
  List<dynamic> _kategoriList = [];
  bool _isLoading = true;
  String? _selectedKategori;
  String _userName = 'User'; // Default nama user

  // Data dinamis untuk "Terakhir Diakses"
  List<Map<String, dynamic>> _recentlyAccessed = [];
  List<dynamic> _quizList = [];
  bool _isQuizLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _loadData();
    _loadQuizData(); // Load quiz list
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user data when dependencies change (e.g., returning from profile page)
    _loadUserData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh data ketika app kembali aktif
      _loadRecentlyAccessedModules();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        setState(() {
          _userName = userData['nama'] ?? 'User';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Tetap gunakan default 'User' jika ada error
    }
  }

  // Method untuk refresh nama user secara manual
  Future<void> refreshUserName() async {
    await _loadUserData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final modulService = ModulService();
      final categoryService = CategoryModulService();

      final modulData = await modulService.fetchModul();
      final kategoriData = await categoryService.fetchKategori();

      setState(() {
        _modulList = modulData;
        _kategoriList = kategoriData;
        _isLoading = false;
      });

      // Load modul yang terakhir diakses
      _loadRecentlyAccessedModules();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  Future<void> _loadQuizData() async {
    setState(() => _isQuizLoading = true);
    try {
      final quizService = QuizService();
      final quizData = await quizService.fetchQuizList();
      setState(() {
        _quizList = quizData;
        _isQuizLoading = false;
      });
    } catch (e) {
      setState(() => _isQuizLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat daftar kuis: $e')));
      }
    }
  }

  Future<void> _loadRecentlyAccessedModules() async {
    try {
      // Ambil data modul yang terakhir diakses dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final recentlyAccessedString = prefs.getString(
        'recently_accessed_modules',
      );

      if (recentlyAccessedString != null) {
        final recentlyAccessedIds =
            jsonDecode(recentlyAccessedString) as List<dynamic>;

        // Filter modul berdasarkan ID yang tersimpan
        final filteredModul = _modulList.where((modul) {
          return recentlyAccessedIds.contains(modul['id']);
        }).toList();

        setState(() {
          _recentlyAccessed = filteredModul.cast<Map<String, dynamic>>();
        });
      } else {
        // Jika belum ada data, ambil 3 modul pertama sebagai default
        if (_modulList.isNotEmpty) {
          setState(() {
            _recentlyAccessed = _modulList
                .take(3)
                .cast<Map<String, dynamic>>()
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error loading recently accessed modules: $e');
      // Fallback ke modul pertama jika ada error
      if (_modulList.isNotEmpty) {
        setState(() {
          _recentlyAccessed = _modulList
              .take(3)
              .cast<Map<String, dynamic>>()
              .toList();
        });
      }
    }
  }

  // Method untuk menambah modul ke daftar terakhir diakses
  Future<void> _addToRecentlyAccessed(Map<String, dynamic> modulData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentlyAccessedString = prefs.getString(
        'recently_accessed_modules',
      );

      List<dynamic> recentlyAccessedIds = [];
      if (recentlyAccessedString != null) {
        recentlyAccessedIds =
            jsonDecode(recentlyAccessedString) as List<dynamic>;
      }

      final modulId = modulData['id'];

      // Hapus modul dari list jika sudah ada (untuk memindahkan ke posisi teratas)
      recentlyAccessedIds.remove(modulId);

      // Tambahkan modul ke posisi teratas
      recentlyAccessedIds.insert(0, modulId);

      // Batasi hanya 5 modul terakhir
      if (recentlyAccessedIds.length > 5) {
        recentlyAccessedIds = recentlyAccessedIds.take(5).toList();
      }

      // Simpan kembali ke SharedPreferences
      await prefs.setString(
        'recently_accessed_modules',
        jsonEncode(recentlyAccessedIds),
      );

      // Update UI
      _loadRecentlyAccessedModules();
    } catch (e) {
      print('Error adding to recently accessed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(title: 'Hai, $_userName'),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat beranda...')
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, AppColors.backgroundLight],
                  stops: [0.0, 0.3],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section with better styling
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowMedium,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apa yang ingin anda pelajari hari ini?',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.accent,
                                  AppColors.accentLight,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  // Navigate to chatbot page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChatbotPage(),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.smart_toy_outlined,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Asisten AI\nAda pertanyaan? Tanya kami kapan saja!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildRecentlyAccessedSection(),
                    const SizedBox(height: 24),
                    _buildModulByCategorySection(),
                    const SizedBox(height: 24),
                    // Quiz Section with enhanced styling
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowMedium,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.quiz,
                                      color: AppColors.accent,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Kuis',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizListPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Lihat Semua',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _isQuizLoading
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  child: const Center(
                                    child: Column(
                                      children: [
                                        CircularProgressIndicator(
                                          color: AppColors.accent,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Memuat daftar kuis...',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : _quizList.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundCard,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.quiz_outlined,
                                          size: 48,
                                          color: AppColors.textLight,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Belum ada kuis tersedia',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _quizList.length,
                                  separatorBuilder: (context, idx) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, idx) {
                                    final quiz = _quizList[idx];
                                    return _buildQuizCardDynamic(quiz);
                                  },
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Color _getCategoryColor(String? categoryName) {
    if (categoryName == null) return const Color(0xFF043461);

    switch (categoryName.toLowerCase()) {
      case 'desain produk':
        return const Color(0xFF2196F3); // Blue
      case 'fotografi':
        return const Color(0xFF9C27B0); // Purple
      case 'digital marketing':
        return const Color(0xFF4CAF50); // Green
      case 'branding':
        return const Color(0xFFFF9800); // Orange
      case 'pemasaran':
        return const Color(0xFFE91E63); // Pink
      case 'teknologi':
        return const Color(0xFF607D8B); // Blue Grey
      case 'bisnis':
        return const Color(0xFF795548); // Brown
      case 'keuangan':
        return const Color(0xFF009688); // Teal
      case 'pendidikan':
        return const Color(0xFF3F51B5); // Indigo
      case 'kesehatan':
        return const Color(0xFFF44336); // Red
      case 'olahraga':
        return const Color(0xFF8BC34A); // Light Green
      case 'seni':
        return const Color(0xFFE91E63); // Pink
      case 'musik':
        return const Color(0xFF9C27B0); // Purple
      case 'kuliner':
        return const Color(0xFFFF5722); // Deep Orange
      case 'travel':
        return const Color(0xFF00BCD4); // Cyan
      case 'fashion':
        return const Color(0xFFE91E63); // Pink
      case 'otomotif':
        return const Color(0xFF607D8B); // Blue Grey
      case 'pertanian':
        return const Color(0xFF8BC34A); // Light Green
      case 'konstruksi':
        return const Color(0xFFFF9800); // Orange
      case 'manufaktur':
        return const Color(0xFF795548); // Brown
      default:
        return const Color(0xFF043461); // Default dark blue
    }
  }

  Widget _buildModuleCard(
    String title,
    String subtitle,
    String imageAsset, {
    String? categoryName,
    Map<String, dynamic>? modulData,
  }) {
    String imageUrl = '';
    if (imageAsset.isNotEmpty) {
      if (imageAsset.startsWith('http')) {
        imageUrl = imageAsset;
      } else {
        imageUrl = 'http://10.42.223.86:8000/$imageAsset';
      }
    }

    final categoryColor = _getCategoryColor(categoryName);

    return GestureDetector(
      onTap: () {
        if (modulData != null) {
          final modul = ModulModel.fromJson(modulData);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModulDetailPage(modul: modul),
            ),
          ).then((_) {
            // Track akses modul
            _addToRecentlyAccessed(modulData);
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Container(
              height: 90, // Reduced height
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    categoryColor.withOpacity(0.9),
                    categoryColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  if (imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 90,
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.3),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: const Icon(
                              Icons.book,
                              color: Colors.white,
                              size: 28,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 90,
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.3),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: const Icon(
                        Icons.book,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  // Overlay gradient
                  Container(
                    width: double.infinity,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  // Category badge
                  if (categoryName != null)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          categoryName,
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 8, // Reduced font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(10), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12, // Reduced font size
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4), // Reduced spacing
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10, // Reduced font size
                      color: AppColors.textSecondary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8), // Reduced spacing
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Baca Modul',
                      style: TextStyle(
                        fontSize: 9, // Reduced font size
                        fontWeight: FontWeight.w600,
                        color: categoryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentModuleCard(
    String title,
    String imageAsset, {
    Map<String, dynamic>? modulData,
  }) {
    String imageUrl = '';
    if (imageAsset.isNotEmpty) {
      if (imageAsset.startsWith('http')) {
        imageUrl = imageAsset;
      } else {
        imageUrl = 'http://10.42.223.86:8000/$imageAsset';
      }
    }

    return GestureDetector(
      onTap: () {
        if (modulData != null) {
          final modul = ModulModel.fromJson(modulData);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModulDetailPage(modul: modul),
            ),
          ).then((_) {
            // Track akses modul
            _addToRecentlyAccessed(modulData);
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section dengan badge "RECENT"
            Stack(
              children: [
                Container(
                  height: 80, // Reduced height
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, AppColors.accentLight],
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.book,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: const Icon(
                            Icons.book,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      // Overlay gradient
                      Container(
                        width: double.infinity,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge "RECENT"
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'RECENT',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(8), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11, // Reduced font size
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4), // Reduced spacing
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 10, // Reduced icon size
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Terakhir diakses',
                        style: TextStyle(
                          fontSize: 8, // Reduced font size
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6), // Reduced spacing
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Baca Modul',
                      style: TextStyle(
                        fontSize: 8, // Reduced font size
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCardDynamic(Map<String, dynamic> quiz) {
    final String title = quiz['title'] ?? '-';
    final String description = quiz['description'] ?? '';
    final String? thumbnail = quiz['thumbnail'];
    String imageUrl = '';
    if (thumbnail != null && thumbnail.isNotEmpty) {
      if (thumbnail.startsWith('http')) {
        imageUrl = thumbnail;
      } else {
        imageUrl = 'http://10.42.223.86:8000/$thumbnail';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizDetailPage(quiz: quiz),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Quiz Image/Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, AppColors.accentLight],
                    ),
                  ),
                  child: imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: const Icon(
                                    Icons.quiz,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.quiz,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                // Quiz Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Mulai Kuis',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textLight,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyAccessedSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.history, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Terakhir Diakses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Modul yang baru-baru ini Anda akses',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _recentlyAccessed.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.history, color: AppColors.textLight, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada modul yang diakses',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  height: 180, // Increased height to accommodate content
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recentlyAccessed.length,
                    itemBuilder: (context, index) {
                      final modul = _recentlyAccessed[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 140,
                          child: _buildRecentModuleCard(
                            modul['judul_modul'] ?? '',
                            modul['foto'] ?? '',
                            modulData: modul,
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

  Widget _buildModulByCategorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.category, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Modul berdasarkan Kategori',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_kategoriList.isNotEmpty) ...[
            Container(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _kategoriList.length,
                itemBuilder: (context, index) {
                  final kategori = _kategoriList[index];
                  final isSelected = _selectedKategori == kategori['nama'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          setState(() {
                            _selectedKategori = isSelected
                                ? null
                                : kategori['nama'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.accent,
                                      AppColors.accentLight,
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : AppColors.borderLight,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.accent.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            kategori['nama'] ?? '',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
          _buildModulList(),
        ],
      ),
    );
  }

  Widget _buildModulList() {
    List<dynamic> filteredModul = _modulList;

    if (_selectedKategori != null) {
      filteredModul = _modulList.where((modul) {
        final categoryModul = modul['category_modul'];
        return categoryModul != null &&
            categoryModul['nama'] == _selectedKategori;
      }).toList();
    }

    if (filteredModul.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(
              _selectedKategori != null ? Icons.filter_list : Icons.book,
              color: AppColors.textLight,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _selectedKategori != null
                  ? 'Tidak ada modul untuk kategori "$_selectedKategori"'
                  : 'Belum ada modul tersedia',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75, // Adjusted aspect ratio to prevent overflow
      ),
      itemCount: filteredModul.length,
      itemBuilder: (context, index) {
        final modul = filteredModul[index];
        return _buildModuleCard(
          modul['judul_modul'] ?? '',
          modul['deskripsi_modul'] ?? '',
          modul['foto'] ?? '',
          categoryName: modul['category_modul']?['nama'],
          modulData: modul,
        );
      },
    );
  }
}
