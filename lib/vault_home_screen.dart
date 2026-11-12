import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'story_model.dart';
import 'video_model.dart';
import 'story_detail_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'calculator_screen.dart';
import 'local_vault_screen.dart';
import 'ad_banner.dart';
import 'ad_native.dart';

class VaultHomeScreen extends StatefulWidget {
  const VaultHomeScreen({super.key});

  @override
  State<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends State<VaultHomeScreen> {
  int _tab = 0;
  bool _syncing = false;
  String? _error;
  List<StoryModel> _stories = [];
  List<VideoModel> _videos = [];
  List<dynamic> _homeFeed = [];

  @override
  void initState() {
    super.initState();
    _sync();
  }

  DateTime _storyDate(StoryModel s) => s.createdAt ?? DateTime(2000);
  DateTime _videoDate(VideoModel v) => v.uploadedAt;

  DateTime _itemDate(dynamic item) {
    if (item is StoryModel) return _storyDate(item);
    if (item is VideoModel) return _videoDate(item);
    return DateTime(2000);
  }

  List<T> _sortShuffle<T>(List<T> list, DateTime Function(T) dateOf) {
    final copy = List<T>.from(list);
    copy.sort((a, b) => dateOf(b).compareTo(dateOf(a)));
    if (copy.length <= 1) return copy;
    final today = DateTime.now();
    final recent = <T>[];
    final older = <T>[];
    for (final item in copy) {
      if (today.difference(dateOf(item)).inDays <= 1) {
        recent.add(item);
      } else {
        older.add(item);
      }
    }
    recent.shuffle(Random());
    older.shuffle(Random());
    return [...recent, ...older];
  }

  Future<void> _sync() async {
    if (_syncing) return;
    setState(() {
      _syncing = true;
      _error = null;
    });
    try {
      final stories = await ApiService.fetchStories();
      final videos = await ApiService.fetchVideos();
      final s = _sortShuffle(stories, _storyDate);
      final v = _sortShuffle(videos, _videoDate);
      final mixed = _sortShuffle<dynamic>([...s, ...v], _itemDate);
      if (!mounted) return;
      setState(() {
        _stories = s;
        _videos = v;
        _homeFeed = mixed;
        if (s.isEmpty && v.isEmpty) {
          _error = 'ডেটা আসেনি। Sync চাপুন।';
        }
      });
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _lock() async {
    await StorageService.lockVault();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CalculatorScreen()),
    );
  }

  Future<void> _openVideo(VideoModel video) async {
    final uri = Uri.parse(video.playUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ব্রাউজার খোলা যায়নি')),
      );
    }
  }

  void _openStory(StoryModel story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StoryDetailScreen(story: story, allStories: _stories),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('Private Vault',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF121212),
        actions: [
          IconButton(
            icon: _syncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.sync),
            onPressed: _syncing ? null : _sync,
          ),
          IconButton(
            icon: const Icon(Icons.folder_special_outlined),
            tooltip: 'লোকাল ভল্ট',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LocalVaultScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SearchScreen(stories: _stories, videos: _videos),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          IconButton(icon: const Icon(Icons.lock_outline), onPressed: _lock),
        ],
      ),
      body: Column(
        children: [
          const AdBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _sync,
              color: const Color(0xFF1E88E5),
              child: _buildBody(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF121212),
        indicatorColor: const Color(0xFF1E88E5).withOpacity(0.25),
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'গল্প',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: 'ভিডিও',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'লোকাল',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_tab == 3) {
      return const LocalVaultScreen(embedded: true);
    }
    if (_tab == 1) return _list(_stories, storiesOnly: true);
    if (_tab == 2) return _list(_videos, videosOnly: true);
    return _list(_homeFeed);
  }

  Widget _empty(String msg) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            children: [
              if (_syncing)
                const CircularProgressIndicator(color: Color(0xFF1E88E5))
              else
                Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[700]),
              const SizedBox(height: 16),
              Text(
                _syncing ? 'লোড হচ্ছে...' : msg,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _list(List items, {bool storiesOnly = false, bool videosOnly = false}) {
    if (items.isEmpty) {
      return _empty(_error ?? 'কিছু নেই\nSync চাপুন');
    }
    final n = items.length;
    final itemCount = n + (n ~/ 2); // প্রতি ২ আইটেমে ১ অ্যাড
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: itemCount,
      itemBuilder: (_, i) {
        if ((i + 1) % 3 == 0) {
          return const AdNative(height: 250);
        }
        final di = i - (i ~/ 3);
        if (di < 0 || di >= n) return const SizedBox.shrink();
        final item = items[di];
        if (item is StoryModel) return _storyCard(item);
        if (item is VideoModel) return _videoCard(item);
        return const SizedBox.shrink();
      },
    );
  }

  Widget _storyCard(StoryModel story) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (story.hasImage)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: story.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      Container(height: 180, color: Colors.grey[900]),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Text(
              story.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: SizedBox(
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332),
                  foregroundColor: const Color(0xFF95D5B2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                onPressed: () => _openStory(story),
                child: const Text('সম্পূর্ণ পড়ুন'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoCard(VideoModel video) {
    return GestureDetector(
      onTap: () => _openVideo(video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    video.thumbnail.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: video.thumbnail,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                Container(color: Colors.grey[900]),
                          )
                        : Container(color: Colors.grey[900]),
                    const Center(
                      child: Icon(Icons.open_in_browser,
                          color: Colors.white70, size: 48),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
