import 'dart:convert';

import 'package:dio/dio.dart';

/// Configuration needed to initiate a Daraja STK push payment.
class DarajaConfig {
  const DarajaConfig({
    required this.businessShortCode,
    required this.passkey,
    required this.callbackUrl,
    required this.bearerToken,
    this.transactionType = 'CustomerPayBillOnline',
    this.accountReference = 'CompanyXLTD',
    this.transactionDescription = 'Payment of goods',
    this.partyB,
    this.defaultMsisdn,
  });

  final String businessShortCode;
  final String passkey;
  final String callbackUrl;
  final String bearerToken;
  final String transactionType;
  final String accountReference;
  final String transactionDescription;
  final String? partyB;
  final String? defaultMsisdn;
}

/// Exception thrown when the Daraja API indicates a failure.
class DarajaException implements Exception {
  DarajaException(this.message);
  final String message;

  @override
  String toString() => 'DarajaException: $message';
}

/// Simple receipt generated after a successful STK push initiation.
class DarajaReceipt {
  const DarajaReceipt({
    required this.amount,
    required this.phoneNumber,
    required this.timestamp,
    required this.merchantRequestId,
    required this.checkoutRequestId,
    required this.responseDescription,
  });

  final double amount;
  final String phoneNumber;
  final DateTime timestamp;
  final String merchantRequestId;
  final String checkoutRequestId;
  final String responseDescription;
}

/// Handles communication with the Daraja STK push API.
class DarajaService {
  DarajaService({
    Dio? dio,
    required DarajaConfig config,
  })  : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://sandbox.safaricom.co.ke/mpesa')),
        _config = config;

  final Dio _dio;
  final DarajaConfig _config;

  /// Initiates an STK push request using the configured Daraja credentials.
  Future<DarajaReceipt> initiateStkPush({
    required double amount,
    String? phoneNumber,
  }) async {
    if (amount <= 0) {
      throw DarajaException('Amount must be greater than zero.');
    }

    final payer = phoneNumber ?? _config.defaultMsisdn;
    if (payer == null || payer.isEmpty) {
      throw DarajaException('A phone number is required for payment.');
    }

    final sanitizedPayer = payer.replaceAll(RegExp(r'\D'), '');
    if (sanitizedPayer.isEmpty) {
      throw DarajaException('Phone number contains invalid characters.');
    }

    final timestamp = _generateTimestamp(DateTime.now().toUtc());
    final password = base64Encode(utf8.encode('${_config.businessShortCode}${_config.passkey}$timestamp'));

    final body = <String, dynamic>{
      'BusinessShortCode': _config.businessShortCode,
      'Password': password,
      'Timestamp': timestamp,
      'TransactionType': _config.transactionType,
      'Amount': amount.round(),
      'PartyA': sanitizedPayer,
      'PartyB': _config.partyB ?? _config.businessShortCode,
      'PhoneNumber': sanitizedPayer,
      'CallBackURL': _config.callbackUrl,
      'AccountReference': _config.accountReference,
      'TransactionDesc': _config.transactionDescription,
    };

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/stkpush/v1/processrequest',
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_config.bearerToken}',
          },
        ),
      );

      final data = response.data ?? const <String, dynamic>{};
      final responseCode = data['ResponseCode']?.toString();
      if (responseCode != '0') {
        final description = data['ResponseDescription']?.toString() ?? 'Unknown error';
        throw DarajaException(description);
      }

      return DarajaReceipt(
        amount: amount,
        phoneNumber: sanitizedPayer,
        timestamp: DateTime.now(),
        merchantRequestId: data['MerchantRequestID']?.toString() ?? '',
        checkoutRequestId: data['CheckoutRequestID']?.toString() ?? '',
        responseDescription: data['ResponseDescription']?.toString() ?? '',
      );
    } on DioException catch (error) {
      final isNetworkError = error.type == DioExceptionType.connectionError ||
          (error.message?.toLowerCase().contains('xmlhttprequest') ?? false);

      if (isNetworkError) {
        throw DarajaException(
          'Unable to reach the Safaricom Daraja service. Verify your Daraja sandbox credentials and availability, then try again.',
        );
      }

      final message = error.response?.data is Map<String, dynamic>
          ? (error.response!.data['errorMessage']?.toString() ?? error.message)
          : error.message;
      throw DarajaException(message ?? 'Failed to initiate payment.');
    }
  }

  String _generateTimestamp(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    final h = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    final s = dateTime.second.toString().padLeft(2, '0');
    return '$y$m$d$h$min$s';
  }
}

