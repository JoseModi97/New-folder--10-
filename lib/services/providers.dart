import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'daraja_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final darajaConfigProvider = Provider<DarajaConfig>((ref) {
  return const DarajaConfig(
    businessShortCode: '174379',
    passkey:
        'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f786b72ada1ed2c919',
    callbackUrl: 'https://mydomain.com/path',
    bearerToken: 'FsboV0UNFQgd4XPitzgNuAGzbl0Y',
    accountReference: 'CompanyXLTD',
    transactionDescription: 'Payment of X',
    defaultMsisdn: '254799213371',
    partyB: '174379',
  );
});

final darajaServiceProvider = Provider<DarajaService>((ref) {
  final config = ref.watch(darajaConfigProvider);
  return DarajaService(config: config);
});

