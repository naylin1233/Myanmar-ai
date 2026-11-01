import 'package:flutter/material.dart';

void main() => runApp(const MyanmarAI());

class MyanmarAI extends StatelessWidget {
  const MyanmarAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MYANMAR AI',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  final chat = TextEditingController();
  final translation = TextEditingController();
  String answer = 'မင်္ဂလာပါ။ MYANMAR AI မှ ကြိုဆိုပါတယ်။';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MYANMAR AI ✨'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: page == 0 ? chatPage() : translatePage(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (i) => setState(() => page = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat),
            label: 'AI Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.translate),
            label: 'ဘာသာပြန်',
          ),
        ],
      ),
    );
  }

  Widget chatPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI Chat', style: TextStyle(fontSize: 25)),
        const SizedBox(height: 20),
        Expanded(
          child: Center(
            child: Text(answer, textAlign: TextAlign.center),
          ),
        ),
        TextField(
          controller: chat,
          decoration: const InputDecoration(
            hintText: 'မေးချင်တာ ရေးပါ...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              setState(() {
                answer = 'သင့်မေးခွန်း - ${chat.text}\n\n'
                    'AI ချိတ်ဆက်မှု မပြုလုပ်ရသေးပါ။';
              });
            },
            child: const Text('Send'),
          ),
        ),
      ],
    );
  }

  Widget translatePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Myanmar Translator',
            style: TextStyle(fontSize: 25)),
        const SizedBox(height: 20),
        TextField(
          controller: translation,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'ဘာသာပြန်ချင်တဲ့ စာရေးပါ...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        const Text('ဘာသာပြန်ရလဒ်'),
        const SizedBox(height: 10),
        const Text('AI ဘာသာပြန်စနစ် ချိတ်ဆက်ရန် ကျန်ရှိသေးသည်။'),
      ],
    );
  }
}
