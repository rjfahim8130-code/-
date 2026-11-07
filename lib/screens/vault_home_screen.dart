import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/story_model.dart';
import '../models/video_model.dart';
import '../widgets/ad_banner.dart';
import '../widgets/ad_native.dart';
import '../widgets/ad_popunder_host.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdPopunderHost.trigger();
    });
  }

  DateTime _storyDate(StoryModel s) => s.createdAt ?? DateTime(2000);

  DateTime _videoDate(VideoModel v) {
    if (v.uploaded.isEmpty) return DateTime(2000);
    return DateTime.tryParse(v.uploaded) ?? DateTime(2000);
  }

  DateTime _itemDate(dynamic item) {
    if (item is StoryModel) return _storyDate(item);
    if (item is VideoModel) return _videoDate(item);
    return DateTime(2000);
  }

  /// নতুন আগে; একই দিনের মধ্যে হালকা শাফল
  List<T> _sortByDateThenShuffle<T>(List<T> list, DateTime Function(T) dateOf) {
    final copy = List<T>.from(list);
    copy.sort((a, b) => dateOf(b).compareTo(dateOf(a)));
    if (copy.length <= 1) return copy;

    final today = DateTime.now();
    final recent = <T>[];
    final older = <T>[];
    for (final item in copy) {
      final d = dateOf(item);
      final isNew = today.difference(d).inDays <= 1;
      if (isNew) {
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
      List<StoryModel> stories = [];
      List<VideoModel> videos = [];
      try {
        stories = await ApiService.fetchStories();
      } catch (e) {
        print('stories error: $e');
      }
      try {
        videos = await ApiService.fetchVideos();
      } catch (e) {
        print('videos error: $e');
      }

      stories = _sortByDateThenShuffle(stories, _storyDate);
      videos = _sortByDateThenShuffle(videos, _videoDate);

      final mixed = <dynamic>[...stories, ...videos];
      final sortedMixed = _sortByDateThenShuffle(mixed, _itemDate);

      if (!mounted) return;
      setState(() {
        _stories = stories;
        _videos = videos;
        _homeFeed = sortedMixed;
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

  Future<void> _openStory(StoryModel story) async {
    await AdPopunderHost.trigger();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryDetailScreen(story: story, allStories: _stories),
      ),
    );
  }

  Future<void> _openVideo(VideoModel video) async {
    await AdPopunderHost.trigger();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(video: video, allVideos: _videos),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          appBar: AppBar(
            title: const Text('Private Vault', style: TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFF121212),
            elevation: 0,
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
                onPressed: () async {
                  await AdPopunderHost.trigger();
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchScreen(stories: _stories, videos: _videos),
                    ),
                  );
                },
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
            onDestinationSelected: (i) async {
              await AdPopunderHost.trigger();
              if (mounted) setState(() => _tab = i);
            },
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
        ),
        AdPopunderHost(key: AdPopunderHost.hostKey),
      ],
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
                  icon: const Icon(Icons.sync, color: Color(0xFF1E88E5)),
                  label: const Text('আবার Sync', style: TextStyle(color: Color(0xFF1E88E5))),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// প্রতি ২টা কার্ডের পর ১টা Native → স্লট: data, data, ad, data, data, ad...
  int _countWithAds(int n) => n + (n ~/ 2);

  int _dataIndex(int i) => i - (i ~/ 3);

  bool _isAdSlot(int i) => (i + 1) % 3 == 0;

  Widget _homeBody() {
    if (_homeFeed.isEmpty) {
      return _empty(_error ?? 'হোমে এখনো কিছু নেই\nSync চাপুন');
    }
    final n = _homeFeed.length;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _countWithAds(n),
      itemBuilder: (_, i) {
        if (_isAdSlot(i)) return const AdNative(height: 250);
        final di = _dataIndex(i);
        if (di < 0 || di >= n) return const SizedBox.shrink();
        final item = _homeFeed[di];
        if (item is StoryModel) return _storyCard(item);
        if (item is VideoModel) return _videoCardWide(item);
        return const SizedBox.shrink();
      },
    );
  }

  Widget _storiesBody() {
    if (_stories.isEmpty) return _empty('কোনো গল্প নেই');
    final n = _stories.length;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _countWithAds(n),
      itemBuilder: (_, i) {
        if (_isAdSlot(i)) return const AdNative(height: 250);
        final di = _dataIndex(i);
        if (di < 0 || di >= n) return const SizedBox.shrink();
        return _storyCard(_stories[di]);
      },
    );
  }

  Widget _videosBody() {
    if (_videos.isEmpty) return _empty('কোনো ভিডিও নেই');
    final n = _videos.length;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _countWithAds(n),
      itemBuilder: (_, i) {
        if (_isAdSlot(i)) return const AdNative(height: 250);
        final di = _dataIndex(i);
        if (di < 0 || di >= n) return const SizedBox.shrink();
        return _videoCardWide(_videos[di]);
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
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
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
                onPressed: () => _openStory(story),
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
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
