import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game/Character.dart';

class UItestScreen extends StatefulWidget {
  const UItestScreen({super.key});

  @override
  State<UItestScreen> createState() => _UItestScreenState();
}

class _UItestScreenState extends State<UItestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _jumpAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final FocusNode _focusNode = FocusNode();

  bool _isAnimating = false;
  bool _hasStarted = false; // 是否已按過第一次

  final List<String> _girlImages = [
    'assets/images/orGirl4.png',
    'assets/images/orGirl3.png',
    'assets/images/orGirl4.png',
    'assets/images/orGirl1.png',
    'assets/images/orGirl1.png',
    'assets/images/orGirl3.png',
    'assets/images/orGirl1.png',
  ];
  int _girlIndex = 0;

  final List<String> _spaceImages = [
    'assets/images/space1.png',
    'assets/images/space2.png',
    'assets/images/space3.png',
    'assets/images/space4.png',
    'assets/images/space5.png',
    'assets/images/space6.png',
    'assets/images/space7.png',
  ];
  int _spaceIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -50.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -50.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 55,
      ),
    ]).animate(_controller);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isAnimating = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;

      if (!_hasStarted) {
        // 第一次按：index 維持 0，播放第一張的進場動畫
        _hasStarted = true;
      } else {
        // 之後才切換 index
        if (_girlIndex < _girlImages.length - 1 &&
            _spaceIndex < _spaceImages.length - 1) {
          _girlIndex++;
          _spaceIndex++;
        } else {
          // 已到最後一張，跳頁
          _isAnimating = false;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CharacterScreen()),
          );
          return;
        }
      }
    });

    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.space) {
          _triggerAnimation();
        }
      },
      child: GestureDetector(
        onTap: _triggerAnimation,
        child: Scaffold(
          body: Stack(
            children: [
              // 1. 背景
              Image.asset(
                'assets/images/backgroundOr.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),

              // 2. 角色：跳躍動畫 + 切換圖片
              AnimatedBuilder(
                animation: _jumpAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _jumpAnimation.value),
                    child: child,
                  );
                },
                child: Image.asset(
                  _girlImages[_girlIndex],
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),

              // 3. 聊天框容器
              Image.asset(
                'assets/images/chatContainer.png',
                fit: BoxFit.contain,
                width: double.infinity,
              ),

              // 4. 台詞：滑入淡入動畫 + 切換圖片
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Image.asset(
                    _spaceImages[_spaceIndex],
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}