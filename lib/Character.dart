import 'package:flutter/material.dart';
import 'package:game/main.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  String? selectedCharacter;
  String? hoverCharacter;

  final characters = [
    "assets/images/redStand.png",
    "assets/images/blueStand.png",
    "assets/images/grayStand.png",
    "assets/images/player.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF3BB), // 深色網頁風
      appBar: AppBar(
        title: const Text("選擇角色"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "選擇你的角色",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: characters.map((path) {
                  final isSelected = selectedCharacter == path;
                  final isHover = hoverCharacter == path;

                  return MouseRegion(
                    onEnter: (_) {
                      setState(() => hoverCharacter = path);
                    },
                    onExit: (_) {
                      setState(() => hoverCharacter = null);
                    },
                    child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCharacter = path;
                          });

                          Future.delayed(const Duration(milliseconds: 150), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameScreen(),
                              ),
                            );
                          });
                        },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        width: isHover ? 140 : 120,
                        height: isHover ? 140 : 120,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.greenAccent
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            if (isHover)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                          ],
                        ),
                        child: AnimatedScale(
                          scale: isSelected ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Image.asset(path),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              if (selectedCharacter != null)
                AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    "目前選擇: $selectedCharacter",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}