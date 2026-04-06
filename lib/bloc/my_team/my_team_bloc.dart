import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_team_event.dart';
import 'my_team_state.dart';

class MyTeamBloc extends Bloc<MyTeamEvent, MyTeamState> {
  MyTeamBloc() : super(const MyTeamState()) {
    on<MyTeamLoadRequested>(_onLoadRequested);
    on<MyTeamFilterChanged>(_onFilterChanged);
    
    add(const MyTeamLoadRequested());
  }

  void _onLoadRequested(
    MyTeamLoadRequested event,
    Emitter<MyTeamState> emit,
  ) {
    // Mock data - in real app, fetch from API
    final members = [
      TeamMember(
        id: 'EMP01',
        name: 'Bagus Fikri',
        designation: 'CEO',
        department: 'Managerial',
        status: 'Active',
        checkIn: '09:00 AM',
        avatar: 'B',
        color: Colors.blue,
      ),
      TeamMember(
        id: 'EMP02',
        name: 'Ihdizein',
        designation: 'Illustrator',
        department: 'Managerial',
        status: 'Active',
        checkIn: '09:15 AM',
        avatar: 'I',
        color: Colors.green,
      ),
      TeamMember(
        id: 'EMP03',
        name: 'Mufti Hidayat',
        designation: 'Project Manager',
        department: 'Managerial',
        status: 'Active',
        checkIn: '09:30 AM',
        avatar: 'M',
        color: Colors.orange,
      ),
      TeamMember(
        id: 'EMP04',
        name: 'Fauzan Ardhiansyah',
        designation: 'QC & Research',
        department: 'Managerial',
        status: 'Active',
        checkIn: '09:00 AM',
        avatar: 'F',
        color: Colors.teal,
      ),
      TeamMember(
        id: 'EMP05',
        name: 'Raihan Fikri',
        designation: 'UI Designer',
        department: 'Human Resources',
        status: 'Invited',
        checkIn: '-',
        avatar: 'R',
        color: Colors.purple,
      ),
      TeamMember(
        id: 'EMP06',
        name: 'Iqbal',
        designation: 'UI Designer',
        department: 'Web Designer',
        status: 'Inactive',
        checkIn: '-',
        avatar: 'I',
        color: Colors.red,
      ),
       TeamMember(
        id: 'EMP07',
        name: 'Panji Dwi',
        designation: 'UI Designer',
        department: 'President of Sales',
        status: 'Active',
        checkIn: '10:00 AM',
        avatar: 'P',
        color: Colors.indigo,
      ),
    ];

    emit(state.copyWith(allMembers: members));
  }

  void _onFilterChanged(
    MyTeamFilterChanged event,
    Emitter<MyTeamState> emit,
  ) {
    emit(state.copyWith(selectedFilter: event.filter));
  }
}

