import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VibeApp()));
}

class VibeApp extends StatelessWidget {
  const VibeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0B0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const VibeHomePage(),
    );
  }
}

class VibeHomePage extends StatefulWidget {
  const VibeHomePage({super.key});

  @override
  State<VibeHomePage> createState() => _VibeHomePageState();
}

class _VibeHomePageState extends State<VibeHomePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: const [
            _ChatsView(),
            _AiView(),
            _BusinessView(),
            _ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Чаты'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Aurion'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Бизнес'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}

class _ChatsView extends StatelessWidget {
  const _ChatsView();

  @override
  Widget build(BuildContext context) {
    final chats = [
      ('Алексей', 'Залетаем в релиз?', '2 мин'),
      ('Команда Vibe', 'Денис: макеты готовы', '18 мин'),
      ('Маркетинг', 'Новый пост опубликован', '1 ч'),
    ];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('Vibe', style: TextStyle(fontWeight: FontWeight.w800)),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
          ],
        ),
        const SliverToBoxAdapter(child: _StatusBanner()),
        SliverList.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              leading: CircleAvatar(
                radius: 27,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(chat.$1.substring(0, 1)),
              ),
              title: Text(chat.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(chat.$2, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Text(chat.$3, style: Theme.of(context).textTheme.labelSmall),
              onTap: () {},
            );
          },
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF24163D), Color(0xFF15121F)]),
        border: Border.all(color: Color(0x408B5CF6)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, size: 20),
          SizedBox(width: 12),
          Expanded(child: Text('Vibe создан для общения без лишнего шума.')),
        ],
      ),
    );
  }
}

class _AiView extends StatelessWidget {
  const _AiView();

  @override
  Widget build(BuildContext context) => const _SectionPage(
        icon: Icons.auto_awesome,
        title: 'Aurion',
        subtitle: 'AI внутри Vibe, а не отдельным приложением.',
        cards: ['Помоги с задачей', 'Проанализируй текст', 'Создай идею'],
      );
}

class _BusinessView extends StatelessWidget {
  const _BusinessView();

  @override
  Widget build(BuildContext context) => const _SectionPage(
        icon: Icons.work,
        title: 'Бизнес-пространство',
        subtitle: 'Рабочие чаты, команды и инструменты в одном месте.',
        cards: ['Команды', 'Marketplace', 'Репутация'],
      );
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) => const _SectionPage(
        icon: Icons.person,
        title: 'Профиль',
        subtitle: 'Твоя идентичность в Vibe.',
        cards: ['Настройки приватности', 'Уведомления', 'Безопасность'],
      );
}

class _SectionPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> cards;

  const _SectionPage({required this.icon, required this.title, required this.subtitle, required this.cards});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(title: Text(title)),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 32, child: Icon(icon, size: 30)),
                const SizedBox(height: 20),
                Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(subtitle),
                const SizedBox(height: 28),
                ...cards.map((card) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(title: Text(card), trailing: const Icon(Icons.chevron_right)),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
