class SocialLinkEntity {
  final String? facebook;
  final String? linkedin;
  final String? twitter;
  final String? instagram;
  final String? whatsappNumberWithoutCountryCode;

  SocialLinkEntity({
    this.facebook,
    this.linkedin,
    this.twitter,
    this.instagram,
    this.whatsappNumberWithoutCountryCode,
  });
}

class ProfileMenuEntity {
  final String? menuLanguageKey;
  final String? languageKeyName;
  final String? profileMenuPhoto;
  final String? menuClick;

  ProfileMenuEntity({
    this.menuLanguageKey,
    this.languageKeyName,
    this.profileMenuPhoto,
    this.menuClick,
  });
}

class ProfileModelEntity {
  final String? id;
  final String? fullName;

  ProfileModelEntity({this.id, this.fullName});
}
