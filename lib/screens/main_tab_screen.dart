import 'package:flutter/material.dart';
import '../tabs/calendar_tab.dart';
import '../tabs/friends_tab.dart';
import '../tabs/statistics_tab.dart';  // 새로 추가
import '../tabs/settings_tab.dart';  // 추가
import '../models/friend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MainTabScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  MainTabScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _MainTabScreenState createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;
  List<Friend> friends = [];
  late PageController _pageController;
  Map<DateTime, List<String>> selectedFriendIds = {};

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _loadSelectedFriendIds();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? friendsJson = prefs.getString('friends');
    if (friendsJson != null) {
      List<dynamic> decodedJson = jsonDecode(friendsJson);
      setState(() {
        friends = decodedJson.map((item) => Friend.fromJson(item)).toList();
      });
    }
  }

  void _loadSelectedFriendIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedFriendIdsJson = prefs.getString('selectedFriendIds');
    if (selectedFriendIdsJson != null) {
      Map<String, dynamic> decodedJson = jsonDecode(selectedFriendIdsJson);
      setState(() {
        selectedFriendIds = decodedJson.map((key, value) => MapEntry(
          DateTime.parse(key),
          (value as List<dynamic>).cast<String>(),
        ));
      });
    }
  }

  void _saveSelectedFriendIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> encodedMap = selectedFriendIds.map((key, value) => MapEntry(
      key.toIso8601String(),
      value,
    ));
    String selectedFriendIdsJson = jsonEncode(encodedMap);
    await prefs.setString('selectedFriendIds', selectedFriendIdsJson);
  }

  void _saveFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String friendsJson = jsonEncode(friends.map((f) => f.toJson()).toList());
    await prefs.setString('friends', friendsJson);
  }

  void _addFriend(Friend friend) {
    setState(() {
      friends.add(friend);
      _saveFriends();
    });
  }

  void _updateFriend(Friend updatedFriend) {
    setState(() {
      final index = friends.indexWhere((friend) => friend.id == updatedFriend.id);
      if (index != -1) {
        friends[index] = updatedFriend;
        _saveFriends();
      }
    });
  }

  void _deleteFriend(Friend friend) {
    setState(() {
      friends.remove(friend);
      _saveFriends();
    });
  }

  void _updateSelectedFriendIds(DateTime date, List<String> friendIds) {
    setState(() {
      selectedFriendIds[date] = friendIds;
      _saveSelectedFriendIds();
    });
  }

  Future<void> _saveToSharedPreferences(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is List) {
      await prefs.setString(key, jsonEncode(value));
    } else if (value is Map) {
      await prefs.setString(key, jsonEncode(value));
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _resetAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      friends = [];
      selectedFriendIds = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friender'),
        centerTitle: false,
        elevation: 1,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          CalendarTab(
            friends: friends,
            selectedFriendIds: selectedFriendIds,
            updateSelectedFriendIds: _updateSelectedFriendIds,
          ),
          FriendsTab(
            friends: friends,
            addFriend: _addFriend,
            updateFriend: _updateFriend,
            deleteFriend: _deleteFriend,
            selectedFriendIds: selectedFriendIds,
          ),
          StatisticsTab(
            friends: friends,
            selectedFriendIds: selectedFriendIds,
          ),
          SettingsTab(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
            resetAllData: _resetAllData,  // 추가
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '캘린더'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '친구'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '통계'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),  // 추가
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
