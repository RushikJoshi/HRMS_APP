import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api/api.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final Api _apiService;

  ProfileBloc({Api? apiService})
      : _apiService = apiService ?? Api(),
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      print('========================================');
      print('ProfileBloc: Loading profile data from API...');
      print('========================================');
      
      final response = await _apiService.getEmployeeProfile();
      
      print('========================================');
      print('ProfileBloc: Profile API Response Received');
      print('========================================');
      print('Success: ${response.success}');
      print('Message: ${response.message}');
      print('Data: ${response.data}');
      
      if (response.data != null) {
        print('----------------------------------------');
        print('Profile Data Details:');
        print('----------------------------------------');
        print('ID: ${response.data!.id}');
        print('Name: ${response.data!.name}');
        print('Email: ${response.data!.email}');
        print('Employee ID: ${response.data!.employeeId}');
        print('Company Code: ${response.data!.companyCode}');
        print('Designation: ${response.data!.designation}');
        print('Department: ${response.data!.department}');
        print('Phone: ${response.data!.phone}');
        print('Address: ${response.data!.address}');
        print('Date of Birth: ${response.data!.dateOfBirth}');
        print('Joining Date: ${response.data!.joiningDate}');
        print('Profile Photo: ${response.data!.profilePhoto}');
        print('Additional Info: ${response.data!.additionalInfo}');
        print('----------------------------------------');
      }

      if (response.success && response.data != null) {
        print('ProfileBloc: Profile data loaded successfully');
        print('========================================');
        emit(ProfileLoaded(response.data!));
      } else {
        final errorMsg = response.message ?? 'Failed to load profile data.';
        print('ProfileBloc: Profile API error: $errorMsg');
        print('========================================');
        if (response.message?.contains('401') == true || response.message?.contains('Unauthorized') == true) {
             emit(ProfileError('Session expired. Please login again.'));
        } else {
             emit(ProfileError(errorMsg));
        }
      }
    } catch (e) {
      String errorMessage = 'Failed to load profile. Please try again.';
      final errorStr = e.toString();
      
      if (errorStr.contains('401') || errorStr.contains('Unauthorized')) {
        errorMessage = 'Session expired. Please login again.';
        // Optional: Trigger logout here if you had access to AuthBloc
      } else if (errorStr.contains('Exception:')) {
        errorMessage = errorStr.replaceFirst('Exception: ', '');
      } else if (errorStr.isNotEmpty) {
        errorMessage = errorStr;
      }
      
      // Clean up error message
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      print('========================================');
      print('ProfileBloc: Error loading profile');
      print('Error: $errorMessage');
      print('Full Exception: $e');
      
      // Check for Token issues
      try {
         // This is a bit of a hack to debug, we don't have direct access to storage here without import
         // but we can infer from the error.
         print('ProfileBloc: Hints -> Check if token is valid and not expired.');
      } catch (_) {}
      
      print('========================================');
      emit(ProfileError(errorMessage));
    }
  }
}

