import 'package:flutter/material.dart';
import '../styles/app_styles.dart';

class SettingsTab extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;
  final Function resetAllData;  // 추가

  const SettingsTab({
    Key? key, 
    required this.toggleTheme, 
    required this.isDarkMode,
    required this.resetAllData,  // 추가
  }) : super(key: key);

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),  // 여기를 500으로 변경했습니다.
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    widget.toggleTheme();
    if (widget.isDarkMode) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('테마 설정'),
          trailing: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Switch(
                value: widget.isDarkMode,
                onChanged: (bool value) => _toggleTheme(),
                thumbColor: MaterialStateProperty.all(
                  Color.lerp(Colors.grey[400], Colors.blue, _animation.value),
                ),
                trackColor: MaterialStateProperty.all(
                  Color.lerp(Colors.grey[300], Colors.blue.withOpacity(0.5), _animation.value),
                ),
              );
            },
          ),
        ),
        ListTile(
          title: Text('알림 설정'),
          trailing: Switch(
            value: true, // 실제 알림 상태에 따라 변경 필요
            onChanged: (bool value) {
              // 알림 설정 변경 로직 구현
            },
          ),
        ),
        ListTile(
          title: Text('언어 설정'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            // 언어 설정 화면으로 이동하는 로직 구현
          },
        ),
        ListTile(
          title: Text('로그아웃'),
          onTap: () {
            // 로그아웃 로직 구현
          },
        ),
        ListTile(
          title: Text('앱 버전'),
          trailing: Text('1.0.0'), // 실제 앱 버전으로 변경 필요
        ),
        ListTile(
          title: Text('모든 데이터 초기화'),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('데이터 초기화'),
                  content: Text('정말로 모든 데이터를 초기화하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('취소'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('확인'),
                      onPressed: () {
                        widget.resetAllData();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

