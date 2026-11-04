import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/story_model.dart';
import '../models/video_model.dart';
import 'story_list_screen.dart';
import 'video_list_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'calculator_screen.dart';

class VaultHomeScreen extends StatefulWidget {
  const VaultHomeScreen({super.key});

  @override
  State<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends State<VaultHomeScreen> {
  bool _isSyncing = false;
  List<StoryModel> _stories = [];
  List<VideoModel> _videos = [];
  String _status = '';

  @override
  void initState() {
    super.initState();
    _syncData(); // অ্যাপ খুললেই অটো সিঙ্ক
  }

  Future<void> _syncData() async {
    if (_isSyncing) return;
    setState(() {
      _isSyncing = true;
      _status = 'সিঙ্ক হচ্ছে...';
    });

    try {
      final stories = await ApiService.fetchStories();
      final videos = await ApiService.fetchVideos();

      setState(() {
        _stories = stories;
        _videos = videos;
        _status = 'সিঙ্ক সম্পন্ন • গল্প: ${stories.length} • ভিডিও: ${videos.length}';
      });
    } catch (e) {
      setState(() => _status = 'সিঙ্ক ব্যর্থ: $e');
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  Future<void> _lockAndExit() async {
    await StorageService.lockVault();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CalculatorScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('Private Vault', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF121212),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.sync),
            tooltip: 'Sync Data',
            onPressed: _isSyncing ? null : _syncData,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(stories: _stories, videos: _videos))),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Lock Vault',
            onPressed: _lockAndExit,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _syncData,
        color: const Color(0xFF1E88E5),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status
            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.blue[300]),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_status, style: TextStyle(color: Colors.grey[400], fontSize: 13))),
                  ],
                ),
              ),

            // Stories Card
            _buildCategoryCard(
              icon: Icons.menu_book_rounded,
              title: 'গল্প ও উপন্যাস',
              subtitle: '${_stories.length} টি আইটেম',
              color: const Color(0xFF4CAF50),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StoryListScreen(stories: _stories)),
              ),
            ),
            const SizedBox(height: 14),

            // Videos Card
            _buildCategoryCard(
              icon: Icons.play_circle_filled_rounded,
              title: 'ভিডিও',
              subtitle: '${_videos.length} টি ভিডিও',
              color: const Color(0xFFE91E63),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VideoListScreen(videos: _videos)),
              ),
            ),
            const SizedBox(height: 24),

            // Quick tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('টিপস', style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    '• উপরের Sync বাটন বা নিচে টেনে রিফ্রেশ করলে নতুন তথ্য আসবে।\n'
                    '• একবার বিল্ড করলেই হবে — ডেটা সবসময় API থেকে লাইভ আপডেট হয়।\n'
                    '• লক বাটন দিয়ে আবার ক্যালকুলেটর মোডে ফিরে যান।',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }
}
