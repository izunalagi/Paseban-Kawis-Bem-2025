import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_widget.dart';
import '../../services/quiz_service.dart';
import '../../services/modul_service.dart';

class PeringkatPage extends StatefulWidget {
  const PeringkatPage({super.key});

  @override
  State<PeringkatPage> createState() => _PeringkatPageState();
}

class _PeringkatPageState extends State<PeringkatPage> {
  int? selectedQuizId;
  String selectedQuizTitle = 'Pilih Kuis';
  List<dynamic> leaderboard = [];
  List<dynamic> quizList = [];
  bool _isLoading = true;
  bool _isLoadingQuiz = true;
  bool _isDropdownOpen = false;
  String? _error;

  // Helper function to get full photo URL
  String _getFullPhotoUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return '';

    // If already a full URL, return as is
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return photoPath;
    }

    // If starts with storage/, add base URL
    if (photoPath.startsWith('storage/')) {
      return '${ModulService.baseUrl}/$photoPath';
    }

    // Otherwise, assume it's a relative path and add base URL
    return '${ModulService.baseUrl}/$photoPath';
  }

  // Helper function to truncate user name
  String _truncateUserName(String? name, int maxLength) {
    if (name == null || name.isEmpty) return '-';
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength)}...';
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true; // Set loading to true immediately
    _fetchQuizList();
  }

  Future<void> _fetchQuizList() async {
    setState(() {
      _isLoadingQuiz = true;
      _isLoading = true; // Keep loading true while fetching quiz list
    });
    try {
      print('Fetching quiz list...');
      quizList = await QuizService().fetchQuizList();
      print('Quiz list fetched: ${quizList.length} items');
      print('Quiz list data: $quizList');

      if (quizList.isNotEmpty) {
        selectedQuizId = quizList[0]['id'] as int;
        selectedQuizTitle = quizList[0]['title'] as String;
        print('Selected quiz: ID=$selectedQuizId, Title=$selectedQuizTitle');
        _fetchLeaderboard();
      } else {
        print('Quiz list is empty');
        setState(() {
          _isLoading = false;
          _isLoadingQuiz = false;
        });
      }
    } catch (e) {
      print('Error fetching quiz list: $e');
      _error = 'Gagal mengambil data kuis: $e';
      setState(() {
        _isLoading = false;
        _isLoadingQuiz = false;
      });
    }
  }

  Future<void> _fetchLeaderboard() async {
    if (selectedQuizId == null) {
      print('selectedQuizId is null, cannot fetch leaderboard');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      print('Fetching leaderboard for quiz ID: $selectedQuizId');
      leaderboard = await QuizService().fetchLeaderboard(
        quizId: selectedQuizId,
      );
      print('Leaderboard fetched: ${leaderboard.length} items');
      print('Leaderboard data: $leaderboard');
    } catch (e) {
      print('Error fetching leaderboard: $e');
      _error = 'Gagal mengambil data peringkat: $e';
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Peringkat'),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat peringkat...')
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
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                child: Center(
                  child: Container(
                    width:
                        500, // max width for web/tablet, will shrink on mobile
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.97),
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
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isDropdownOpen = !_isDropdownOpen;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary.withOpacity(0.05),
                                      AppColors.accent.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _isDropdownOpen
                                        ? AppColors.primary.withOpacity(0.4)
                                        : AppColors.primary.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(
                                        0.08,
                                      ),
                                      blurRadius: _isDropdownOpen ? 12 : 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      selectedQuizTitle == 'Pilih Kuis'
                                          ? Icons.quiz_outlined
                                          : Icons.quiz,
                                      color: selectedQuizTitle == 'Pilih Kuis'
                                          ? AppColors.primary.withOpacity(0.7)
                                          : AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        selectedQuizTitle,
                                        style: TextStyle(
                                          color:
                                              selectedQuizTitle == 'Pilih Kuis'
                                              ? AppColors.textSecondary
                                              : AppColors.primary,
                                          fontSize: 16,
                                          fontWeight:
                                              selectedQuizTitle == 'Pilih Kuis'
                                              ? FontWeight.w500
                                              : FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: _isDropdownOpen ? 0.5 : 0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              height: _isDropdownOpen
                                  ? (quizList.length * 56.0).clamp(0, 200)
                                  : 0,
                              child: Container(
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.15),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowMedium.withOpacity(
                                        0.15,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: quizList.length,
                                    itemBuilder: (context, index) {
                                      final quiz = quizList[index];
                                      final isSelected =
                                          selectedQuizTitle == quiz['title'];
                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedQuizTitle =
                                                  quiz['title'] as String;
                                              selectedQuizId =
                                                  quiz['id'] as int;
                                              _isDropdownOpen = false;
                                              _fetchLeaderboard();
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primary
                                                        .withOpacity(0.08)
                                                  : Colors.transparent,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? AppColors.primary
                                                        : AppColors.accent,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    quiz['title'] as String,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w600
                                                          : FontWeight.w500,
                                                      color: isSelected
                                                          ? AppColors.primary
                                                          : AppColors
                                                                .textPrimary,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Icon(
                                                    Icons.check_circle_rounded,
                                                    color: AppColors.primary,
                                                    size: 18,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_error != null)
                          Center(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                        else if (leaderboard.isEmpty)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.emoji_events,
                                  color: AppColors.textLight,
                                  size: 48,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Belum ada data peringkat',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          RefreshIndicator(
                            onRefresh: _fetchLeaderboard,
                            child: ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              children: [
                                _buildTopThree(),
                                const SizedBox(height: 16),
                                ..._buildLeaderboardList(),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTopThree() {
    if (leaderboard.isEmpty) return const SizedBox();
    final top = leaderboard.take(3).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(top.length, (i) {
        final user = top[i];
        final color = i == 0
            ? AppColors.accent
            : (i == 1 ? Colors.grey : Colors.brown[400]!);
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Stack(
                children: [
                  // User profile photo
                  Container(
                    width: i == 0 ? 70 : (i == 1 ? 65 : 60),
                    height: i == 0 ? 70 : (i == 1 ? 65 : 60),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: i == 0 ? 35 : (i == 1 ? 32 : 30),
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      backgroundImage:
                          user['user_photo'] != null &&
                              user['user_photo'].isNotEmpty
                          ? NetworkImage(_getFullPhotoUrl(user['user_photo']))
                          : null,
                      child:
                          user['user_photo'] == null ||
                              user['user_photo'].isEmpty
                          ? Text(
                              (user['user_name'] ?? '-').isNotEmpty
                                  ? user['user_name'][0]
                                  : '-',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: i == 0 ? 24 : (i == 1 ? 22 : 20),
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  // Ranking indicator (trophy/medal)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          i == 0 ? Icons.emoji_events : Icons.star,
                          color: Colors.white,
                          size: i == 0 ? 14 : (i == 1 ? 13 : 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: i == 0 ? 80 : (i == 1 ? 75 : 70),
                child: Text(
                  _truncateUserName(user['user_name'], i == 0 ? 10 : 8),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: i == 0 ? 16 : 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Skor: ${user['score'] ?? 0}/${user['total_questions'] ?? 0}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${double.tryParse(user['percentage'].toString())?.toStringAsFixed(0) ?? '0'}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildLeaderboardList() {
    final items = leaderboard.length > 3 ? leaderboard.sublist(3) : [];
    return List.generate(items.length, (i) {
      final user = items[i];
      final rank = i + 4;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ranking number in circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accent.withOpacity(0.7),
                    AppColors.accent.withOpacity(0.2),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // User profile photo
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              backgroundImage:
                  user['user_photo'] != null && user['user_photo'].isNotEmpty
                  ? NetworkImage(_getFullPhotoUrl(user['user_photo']))
                  : null,
              child: user['user_photo'] == null || user['user_photo'].isEmpty
                  ? Text(
                      (user['user_name'] ?? '-').isNotEmpty
                          ? user['user_name'][0]
                          : '-',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _truncateUserName(user['user_name'], 15),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Skor: ${user['score'] ?? 0}/${user['total_questions'] ?? 0}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${user['percentage'] ?? 0}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
