import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_practice_chat_flutter/features/auth/domain/models/user_with_token_dto.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

class AuthorizedScope extends StatelessWidget {
  final UserWithTokenDto userWithTokenDto;
  final Widget child;

  const AuthorizedScope({
    required this.userWithTokenDto,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => userWithTokenDto),
        Provider(create: (_) => StudyJamClient().getAuthorizedClient(userWithTokenDto.tokenDto.token)),
      ],
      child: child,
    );
  }

  static UserWithTokenDto authorizedUser(BuildContext context) => context.read<UserWithTokenDto>();

  static StudyJamClient authorizedClient(BuildContext context) => context.read<StudyJamClient>();
}
