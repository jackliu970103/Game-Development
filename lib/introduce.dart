import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game/main.dart';

class IntroducePage extends StatefulWidget {
  final String stg;
  const IntroducePage({super.key, required this.stg});

  @override
  State<IntroducePage> createState() => _IntroducePageState();
}

class _IntroducePageState extends State<IntroducePage> {
  List<String> goodImageList = [
    "good1.png",
    "good2.png",
    "good3.png",
    "good4.png",
    "good5.png"
  ];
  List<String> badImageList = [
    "bad6.png",
    "bad7.png",
    "bad3.png",
    "bad4.png",
    "bad5.png",
  ];
  late List<GoodIntroduce> goodData = [];
  late List<BadIntroduce> badData = [];

  late FocusNode _focusNode;

  Future<void> decodeGoodFood() async {
    final data = await rootBundle.loadString("assets/gooddata.json");
    final List<dynamic> st = jsonDecode(data);
    goodData = st.map((da) => GoodIntroduce.fromJson(da)).toList();
  }

  Future<void> decodeBadFood() async {
    final data = await rootBundle.loadString("assets/baddata.json");
    final List<dynamic> st = jsonDecode(data);
    badData = st.map((da) => BadIntroduce.fromJson(da)).toList();
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _initializeData();
  }

  void _initializeData() {
    decodeGoodFood().then((_) {
      decodeBadFood().then((_) {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // 處理空白鍵按下
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.space) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GameScreen(stg: widget.stg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isMobile ? 2 : 5;

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('食物介紹'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 好食物標題
                Text(
                  '健康食物 ✓',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // 好食物交錯網格
                _buildStaggeredGrid(
                  imageList: goodImageList,
                  dataList: goodData,
                  borderColor: Colors.green,
                ),

                const SizedBox(height: 40),

                // 壞食物標題
                Text(
                  '不健康食物 ✗',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // 壞食物交錯網格
                _buildStaggeredGrid(
                  imageList: badImageList,
                  dataList: badData,
                  borderColor: Colors.red,
                ),

                const SizedBox(height: 40),

                // 底部提示
                Center(
                  child: Text(
                    '按下空白鍵 (SPACE) 進行下一步',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 交錯網格組件
  Widget _buildStaggeredGrid({
    required List<String> imageList,
    required List<dynamic> dataList,
    required Color borderColor,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isMobile ? 2 : 5;
    final childAspectRatio = isMobile ? 0.75 : 0.85;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
      ),
      itemCount: imageList.length,
      itemBuilder: (context, index) {
        final imageName = imageList[index];
        final foodData = index < dataList.length ? dataList[index] : null;

        // 計算偏移：0, 2, 4, 6... 位置向上移動
        final offset = index % 2 == 0 ? const Offset(0, -30) : Offset.zero;

        return Transform.translate(
          offset: offset,
          child: GestureDetector(
            onTap: () => _showFoodDetail(
              context,
              foodData?.name ?? imageName,
              foodData?.content ?? '暫無資料',
            ),
            child: Card(
              elevation: 8,
              shadowColor: borderColor.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor, width: 2),
              ),
              child: Column(
                children: [
                  // 圖片區域
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Image.asset(
                          "assets/images/food/$imageName",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: borderColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // 文字區域
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            foodData?.name ?? imageName.replaceAll('.png', ''),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '點擊查看詳情',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 詳情彈窗
  void _showFoodDetail(BuildContext context, String name, String content) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 64,
          vertical: 24,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? 400 : 600,
            maxHeight: isMobile ? 500 : 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標題欄
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.headlineSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // 內容區域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              // 底部按鈕
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('關閉'),
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

class GoodIntroduce {
  final String name;
  final String content;

  GoodIntroduce({required this.name, required this.content});

  factory GoodIntroduce.fromJson(Map<String, dynamic> json) {
    return GoodIntroduce(name: json['name'], content: json['content']);
  }
}

class BadIntroduce {
  final String name;
  final String content;

  BadIntroduce({required this.name, required this.content});

  factory BadIntroduce.fromJson(Map<String, dynamic> json) {
    return BadIntroduce(name: json['name'], content: json['content']);
  }
}