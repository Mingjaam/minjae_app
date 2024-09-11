import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/friend.dart';
import '../styles/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CalendarTab extends StatefulWidget {
  final List<Friend> friends;
  final Map<DateTime, List<String>> selectedFriendIds;
  final Function(DateTime, List<String>) updateSelectedFriendIds;

  const CalendarTab({
    required this.friends,
    required this.selectedFriendIds,
    required this.updateSelectedFriendIds,
  });

  @override
  _CalendarTabState createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  late PageController _pageController;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<String>> _selectedFriendIds = {};

  @override
  void initState() {
    super.initState();
    _selectedFriendIds = widget.selectedFriendIds;
    _pageController = PageController(initialPage: 1200); // 현재 월을 1200으로 설정
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadSelectedFriendIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedFriendIdsJson = prefs.getString('selectedFriendIds');
    if (selectedFriendIdsJson != null) {
      Map<String, dynamic> decodedJson = jsonDecode(selectedFriendIdsJson);
      setState(() {
        _selectedFriendIds = decodedJson.map((key, value) => MapEntry(
          DateTime.parse(key),
          (value as List<dynamic>).cast<String>(),
        ));
      });
    }
  }

  // _saveSelectedFriendIds 메서드 수정
  void _saveSelectedFriendIds() {
    widget.updateSelectedFriendIds(_selectedDay, _selectedFriendIds[_selectedDay] ?? []);
    // SharedPreferences 저장 로직은 유지
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        final monthOffset = index - 1200;
        final targetDate = DateTime(_focusedDay.year, _focusedDay.month + monthOffset, 1);
        return _buildMonthCalendar(targetDate);
      },
      onPageChanged: (index) {
        final monthOffset = index - 1200;
        setState(() {
          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + monthOffset, 1);
        });
      },
    );
  }

  Widget _buildMonthCalendar(DateTime month) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableHeight = constraints.maxHeight;
        double rowHeight = availableHeight / 7.1;

        return TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: month,
          currentDay: DateTime.now(),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _showFriendsList(context, selectedDay);
          },
          calendarFormat: CalendarFormat.month,
          rowHeight: rowHeight,
          daysOfWeekHeight: 20,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(fontSize: 18),
            headerPadding: EdgeInsets.symmetric(vertical: 5),
          ),
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: true,  // 이 속성을 true로 설정
            defaultTextStyle: TextStyle(color: Colors.black),
            weekendTextStyle: TextStyle(color: Colors.red),
            outsideTextStyle: TextStyle(color: Colors.grey),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: AppStyles.calendarDayTextStyle,
            weekendStyle: AppStyles.calendarDayTextStyle,
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              return _buildCalendarCell(day, false);
            },
            selectedBuilder: (context, day, focusedDay) {
              return _buildCalendarCell(day, true);
            },
            todayBuilder: (context, day, focusedDay) {
              return _buildCalendarCell(day, false, isToday: true);
            },
            outsideBuilder: (context, day, focusedDay) {
              return _buildCalendarCell(day, false, isOutside: true);
            },
          ),
          sixWeekMonthsEnforced: true,
        );
      },
    );
  }

  Widget _buildCalendarCell(DateTime day, bool isSelected, {bool isToday = false, bool isOutside = false}) {
    // 날짜만 비교하기 위해 시간 정보를 제거합니다.
    DateTime dateOnly = DateTime(day.year, day.month, day.day);
    List<String> friendIdsForDay = [];
  
    // 모든 날짜에 대해 친구 ID를 확인합니다.
    _selectedFriendIds.forEach((date, ids) {
      if (date.year == dateOnly.year && date.month == dateOnly.month && date.day == dateOnly.day) {
        friendIdsForDay.addAll(ids);
      }
    });
  
    List<Friend> friendsForDay = widget.friends.where((friend) => friendIdsForDay.contains(friend.id)).toList();


    return LayoutBuilder(
      builder: (context, constraints) {
        double cellWidth = constraints.maxWidth;
        double cellHeight = constraints.maxHeight;

        return Container(
          width: cellWidth,
          height: cellHeight,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.blue.withOpacity(0.3)
                : isToday 
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isOutside 
                        ? Colors.grey
                        : isSelected 
                            ? Colors.blue 
                            : (isToday ? Colors.blue : null),
                    fontWeight: isSelected || isToday ? FontWeight.bold : null,
                    fontSize: 12,
                  ),
                ),
              ),
              if (friendsForDay.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 2,
                      runSpacing: 2,
                      children: friendsForDay.take(20).map((friend) {
                        return AnimatedDot(color: friend.color);
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showFriendsList(BuildContext context, DateTime selectedDate) {
    List<String> selectedFriendIds = _selectedFriendIds[selectedDate] ?? [];
    List<Friend> allFriends = widget.friends;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.2,
              maxChildSize: 0.9,
              builder: (_, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 5,
                        width: 40,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '${selectedDate.month} / ${selectedDate.day}',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 0.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 24,
                          ),
                          itemCount: allFriends.length,
                          itemBuilder: (context, index) {
                            final friend = allFriends[index];
                            final isSelected = selectedFriendIds.contains(friend.id);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedFriendIds.remove(friend.id);
                                  } else {
                                    selectedFriendIds.add(friend.id);
                                  }
                                  _selectedFriendIds[selectedDate] = selectedFriendIds;
                                });
                                _saveSelectedFriendIds();
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: friend.color,
                                        radius: 30,
                                      ),
                                      if (isSelected)
                                        Icon(Icons.check, color: Colors.white, size: 40),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    friend.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).then((_) {
      setState(() {});
    });
  }
}

class AnimatedDot extends StatefulWidget {
  final Color color;

  const AnimatedDot({required this.color});

  @override
  _AnimatedDotState createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<AnimatedDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),  // 애니메이션 지속 시간
      vsync: this,
    );
    _animation = Tween<double>(begin: -20, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceOut),  // 애니메이션 곡선
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
