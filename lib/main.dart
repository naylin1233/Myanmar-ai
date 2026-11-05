
import 'dart:async';
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
  int cooldownSeconds = 0;

  Timer? cooldownTimer;

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
    cooldownTimer?.cancel();
    chat.dispose();
    translation.dispose();
    super.dispose();
  }

  void startCooldown() {
    cooldownTimer?.cancel();

    setState(() {
      cooldownSeconds = 45;
    });

    cooldownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (cooldownSeconds <= 1) {
          timer.cancel();
          setState(() {
            cooldownSeconds = 0;
          });
        } else {
          setState(() {
            cooldownSeconds--;
          });
        }
      },
    );
  }

  Future<String> askAI(String message) async {
    final response = await http
        .post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'message': message,
          }),
        )
        .timeout(const Duration(seconds: 60));

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['error'] ?? 'Gemini API Error',
      );
    }

    return data['reply'] ?? 'အဖြေမရရှိပါ။';
  }

  bool isRateLimitError(Object error) {
    final message = error.toString().toLowerCase();

    return message.contains('rate limit') ||
        message.contains('too many requests') ||
        message.contains('429');
  }

  Future<void> sendMessage() async {
    final message = chat.text.trim();

    if (message.isEmpty ||
        loading ||
        cooldownSeconds > 0) {
      return;
    }

    setState(() {
      loading = true;
      answer = 'AI စဉ်းစားနေပါတယ်...';
    });

    try {
      final result = await askAI(message);

      if (!mounted) return;

      setState(() {
        answer = result;
      });
    } catch (e) {
      if (!mounted) return;

      if (isRateLimitError(e)) {
        startCooldown();

        setState(() {
          answer =
              'Gemini Free Tier အသုံးပြုမှု ကန့်သတ်ချက် ပြည့်သွားပါတယ်။ '
              'ခဏစောင့်ပြီး ပြန်မေးပေးပါ။';
        });
      } else {
        setState(() {
          answer = 'ချိတ်ဆက်မှု အမှားဖြစ်နေပါတယ်။\n$e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> translateText() async {
    final text = translation.text.trim();

    if (text.isEmpty ||
        loading ||
        cooldownSeconds > 0) {
      return;
    }

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

      setState(() {
        translated = result;
      });
    } catch (e) {
      if (!mounted) return;

      if (isRateLimitError(e)) {
        startCooldown();

        setState(() {
          translated =
              'Gemini Free Tier ကန့်သတ်ချက် ပြည့်သွားပါတယ်။ '
              'ခဏစောင့်ပြီး ပြန်စမ်းပါ။';
        });
      } else {
        setState(() {
          translated = 'ဘာသာပြန်မှု အမှားဖြစ်နေပါတယ်။\n$e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
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
          setState(() {
            page = i;
          });
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
        const Text(
          'AI Chat',
          style: TextStyle(fontSize: 25),
        ),
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
            onPressed:
                loading || cooldownSeconds > 0
                    ? null
                    : sendMessage,
            child: Text(
              cooldownSeconds > 0
                  ? 'စောင့်ပါ (${cooldownSeconds}s)'
                  : loading
                      ? 'စဉ်းစားနေပါတယ်...'
                      : 'Send',
            ),
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
            return DropdownMenuItem<String>(
              value: language,
              child: Text(language),
            );
          }).toList(),
          onChanged: loading || cooldownSeconds > 0
              ? null
              : (value) {
                  if (value != null) {
                    setState(() {
                      targetLanguage = value;
                    });
                  }
                },
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed:
                loading || cooldownSeconds > 0
                    ? null
                    : translateText,
            child: Text(
              cooldownSeconds > 0
                  ? 'စောင့်ပါ (${cooldownSeconds}s)'
                  : loading
                      ? 'ဘာသာပြန်နေသည်...'
                      : 'ဘာသာပြန်မည်',
            ),
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
