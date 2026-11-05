import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/story_model.dart';
import '../models/video_model.dart';
import '../widgets/ad_banner.dart';
import 'story_detail_screen.dart';
import 'video_player_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'calculator_screen.dart';

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

  Future<void> _sync() async {
    if (_syncing) return;
    setState(() {
      _syncing = true;
      _error = null;
    });
    try {
      // আলাদা আলাদা try — একটা ফেল করলে অন্যটা আসুক
      List<StoryModel> stories = [];
      List<VideoModel> videos = [];
      try {
        stories = await ApiService.fetchStories();
      } catch (e) {
        print('stories: $e');
      }
      try {
        videos = await ApiService.fetchVideos();
      } catch (e) {
        print('videos: $e');
      }

      final mixed = <dynamic>[...stories, ...videos];
      mixed.shuffle(Random());

      if (!mounted) return;
      setState(() {
        _stories = stories;
        _videos = videos;
        _homeFeed = mixed;
        if (stories.isEmpty && videos.isEmpty) {
          _error = 'ডেটা আসেনি। Sync আবার চাপুন।';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('Private Vault', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF121212),
        actions: [
          IconButton(
            icon: _syncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.sync),
            onPressed: _syncing ? null : _sync,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchScreen(stories: _stories, videos: _videos),
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
          // ===== টপ ব্যানার (টেস্ট) =====
          const AdBanner(height: 50),
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
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_tab == 1) return _storiesBody();
    if (_tab == 2) return _videosBody();
    return _homeBody();
  }

  Widget _empty(String msg) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
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
              if (!_syncing) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _sync,
                  icon: const Icon(Icons.sync),
                  label: const Text('আবার Sync'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _homeBody() {
    if (_homeFeed.isEmpty) {
      return _empty(_error ?? 'হোমে এখনো কিছু নেই\nSync চাপুন');
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _homeFeed.length,
      itemBuilder: (_, i) {
        final item = _homeFeed[i];
        if (item is StoryModel) return _storyCard(item);
        if (item is VideoModel) return _videoCardWide(item);
        return const SizedBox.shrink();
      },
    );
  }

  Widget _storiesBody() {
    if (_stories.isEmpty) return _empty('কোনো গল্প নেই');
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _stories.length,
      itemBuilder: (_, i) => _storyCard(_stories[i]),
    );
  }

  Widget _videosBody() {
    if (_videos.isEmpty) return _empty('কোনো ভিডিও নেই');
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _videos.length,
      itemBuilder: (_, i) => _videoCardGrid(_videos[i]),
    );
  }

  /// গল্প কার্ড (স্ক্রিনশট স্টাইল)
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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                if (story.code.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'কোড: ${story.code}',
                      style: const TextStyle(fontSize: 11, color: Colors.lightBlueAccent),
                    ),
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4332),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    story.episodeLabel,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF95D5B2)),
                  ),
                ),
              ],
            ),
          ),
          if (story.hasImage)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: story.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(height: 200, color: Colors.grey[900]),
                  errorWidget: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[900],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Text(
              story.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              story.cardSubtitle,
              style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332),
                  foregroundColor: const Color(0xFF95D5B2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoryDetailScreen(
                      story: story,
                      allStories: _stories,
                    ),
                  ),
                ),
                child: const Text('সম্পূর্ণ পড়ুন', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoCardWide(VideoModel video) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(video: video, allVideos: _videos),
        ),
      ),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    video.thumbnail.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: video.thumbnail,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
                          )
                        : Container(color: Colors.grey[900]),
                    const Center(
                      child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 56),
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
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _videoCardGrid(VideoModel video) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(video: video, allVideos: _videos),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    video.thumbnail.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: video.thumbnail,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
                          )
                        : Container(color: Colors.grey[900]),
                    const Center(
                      child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 40),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
