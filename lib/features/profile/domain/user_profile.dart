class UserProfile { final String id; final String username; final String displayName; final String? avatarUrl; const UserProfile({required this.id, required this.username, required this.displayName, this.avatarUrl}); }
abstract interface class ProfileRepository { Future<UserProfile?> current(); Future<void> update(UserProfile profile); }
