
import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../services/user_context.dart';

class PermissionGuard extends StatelessWidget {
  final AppPermission permission;
  final Widget child;
  final Widget? fallback;

  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    // Listen to UserContext changes
    return ListenableBuilder(
      listenable: UserContext(),
      builder: (context, _) {
        final user = UserContext().currentUser;
        
        if (user == null) {
          return fallback ?? const SizedBox.shrink();
        }

        if (PermissionResolver.can(user, permission)) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }
}
