import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../aurion/presentation/aurion_page.dart';
import '../../chats/presentation/chat_list_controller.dart';
import '../../messages/presentation/chat_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _index = 0;
  @override Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: _index, children: const [_ChatsTab(), AurionPage(), _BusinessTab(), _ProfileTab()])),
    bottomNavigationBar: NavigationBar(selectedIndex: _index, onDestinationSelected: (value) => setState(() => _index = value), destinations: const [
      NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Чаты'),
      NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Aurion'),
      NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Бизнес'),
      NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Профиль'),
    ]),
  );
}

class _ChatsTab extends ConsumerWidget {
  const _ChatsTab();
  @override Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatListProvider);
    return CustomScrollView(slivers: [
      const SliverAppBar(pinned: true, title: Text('Vibe', style: TextStyle(fontWeight: FontWeight.w800))),
      const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text('Общение без лишнего шума.'))),
      chats.when(
        loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
        error: (error, _) => SliverFillRemaining(child: Center(child: Text('Не удалось загрузить чаты: $error'))),
        data: (items) => SliverList.builder(itemCount: items.length, itemBuilder: (context, index) {
          final chat = items[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            leading: CircleAvatar(child: Text(chat.title.characters.first)),
            title: Text(chat.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(chat.preview, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: chat.unreadCount > 0 ? Badge(label: Text('${chat.unreadCount}')) : null,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatPage(chatId: chat.id, title: chat.title))),
          );
        }),
      ),
    ]);
  }
}

class _BusinessTab extends StatelessWidget { const _BusinessTab(); @override Widget build(BuildContext context) => const _PlaceholderTab(icon: Icons.work, title: 'Бизнес-пространство', subtitle: 'Команды, marketplace и рабочие чаты.'); }
class _ProfileTab extends StatelessWidget { const _ProfileTab(); @override Widget build(BuildContext context) => const _PlaceholderTab(icon: Icons.person, title: 'Профиль', subtitle: 'Идентичность и настройки Vibe.'); }
class _PlaceholderTab extends StatelessWidget {
  final IconData icon; final String title; final String subtitle;
  const _PlaceholderTab({required this.icon, required this.title, required this.subtitle});
  @override Widget build(BuildContext context) => CustomScrollView(slivers: [SliverAppBar(title: Text(title)), SliverFillRemaining(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 48), const SizedBox(height: 16), Text(title, style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 8), Text(subtitle)]))) ]);
}
