import 'package:equatable/equatable.dart';

class ForumPost extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String category;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final List<ForumComment> comments;

  const ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.updatedAt,
    required this.category,
    this.tags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.comments = const [],
  });

  ForumPost copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    List<ForumComment>? comments,
  }) {
    return ForumPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      comments: comments ?? this.comments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'category': category,
      'tags': tags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] as List),
      likesCount: json['likesCount'] as int,
      commentsCount: json['commentsCount'] as int,
      comments: (json['comments'] as List)
          .map((comment) => ForumComment.fromJson(comment))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        authorId,
        authorName,
        createdAt,
        updatedAt,
        category,
        tags,
        likesCount,
        commentsCount,
        comments,
      ];
}

class ForumComment extends Equatable {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final int likesCount;

  const ForumComment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.likesCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
    };
  }

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['id'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likesCount: json['likesCount'] as int,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        authorId,
        authorName,
        createdAt,
        likesCount,
      ];
}