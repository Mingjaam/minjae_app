import 'package:flutter/material.dart';
import '../models/friend.dart';

class StatisticsTab extends StatelessWidget {
  final List<Friend> friends;
  final Map<DateTime, List<String>> selectedFriendIds;

  const StatisticsTab({
    Key? key,
    required this.friends,
    required this.selectedFriendIds,
  }) : super(key: key);

  Map<String, int> _getMeetingCountForMonth(int year, int month) {
    Map<String, int> meetingCount = {};
    selectedFriendIds.forEach((date, ids) {
      if (date.year == year && date.month == month && ids.isNotEmpty) {
        for (var id in ids.where((id) => id.isNotEmpty)) {
          if (friends.any((friend) => friend.id == id)) {
            meetingCount[id] = (meetingCount[id] ?? 0) + 1;
          }
        }
      }
    });
    return meetingCount;
  }

  List<MapEntry<Friend, int>> _getSortedFriendsForMonth(int year, int month) {
    var meetingCount = _getMeetingCountForMonth(year, month);
    var friendMeetings = friends
        .map((friend) => MapEntry(friend, meetingCount[friend.id] ?? 0))
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return friendMeetings;
  }

  void _checkData() {
    selectedFriendIds.forEach((date, ids) {
      if (ids.any((id) => !friends.any((friend) => friend.id == id))) {
        print('유효하지 않은 친구 ID가 발견됨: $date, $ids');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _checkData();
    final now = DateTime.now();
    final friendMeetings = _getSortedFriendsForMonth(now.year, now.month);

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '우리는 ${now.month}월에...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...friendMeetings.map((entry) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: entry.key.color,
                ),
                title: Text(entry.key.name),
                trailing: Text('${entry.value}회'),
              )),
        ],
      ),
    );
  }
}
