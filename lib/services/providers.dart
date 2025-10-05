import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'daraja_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

String _requireEnv(String key) {
  final value = dotenv.maybeGet(key);
  if (value == null || value.isEmpty) {
    throw StateError('Missing environment value for $key.');
  }
  return value;
}

final darajaConfigProvider = Provider<DarajaConfig>((ref) {
  return DarajaConfig(
    businessShortCode: _requireEnv('DARAJA_BUSINESS_SHORT_CODE'),
    passkey: _requireEnv('DARAJA_PASSKEY'),
    callbackUrl: _requireEnv('DARAJA_CALLBACK_URL'),
    bearerToken: _requireEnv('DARAJA_BEARER_TOKEN'),
    accountReference: dotenv.maybeGet('DARAJA_ACCOUNT_REFERENCE') ?? 'CompanyXLTD',
    transactionDescription:
        dotenv.maybeGet('DARAJA_TRANSACTION_DESCRIPTION') ?? 'Payment of goods',
    transactionType:
        dotenv.maybeGet('DARAJA_TRANSACTION_TYPE') ?? 'CustomerPayBillOnline',
    defaultMsisdn: dotenv.maybeGet('DARAJA_DEFAULT_MSISDN'),
    partyB: dotenv.maybeGet('DARAJA_PARTY_B'),
  );
});

final darajaServiceProvider = Provider<DarajaService>((ref) {
  final config = ref.watch(darajaConfigProvider);
  return DarajaService(config: config);
});

