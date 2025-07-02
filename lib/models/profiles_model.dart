class ProfileModel {
  final String name;
  final String imageUrl;
  final String profession;
  final String description;
  final String location;
  final String area;
  final int postsCount;
  final int followersCount;
  final int followingCount;

  ProfileModel({
    required this.name,
    required this.imageUrl,
    required this.profession,
    required this.description,
    required this.location,
    required this.area,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
  });
}

class PostModel {
  final String imageUrl;
  final int likesCount;
  final List<CommentModel> comments;
  final String date;

  PostModel({
    required this.imageUrl,
    required this.likesCount,
    required this.comments,
    required this.date,
  });
}

class CommentModel {
  final String username;
  final String text;

  CommentModel({
    required this.username,
    required this.text,
  });
}
