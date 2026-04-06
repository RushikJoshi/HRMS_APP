import 'package:flutter/material.dart';
import '../models/profile_compat_entities.dart';
import '../widgets/common_grid_section.dart';

class ProfilePersonalInfoCard extends StatelessWidget {
  final List<ProfileMenuEntity> personalInfoList;
  final ProfileModelEntity profileModelEntity;
  final ValueChanged<ProfileMenuEntity>? onMenuTap;

  const ProfilePersonalInfoCard({
    super.key,
    required this.personalInfoList,
    required this.profileModelEntity,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return CommonGridSection(
      title: 'Personal Info',
      sectionGif: 'assets/gifs/profile_info.gif',
      items: personalInfoList.map((item) {
        return GridItem(
          label: item.languageKeyName.toString(),
          iconPath: item.profileMenuPhoto,
          onTap: () => onMenuTap?.call(item),
        );
      }).toList(),
    );
  }
}
