import 'package:dio/dio.dart';
import '../../core/env.dart';

/// Payment service for Midtrans integration
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  late final Dio _dio = Dio(BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  /// Create a new payment transaction
  /// Returns: { orderId, token, redirectUrl, paymentId }
  Future<PaymentResponse> createPayment({
    required int movieId,
    required String movieTitle,
    required int? showtimeId,
    required String cinema,
    required List<String> seats,
    required int amount,
    required String customerName,
    required String customerEmail,
    String? customerPhone,
  }) async {
    try {
      final response = await _dio.post('/api/payments/create', data: {
        'movieId': movieId,
        'movieTitle': movieTitle,
        'showtimeId': showtimeId,
        'cinema': cinema,
        'seats': seats,
        'amount': amount,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
      });

      return PaymentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw PaymentException(
        message: e.response?.data?['message'] ?? 'Failed to create payment',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Check payment status by order ID
  Future<PaymentStatus> checkStatus(String orderId) async {
    try {
      final response = await _dio.get('/api/payments/$orderId/status');
      return PaymentStatus.fromJson(response.data);
    } on DioException catch (e) {
      throw PaymentException(
        message: e.response?.data?['message'] ?? 'Failed to check payment status',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Poll payment status until it changes from pending
  Stream<PaymentStatus> pollStatus(String orderId, {Duration interval = const Duration(seconds: 3)}) async* {
    while (true) {
      await Future.delayed(interval);
      try {
        final status = await checkStatus(orderId);
        yield status;
        if (status.status != 'pending') {
          break;
        }
      } catch (e) {
        // Continue polling even on error
      }
    }
  }
}

/// Payment creation response
class PaymentResponse {
  final String orderId;
  final String token;
  final String redirectUrl;
  final int paymentId;

  PaymentResponse({
    required this.orderId,
    required this.token,
    required this.redirectUrl,
    required this.paymentId,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      orderId: json['orderId'] as String,
      token: json['token'] as String,
      redirectUrl: json['redirectUrl'] as String,
      paymentId: json['paymentId'] as int,
    );
  }
}

/// Payment status response
class PaymentStatus {
  final String orderId;
  final String status;
  final int amount;
  final String? paymentType;
  final String? movieTitle;
  final String? cinema;
  final List<String> seats;
  final String? paidAt;
  final String createdAt;

  PaymentStatus({
    required this.orderId,
    required this.status,
    required this.amount,
    this.paymentType,
    this.movieTitle,
    this.cinema,
    required this.seats,
    this.paidAt,
    required this.createdAt,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      orderId: json['orderId'] as String,
      status: json['status'] as String,
      amount: json['amount'] as int,
      paymentType: json['paymentType'] as String?,
      movieTitle: json['movieTitle'] as String?,
      cinema: json['cinema'] as String?,
      seats: (json['seats'] as List<dynamic>).cast<String>(),
      paidAt: json['paidAt'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed' || status == 'expired';
}

/// Payment exception
class PaymentException implements Exception {
  final String message;
  final int? statusCode;

  PaymentException({required this.message, this.statusCode});

  @override
  String toString() => 'PaymentException: $message (status: $statusCode)';
}
