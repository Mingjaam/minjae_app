import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/friend.dart';
import '../styles/app_styles.dart';

class FriendsTab extends StatelessWidget {
  final List<Friend> friends;
  final Function(Friend) addFriend;
  final Function(Friend) updateFriend;
  final Function(Friend) deleteFriend;
  final Map<DateTime, List<String>> selectedFriendIds;

  const FriendsTab({
    required this.friends,
    required this.addFriend,
    required this.updateFriend,
    required this.deleteFriend,
    required this.selectedFriendIds,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 0.65,
          crossAxisSpacing: 10,
          mainAxisSpacing: 15,
        ),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showFriendInfoDialog(context, friends[index]),
            onLongPress: () => _showEditDeleteDialog(context, friends[index]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: AppStyles.friendAvatarSize,
                  height: AppStyles.friendAvatarSize,
                  decoration: BoxDecoration(
                    color: friends[index].color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      friends[index].name,
                      style: AppStyles.friendNameStyle.copyWith(fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFriendDialog(context),
        child: const Icon(Icons.person_add),
        tooltip: '친구 추가',
      ),
    );
  }

  void _showFriendInfoDialog(BuildContext context, Friend friend) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    List<DateTime> meetingDates = [];

    selectedFriendIds.forEach((date, ids) {
      if (ids.contains(friend.id)) {
        meetingDates.add(DateTime(date.year, date.month, date.day));
      }
    });

    meetingDates.sort();

    String message = '';
    
    if (meetingDates.contains(today)) {
      message = '우리는 오늘 만나요.\n';
    } else {
      final lastMeetingDate = meetingDates.lastWhere((date) => date.isBefore(today), orElse: () => today);
      final nextMeetingDate = meetingDates.firstWhere((date) => date.isAfter(today), orElse: () => today);

      final daysSinceLastMeeting = today.difference(lastMeetingDate).inDays;
      message += '우리는 마지막으로 $daysSinceLastMeeting일 전에 만났어요.\n';


     final daysUntilNextMeeting = nextMeetingDate.difference(today).inDays;
      message += '우리는 $daysUntilNextMeeting일 뒤에 만날 거예요.\n';

    }

    if (message.isEmpty) {
      message = '우린 아직 만난 기록이 없어요.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(friend.name),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    String friendName = '';
    Color friendColor = Colors.blue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('친구 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(hintText: "친구의 이름을 입력하세요"),
                      onChanged: (value) => friendName = value,
                    ),
                    const SizedBox(height: 20),
                    const Text('친구의 색상을 선택하세요'),
                    const SizedBox(height: 10),
                    ColorPicker(
                      pickerColor: friendColor,
                      onColorChanged: (color) {
                        setState(() => friendColor = color);
                      },
                      pickerAreaHeightPercent: 0.8,
                      enableAlpha: false,
                      displayThumbColor: true,
                      showLabel: false,
                      paletteType: PaletteType.hsv,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('추가'),
                  onPressed: () {
if (friendName.isNotEmpty) {
  addFriend(Friend(
    id: DateTime.now().millisecondsSinceEpoch.toString(), // 임시 ID 생성
    name: friendName,
    color: friendColor
  ));
  Navigator.of(context).pop();
}
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDeleteDialog(BuildContext context, Friend friend) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('친구 관리'),
          content: Text('${friend.name}에 대해 수행할 작업을 선택하세요.'),
          actions: <Widget>[
            TextButton(
              child: const Text('수정'),
              onPressed: () {
                Navigator.of(context).pop();
                _showEditFriendDialog(context, friend);
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                deleteFriend(friend);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showEditFriendDialog(BuildContext context, Friend friend) {
    String friendName = friend.name;
    Color friendColor = friend.color;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('친구 수정'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(hintText: "친구의 이름을 입력하세요"),
                      onChanged: (value) => friendName = value,
                      controller: TextEditingController(text: friendName),
                    ),
                    const SizedBox(height: 20),
                    const Text('친구의 색상을 선택하세요'),
                    const SizedBox(height: 10),
                    ColorPicker(
                      pickerColor: friendColor,
                      onColorChanged: (color) {
                        setState(() => friendColor = color);
                      },
                      pickerAreaHeightPercent: 0.8,
                      enableAlpha: false,
                      displayThumbColor: true,
                      showLabel: false,
                      paletteType: PaletteType.hsv,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('수정'),
                  onPressed: () {
                    if (friendName.isNotEmpty) {
                      updateFriend(Friend(
                        id: friend.id,
                        name: friendName,
                        color: friendColor
                      ));
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
