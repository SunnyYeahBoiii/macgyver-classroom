import 'dart:convert';

enum ScanStatus {
  created,
  uploading,
  uploaded,
  analyzing,
  needsConfirmation,
  confirmed,
  failed,
}

enum SafetyCategory { safe, caution, blocked }

class UserSession {
  const UserSession({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    required this.profileComplete,
    this.role = 'teacher',
  });

  final String userId;
  final String fullName;
  final String email;
  final String accessToken;
  final String refreshToken;
  final bool profileComplete;
  final String role;

  UserSession copyWith({
    bool? profileComplete,
    String? accessToken,
    String? fullName,
  }) => UserSession(
    userId: userId,
    fullName: fullName ?? this.fullName,
    email: email,
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken,
    profileComplete: profileComplete ?? this.profileComplete,
    role: role,
  );

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
    userId: json['user_id'] as String,
    fullName:
        json['full_name'] as String? ??
        json['fullName'] as String? ??
        'Teacher',
    email: json['email'] as String,
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
    profileComplete: json['profile_complete'] as bool? ?? false,
    role: json['role'] as String? ?? 'teacher',
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'full_name': fullName,
    'email': email,
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'profile_complete': profileComplete,
    'role': role,
  };

  String encode() => jsonEncode(toJson());
}

class TeacherProfile {
  const TeacherProfile({
    required this.schoolName,
    required this.subjects,
    required this.gradeBands,
    required this.classLabels,
    required this.defaultTopic,
    required this.teachingNotes,
  });

  final String schoolName;
  final List<String> subjects;
  final List<String> gradeBands;
  final List<String> classLabels;
  final String defaultTopic;
  final String teachingNotes;

  bool get isComplete =>
      schoolName.trim().isNotEmpty &&
      subjects.isNotEmpty &&
      gradeBands.isNotEmpty;

  static const empty = TeacherProfile(
    schoolName: '',
    subjects: [],
    gradeBands: [],
    classLabels: [],
    defaultTopic: '',
    teachingNotes: '',
  );
}

class ScanImage {
  const ScanImage({required this.id, required this.source, required this.path});

  final String id;
  final String source;
  final String path;
}

class DetectedItem {
  const DetectedItem({
    required this.id,
    required this.label,
    required this.quantity,
    required this.unit,
    required this.confidence,
    required this.evidence,
    this.notes = '',
    this.safetyFlags = const [],
    this.removed = false,
  });

  final String id;
  final String label;
  final int quantity;
  final String unit;
  final double confidence;
  final String evidence;
  final String notes;
  final List<String> safetyFlags;
  final bool removed;

  DetectedItem copyWith({
    String? label,
    int? quantity,
    String? unit,
    String? notes,
    bool? removed,
  }) => DetectedItem(
    id: id,
    label: label ?? this.label,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    confidence: confidence,
    evidence: evidence,
    notes: notes ?? this.notes,
    safetyFlags: safetyFlags,
    removed: removed ?? this.removed,
  );
}

class InventoryScan {
  const InventoryScan({
    required this.id,
    required this.status,
    required this.images,
    required this.detectedItems,
    required this.subject,
    required this.gradeBand,
    required this.topic,
    required this.classLabel,
    this.errorMessage,
  });

  final String id;
  final ScanStatus status;
  final List<ScanImage> images;
  final List<DetectedItem> detectedItems;
  final String subject;
  final String gradeBand;
  final String topic;
  final String classLabel;
  final String? errorMessage;

  List<DetectedItem> get confirmedItems =>
      detectedItems.where((item) => !item.removed).toList();

  InventoryScan copyWith({
    ScanStatus? status,
    List<ScanImage>? images,
    List<DetectedItem>? detectedItems,
    String? subject,
    String? gradeBand,
    String? topic,
    String? classLabel,
    String? errorMessage,
  }) => InventoryScan(
    id: id,
    status: status ?? this.status,
    images: images ?? this.images,
    detectedItems: detectedItems ?? this.detectedItems,
    subject: subject ?? this.subject,
    gradeBand: gradeBand ?? this.gradeBand,
    topic: topic ?? this.topic,
    classLabel: classLabel ?? this.classLabel,
    errorMessage: errorMessage,
  );
}

class ExperimentSuggestion {
  const ExperimentSuggestion({
    required this.id,
    required this.title,
    required this.gradeBand,
    required this.subject,
    required this.topic,
    required this.durationMinutes,
    required this.difficulty,
    required this.safetyCategory,
    required this.availableMaterials,
    required this.missingMaterials,
    required this.reasoning,
  });

  final String id;
  final String title;
  final String gradeBand;
  final String subject;
  final String topic;
  final int durationMinutes;
  final String difficulty;
  final SafetyCategory safetyCategory;
  final List<String> availableMaterials;
  final List<String> missingMaterials;
  final String reasoning;
}

class LessonPlan {
  const LessonPlan({
    required this.id,
    required this.title,
    required this.gradeBand,
    required this.subject,
    required this.topic,
    required this.durationMinutes,
    required this.objectives,
    required this.materials,
    required this.flow,
    required this.questions,
    required this.assessment,
    required this.safetyNotes,
    required this.sourceExperimentId,
    this.favorite = false,
    this.archived = false,
    this.version = 1,
  });

  final String id;
  final String title;
  final String gradeBand;
  final String subject;
  final String topic;
  final int durationMinutes;
  final List<String> objectives;
  final List<String> materials;
  final List<String> flow;
  final List<String> questions;
  final String assessment;
  final List<String> safetyNotes;
  final String sourceExperimentId;
  final bool favorite;
  final bool archived;
  final int version;

  LessonPlan copyWith({
    String? title,
    List<String>? objectives,
    List<String>? flow,
    bool? favorite,
    bool? archived,
    int? version,
  }) => LessonPlan(
    id: id,
    title: title ?? this.title,
    gradeBand: gradeBand,
    subject: subject,
    topic: topic,
    durationMinutes: durationMinutes,
    objectives: objectives ?? this.objectives,
    materials: materials,
    flow: flow ?? this.flow,
    questions: questions,
    assessment: assessment,
    safetyNotes: safetyNotes,
    sourceExperimentId: sourceExperimentId,
    favorite: favorite ?? this.favorite,
    archived: archived ?? this.archived,
    version: version ?? this.version,
  );

  String toMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# $title')
      ..writeln()
      ..writeln('**$gradeBand | $subject | $durationMinutes minutes**')
      ..writeln()
      ..writeln('## Objectives')
      ..writeln(objectives.map((item) => '- $item').join('\n'))
      ..writeln()
      ..writeln('## Materials')
      ..writeln(materials.map((item) => '- $item').join('\n'))
      ..writeln()
      ..writeln('## Flow')
      ..writeln(flow.map((item) => '- $item').join('\n'))
      ..writeln()
      ..writeln('## Questions')
      ..writeln(questions.map((item) => '- $item').join('\n'))
      ..writeln()
      ..writeln('## Assessment')
      ..writeln(assessment)
      ..writeln()
      ..writeln('## Safety')
      ..writeln(safetyNotes.map((item) => '- $item').join('\n'));
    return buffer.toString();
  }
}

class FeedbackEntry {
  const FeedbackEntry({
    required this.lessonId,
    required this.rating,
    required this.issueType,
    required this.prepTimeImpact,
    required this.comment,
  });

  final String lessonId;
  final int rating;
  final String issueType;
  final String prepTimeImpact;
  final String comment;
}
