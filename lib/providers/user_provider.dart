import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserNotifier extends StateNotifier<Map<String, String>> {
  UserNotifier() : super({});

  void setUser({
    required String id,
    required String name,
    required String email,
    String? phone,
  }) {
    state = {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone ?? "",
    };
  }
}

final userProvider =
    StateNotifierProvider<UserNotifier, Map<String, String>>((ref) {
  return UserNotifier();
});
