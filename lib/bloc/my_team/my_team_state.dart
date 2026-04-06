import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TeamMember {
  final String id;
  final String name;
  final String designation;
  final String department;
  final String status;
  final String checkIn;
  final String avatar;
  final Color color;

  TeamMember({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.status,
    required this.checkIn,
    required this.avatar,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'designation': designation,
      'department': department,
      'status': status,
      'checkIn': checkIn,
      'avatar': avatar,
      'color': color.value,
    };
  }

  factory TeamMember.fromMap(Map<String, dynamic> map) {
    return TeamMember(
      id: map['id'] as String,
      name: map['name'] as String,
      designation: map['designation'] as String,
      department: map['department'] as String? ?? 'Managerial', // Default if missing
      status: map['status'] as String,
      checkIn: map['checkIn'] as String,
      avatar: map['avatar'] as String,
      color: map['color'] is Color 
          ? map['color'] as Color 
          : Color(map['color'] as int),
    );
  }
}

class MyTeamState extends Equatable {
  final List<TeamMember> allMembers;
  final String selectedFilter;

  const MyTeamState({
    this.allMembers = const [],
    this.selectedFilter = 'All',
  });

  List<TeamMember> get filteredMembers {
    if (selectedFilter == 'All') {
      return allMembers;
    }
    return allMembers.where((member) => member.status == selectedFilter).toList();
  }

  @override
  List<Object?> get props => [allMembers, selectedFilter];

  MyTeamState copyWith({
    List<TeamMember>? allMembers,
    String? selectedFilter,
  }) {
    return MyTeamState(
      allMembers: allMembers ?? this.allMembers,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

