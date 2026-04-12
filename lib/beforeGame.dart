import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game/introduce.dart';

import 'Character.dart';
import 'main.dart';

class ChatScreen extends StatefulWidget {
  final String chose;
  const ChatScreen({super.key,required this.chose});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _jumpAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final FocusNode _focusNode = FocusNode();

  bool _isAnimating = false;
  bool _hasStarted = false; // 是否已按過第一次

  final List<String> _orgirlImages = [
    'assets/images/initImages/orGirl1.png',
    'assets/images/initImages/orGirl2.png',
  ];
  int _girlIndex = 0;

  final List<String> _orspaceImages = [
    'assets/images/choseoOr1.png',
    'assets/images/choseOr2.png',
  ];
  final List<String> _blImages =[
    "assets/images/blue/blue1.png",
    "assets/images/blue/blue3.png",
    "assets/images/blue/blue2.png",
  ];
  final List<String> _blText =[
    "assets/images/blue/me.png",
    "assets/images/blue/eww.png",
    "assets/images/blue/start.png"
  ];
  final List<String> _pkImages =[
    "assets/images/pink/pink4.png",
    "assets/images/pink/pink2.png",
    "assets/images/pink/pink3.png",
    "assets/images/pink/pink1.png"
  ];
  final List<String> _pkText =[
    "assets/images/pink/a.png",
    "assets/images/pink/dot.png",
    "assets/images/pink/manydot.png",
    "assets/images/pink/gogogo.png"
  ];
  final List<String> _gyImages =[
    "assets/images/grey/grey1.png",
    "assets/images/grey/grey2.png",
    "assets/images/grey/grey3.png"
  ];
  final List<String> _gyText =[
    "assets/images/grey/pick.png",
    "assets/images/grey/yummy.png",
    "assets/images/grey/eat.png"
  ];
  String backgroundImage ="";
  String chatBoxImage ="";
  List<String> characterImageList =[];
  List<String> characterChatList =[];
  int _spaceIndex = 0;

  @override
  void initState() {
    super.initState();
    switch(widget.chose){
      case "assets/images/redStand.png" :
          backgroundImage ="assets/images/background/backgroundPk.png";
          chatBoxImage="assets/images/chatbox/chatboxPk.png";
          characterImageList=_pkImages;
          characterChatList =_pkText;
        break;
      case "assets/images/greyStand.png":
        backgroundImage ="assets/images/background/backgroundGy.png";
        chatBoxImage="assets/images/chatbox/chatboxGy.png";
        characterImageList=_gyImages;
        characterChatList =_gyText;
        break;
      case "assets/images/blueStand.png":
        backgroundImage ="assets/images/background/backgroundBl.png";
        chatBoxImage="assets/images/chatbox/chatboxBl.png";
        characterImageList=_blImages;
        characterChatList =_blText;
        break;
      case "assets/images/player.png":
        backgroundImage ="assets/images/background/backgroundOr.png";
        chatBoxImage="assets/images/chatbox/chatContainer.png";
        characterImageList=_orgirlImages;
        characterChatList =_orspaceImages;
        break;
    }
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
        // 檢查是否還有下一張
        int nextGirlIndex = _girlIndex + 1;
        int nextSpaceIndex = _spaceIndex + 1;

        if (nextGirlIndex < characterImageList.length &&
            nextSpaceIndex < characterChatList.length) {
          // 可以繼續切換
          _girlIndex = nextGirlIndex;
          _spaceIndex = nextSpaceIndex;
        } else {
          // 已到最後，跳頁
          _isAnimating = false;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IntroducePage(stg: widget.chose),
            ),
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
                backgroundImage,
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
                  characterImageList[_girlIndex],
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),

              // 3. 聊天框容器
              Image.asset(
                chatBoxImage,
                fit: BoxFit.contain,
                width: double.infinity,
              ),

              // 4. 台詞：滑入淡入動畫 + 切換圖片
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Image.asset(
                    characterChatList[_spaceIndex],
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
