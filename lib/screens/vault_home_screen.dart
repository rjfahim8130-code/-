import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/video_open_service.dart';
import '../models/story_model.dart';
import '../models/video_model.dart';
import '../widgets/ad_top_native.dart';
import '../widgets/ad_native.dart';
import '../widgets/ad_banner_medium.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => AdPopunderHost.trigger());
  }

  // ───────────────────────── তারিখ / সাজানো ─────────────────────────

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

  List<T> _sortByDateThenShuffle<T>(List<T> list, DateTime Function(T) dateOf) {
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

  // ───────────────────────── Sync ─────────────────────────

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
      } catch (_) {}
      try {
        videos = await ApiService.fetchVideos();
      } catch (_) {}

      stories = _sortByDateThenShuffle(stories, _storyDate);
      videos = _sortByDateThenShuffle(videos, _videoDate);
      final mixed = _sortByDateThenShuffle<dynamic>(
        [...stories, ...videos],
        _itemDate,
      );

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

  // ───────────────────────── Navigation actions ─────────────────────────

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

  /// ✅ আপডেট: tryOpenExternal — ব্রাউজার সফলভাবে খুললেই কেবল কোটা কাটবে।
  ///    ব্যর্থ open-এ বা লিমিট শেষে in-app player-এ ফলব্যাক।
  Future<void> _openVideo(VideoModel video) async {
    await AdPopunderHost.trigger();

    final openedExternally = await VideoOpenService.tryOpenExternal(() async {
      final uri = Uri.parse(video.playUrl);
      if (!await canLaunchUrl(uri)) return false;
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    });

    if (openedExternally) return;

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(video: video, allVideos: _videos),
      ),
    );
  }

  // ───────────────────────── Ad slot pattern ─────────────────────────
  // প্যাটার্ন: data, data, ad, data, data, ad, ...
  //  - প্রতি ৩য় স্লটে অ্যাড
  //  - কিন্তু শেষ স্লটে অ্যাড দেব না (ডেটা ছাড়া ট্রেইলিং অ্যাড এড়াতে)

  static const _adEvery = 3; // প্রতি ৩য় স্লটে অ্যাড

  /// মোট কতটি ডেটা স্লট + কতটি অ্যাড স্লট
  /// শেষ স্লট ad না হলে ট্রেইলিং-এড এড়ানো যায়।
  ({int total, int dataCount, int adCount}) _layout(int n) {
    if (n == 0) return (total: 0, dataCount: 0, adCount: 0);
    // প্রতি ৩টির মধ্যে ২টি ডেটা, ১টি অ্যাড (স্লট-ভিত্তিক)
    // তবে শেষের ad বাদ দিয়ে হিসাব করি: n ডেটার জন্য সর্বোচ্চ n ~/ 2 অ্যাড
    final adCount = n ~/ 2;
    return (total: n + adCount, dataCount: n, adCount: adCount);
  }

  Widget _adAt(int adIndex) {
    // even adIndex → Native 3:1, odd → 300x250
    if (adIndex.isEven) return const AdNative(height: 130);
    return const AdBannerMedium();
  }

  // ───────────────────────── Build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          appBar: AppBar(
            title: const Text(
              'Private Vault',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF121212),
            elevation: 0,
            actions: [
              IconButton(
                icon: _syncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
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
                      builder: (_) =>
                          SearchScreen(stories: _stories, videos: _videos),
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
              IconButton(
                icon: const Icon(Icons.lock_outline),
                onPressed: _lock,
              ),
            ],
          ),
          body: Column(
            children: [
              const AdTopNative(),
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
    if (_tab == 1) return _listBody(_stories);
    if (_tab == 2) return _listBody(_videos);
    return _listBody(_homeFeed);
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
            ],
          ),
        ),
      ],
    );
  }

  /// লেআউট: data, data, ad, data, data, ad, ... data (কখনোই ad দিয়ে শেষ হবে না)
  /// প্রতি [_adEvery] স্লটে একবার অ্যাড, কিন্তু শেষ স্লট অ্যাড নয়।
  Widget _listBody(List items) {
    if (items.isEmpty) {
      return _empty(_error ?? 'কিছু নেই\nSync চাপুন');
    }
    final n = items.length;
    final layout = _layout(n);

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: layout.total,
      itemBuilder: (_, i) {
        // স্লট প্যাটার্ন: প্রতি ৩য় স্লট (i=2, 5, 8, ...) অ্যাড
        final isAdSlot = (i + 1) % _adEvery == 0;

        if (isAdSlot) {
          final adIndex = (i + 1) ~/ _adEvery - 1;
          // নিরাপত্তা: adIndex কখনো layout.adCount অতিক্রম করবে না
          if (adIndex >= layout.adCount) return const SizedBox.shrink();
          return _adAt(adIndex);
        }

        // ডেটা ইনডেক্স: i - (কতটি অ্যাড ইতিমধ্যে পেরিয়েছি)
        final adsBefore = (i + 1) ~/ _adEvery; // i-এর আগে কতগুলো ad slot
        final di = i - adsBefore;
        if (di < 0 || di >= n) return const SizedBox.shrink();

        final item = items[di];
        if (item is StoryModel) return _storyCard(item);
        if (item is VideoModel) return _videoCard(item);
        return const SizedBox.shrink();
      },
    );
  }

  // ───────────────────────── Cards ─────────────────────────

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
                            errorWidget: (_, __, ___) =>
                                Container(color: Colors.grey[900]),
                          )
                        : Container(color: Colors.grey[900]),
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white70,
                        size: 56,
                      ),
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
