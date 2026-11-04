
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyanmarAI());

const String apiUrl =
    'https://myanmar-ai-api.nay577770.workers.dev';

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
  bool loading = false;

  final chat = TextEditingController();
  final translation = TextEditingController();

  String answer = 'မင်္ဂလာပါ။ MYANMAR AI မှ ကြိုဆိုပါတယ်။';
  String translated = 'ဘာသာပြန်ရလဒ် ဒီမှာပေါ်ပါမယ်။';
  String targetLanguage = 'English';

  final languages = [
    'English',
    'Myanmar',
    'Thai',
    'Chinese',
    'Japanese',
    'Korean',
  ];

  @override
  void dispose() {
    chat.dispose();
    translation.dispose();
    super.dispose();
  }

  Future<String> askAI(String message) async {
    final response = await http
        .post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': message}),
        )
        .timeout(const Duration(seconds: 60));

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'AI Error');
    }

    return data['reply'] ?? 'အဖြေမရရှိပါ။';
  }

  Future<void> sendMessage() async {
    final message = chat.text.trim();
    if (message.isEmpty || loading) return;

    setState(() {
      loading = true;
      answer = 'AI စဉ်းစားနေပါတယ်...';
    });

    try {
      final result = await askAI(message);
      if (!mounted) return;
      setState(() => answer = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => answer = 'ချိတ်ဆက်မှု အမှားဖြစ်နေပါတယ်။\n$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> translateText() async {
    final text = translation.text.trim();
    if (text.isEmpty || loading) return;

    setState(() {
      loading = true;
      translated = 'ဘာသာပြန်နေပါတယ်...';
    });

    try {
      final result = await askAI(
        'Translate the following text into $targetLanguage. '
        'Return only the translation.\n\n$text',
      );

      if (!mounted) return;
      setState(() => translated = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => translated = 'အမှားဖြစ်နေပါတယ်။\n$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

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
        onDestinationSelected: (i) {
          setState(() => page = i);
        },
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
          child: SingleChildScrollView(
            child: Center(
              child: SelectableText(
                answer,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
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
            onPressed: loading ? null : sendMessage,
            child: Text(loading ? 'စောင့်ပါ...' : 'Send'),
          ),
        ),
      ],
    );
  }

  Widget translatePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Myanmar Translator',
          style: TextStyle(fontSize: 25),
        ),
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
        const Text('ပြန်ဆိုမည့် ဘာသာစကား'),
        DropdownButton<String>(
          value: targetLanguage,
          isExpanded: true,
          items: languages.map((language) {
            return DropdownMenuItem(
              value: language,
              child: Text(language),
            );
          }).toList(),
          onChanged: loading
              ? null
              : (value) {
                  if (value != null) {
                    setState(() => targetLanguage = value);
                  }
                },
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: loading ? null : translateText,
            child: Text(loading ? 'ဘာသာပြန်နေသည်...' : 'ဘာသာပြန်မည်'),
          ),
        ),
        const SizedBox(height: 20),
        const Text('ဘာသာပြန်ရလဒ်'),
        const SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            child: SelectableText(
              translated,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
