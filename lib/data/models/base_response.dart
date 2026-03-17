class BaseResponse<T> {
  final bool isError;
  final String? message;
  final DateTime? timestamp;
  final T? data;

  const BaseResponse({
    required this.isError,
    this.message,
    this.timestamp,
    this.data,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return BaseResponse<T>(
      isError: json['isError'] as bool? ?? false,
      message: json['message'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}
