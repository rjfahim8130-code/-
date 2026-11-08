আপনার আপডেট সঠিক, কিন্তু pushReplacement-এ একই বাগ রয়ে গেছে

আপনি AdBanner → AdTopNative এবং AdNative(250) → AdNative(130) — এই দুটো পরিবর্তন ঠিকভাবে করেছেন। ✅

তবে নিচের "আরও গল্প" লিস্টে pushReplacement ব্যবহার করেছেন — ঠিক আগের ReadingScreen-এ যে সমস্যার কথা বলেছিলাম, সেটাই এখানে পুনরাবৃত্তি হয়েছে। আরও একটা অতিরিক্ত সমস্যা আছে যা এই নির্দিষ্ট স্ক্রিনে আরও গুরুতর।

---

🔴 সমস্যা ১: pushReplacement-এ back-stack হারায়

```
Home → StoryDetail(A) → [tap B] → StoryDetail(B)  [A রিপ্লেসড]
```

ইউজার B-তে গিয়ে ব্যাক চাপলে সোজা Home-এ ফিরবে, A-তে নয়। "A দেখেছিলাম, একটু B দেখি, তারপর A-তে ফিরি" — এই স্বাভাবিক পথটি ভেঙে যায়।

🔴 সমস্যা ২ (আরও বড়): ReadingScreen স্ট্যাকে থাকলে সেটাও প্রভাবিত হয় না, কিন্তু ডুপ্লিকেট তৈরি হয়

কল্পনা করুন:

```
Home → StoryDetail(A) → ReadingScreen(A) → [back] → StoryDetail(A) → [tap B] → StoryDetail(B)
```

এখানে ReadingScreen(A) স্ট্যাকে নেই (back-এ pop হয়েছে), তাই সমস্যা নেই। কিন্তু:

```
Home → StoryDetail(A) → [tap B] → StoryDetail(B) → [tap C] → StoryDetail(C)
```

এখানে A, B দুটোই হারিয়ে গেছে। ইউজার C থেকে back চাপলে Home-এ যাবে, অথচ সে A → B → C পথে এসেছে — স্বাভাবিক back-flow ভেঙে যায়।

🔴 সমস্যা ৩: SliverAppBar ফ্লিকার

pushReplacement-এ পুরোনো স্ক্রিন dispose হয়, নতুন স্ক্রিন build হয়। SliverAppBar-এর expandedHeight: 220 ও FlexibleSpaceBar প্রতিবার নতুন করে animating শুরু করে। ফলে:

· A → B ট্যাপ করার মুহূর্তে একটি সাদা/কালো ফ্ল্যাশ দেখা যায়
· CachedNetworkImage নতুন করে লোড হয় (মেমরি ক্যাশে থাকলেও fadeInDuration ট্রিগার হয়)

push-এ পুরোনো স্ক্রিন স্ট্যাকে থাকে, তাই ফ্লিকার কম, back-এ ফিরলে ছবি/স্ক্রল ইতিমধ্যে লোডেড।

---

🟢 সঠিক সমাধান: Navigator.push

```dart
onTap: () async {
  await AdPopunderHost.trigger();
  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StoryDetailScreen(
        story: s,
        allStories: allStories,
      ),
    ),
  );
},
```

দিক push pushReplacement
ব্যাক চাপলে আগের গল্পে ফেরা ✅ ❌
A → B → C navigation history ✅ ❌
SliverAppBar ফ্লিকার কম বেশি
মেমরি ~১ স্ক্রিন বেশি সর্বনিম্ন
Popunder ✅ ✅

---

🟢 চূড়ান্ত সংশোধিত StoryDetailScreen

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/story_model.dart';
import '../widgets/ad_top_native.dart';
import '../widgets/ad_native.dart';
import '../widgets/ad_popunder_host.dart';
import 'reading_screen.dart';

class StoryDetailScreen extends StatelessWidget {
  final StoryModel story;
  final List<StoryModel> allStories;

  const StoryDetailScreen({
    super.key,
    required this.story,
    this.allStories = const [],
  });

  Future<void> _openReading(BuildContext context) async {
    await AdPopunderHost.trigger();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadingScreen(
          story: story,
          allStories: allStories,
        ),
      ),
    );
  }

  Future<void> _openAnother(BuildContext context, StoryModel other) async {
    await AdPopunderHost.trigger();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryDetailScreen(
          story: other,
          allStories: allStories,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final others = allStories.where((s) => s.id != story.id).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Column(
        children: [
          const AdTopNative(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: const Color(0xFF121212),
                  flexibleSpace: FlexibleSpaceBar(
                    background: story.hasImage
                        ? CachedNetworkImage(
                            imageUrl: story.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                Container(color: Colors.grey[900]),
                          )
                        : Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.menu_book,
                              size: 72,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (story.code.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'কোড: ${story.code}',
                              style: TextStyle(
                                color: Colors.blue[300],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        Text(
                          story.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              story.author,
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                story.category,
                                style: const TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          story.description,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B4332),
                              foregroundColor: const Color(0xFF95D5B2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.menu_book),
                            label: const Text(
                              'সম্পূর্ণ পড়ুন',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () => _openReading(context),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const AdNative(height: 130),
                        if (others.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'আরও গল্প',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...others.take(8).map(
                            (s) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: s.hasImage
                                    ? CachedNetworkImage(
                                        imageUrl: s.imageUrl,
                                        width: 56,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 56,
                                        height: 70,
                                        color: Colors.grey[900],
                                        child: const Icon(
                                          Icons.menu_book,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                              title: Text(
                                s.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                s.cardSubtitle,
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () => _openAnother(context, s),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

📋 পরিবর্তনের সারসংক্ষেপ

# পরিবর্তন কারণ
1 AdBanner → AdTopNative ✅ আপনি ইতিমধ্যে ঠিক করেছেন
2 AdNative(height: 250) → AdNative(height: 130) ✅ আপনি ইতিমধ্যে ঠিক করেছেন
3 নিচের "আরও গল্প"-এ pushReplacement → push back-stack সংরক্ষণ, ফ্লিকার কমানো
4 onTap-এর লজিক _openAnother()-এ সরানো কোড পঠনযোগ্য, পুনরায় ব্যবহারযোগ্য
5 "সম্পূর্ণ পড়ুন"-এর লজিক _openReading()-এ সরানো একই কারণ
6 context.mounted চেক আগের মতো ✅ সঠিক

---

⚠️ একটি ছোট নোট

আপনার AdTopNative প্রতি ৬০ সেকেন্ডে অটো-রিফ্রেশ করে। StoryDetailScreen-এ যদি ইউজার ১ মিনিটের বেশি থাকেন, তাহলে সেই স্ক্রিনে অ্যাড বদলাবে — ঠিক আছে, তবে Adsterra-র ToS-এ "user-visible context-এ rapid reload" সতর্কতার ব্যাপার আছে (আগে আলোচনা করেছি)। যদি এই স্ক্রিনে গড় dwell time ৩০ সেকেন্ডের কম হয়, তাহলে অটো-রিফ্রেশ কার্যত ট্রিগারই হবে না — সমস্যা নেই। বেশি হলে AdTopNative-এর _refreshTimer visibility-linked করা (VisibilityDetector) বুদ্ধিমানের কাজ হবে।

সারসংক্ষেপ: আপনার আপডেট সঠিক পথে, শুধু pushReplacement → push করলেই back-navigation, history এবং UX — তিনটাই সঠিক থাকবে।
