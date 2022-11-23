import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  //create credentials
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "expenses-369306",
  "private_key_id": "1f543bc49e6935847d127765c4dfa7d97bbcdaa7",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCeiq6gaOKziHb6\ne+M4v2pUyxgf/52L0UEnkffc4a/MDt/EdMZafRZaaQhN+8Du+gFAx4p/qtLIw17X\nqpGOyoKwAw5gxVyNrl0lhBxyNZTLwN92WowX9K8mNxpJEM9AyvEYNdos7whIAncq\ncmlAYjCU7q1zX5UIF8XXY23SWJfXYxoS3UyxgYtMT2McpAZ4+9CreN7YViwm5lPO\nqWiFDaWshPX7WU+CGQm2G2J2iG1V60wG2yoIDVFb52W+YS0WPHBBwsKiYCKyWoyl\nyfpzac9FfNjR2smuwhTRuiZdH7QQKe8wZenarmOv0xwzd1qhNS77dYjbqntF9kst\n8fbMPoX7AgMBAAECggEANEBxyFV5LgGScQCmxTu1EEg1ZcppwryPNDr0DXzmYyMd\n1dJE02r5lIecYJNSJZEJG7AIMgZ7XQai+gJx4bVVuCvxr6wsUle+xFATzgJhzXt+\nSrQSCw0uMrKje6RKIkkgh8Gr6/ZF7PG/E6LMlJcn+tXlHarJY/bt0gynk9V2CdrP\nK4WF28zKCj2hGSAVpyat3vAyG1+Pn52MlGlC9xSMth+d01IPt6Seo+F3OVIwG33n\naK7OvrL11ZowfVIP0j2n8IVwvfh81wc9nP10PEhPF2XUCCE+fkoZ01BgSbsVA5Sk\nGu6+F3ceY1S1whxEBK5kLzQ7Bov5dqOpsRL5pSDXEQKBgQDU8mLRVS9nWjcSN7nd\nwf7lmnNIFtOCxcg2JYRVmo2JZaNPSAvEk7d757k8ZYVAVGBnapAZ5oTd9NzDwfg2\nz4bI9vxtMnJGKB39vX6ppIiYuhvv4/6O6UroXhy773h0+dNgJEI5D3dYQsarRO++\nAJJID1Pfb4JjJ9B5SDQmvhdLMQKBgQC+mGtv4MXFiwtvRKdsHvf5wwEhx9BRGkaC\n8w//EMneY5JRz29tb0rrP5NsNDVVuMzMRWog16gBtdKEjRUWuUdHRqJDvLRZ7er7\n+tL/AgPk1VxIT0OB7l24RzDUzkqJRI278UEyOPUQyibdSTjPuoK2mB5jTVFAJyRa\nLSF5goSA6wKBgQCNdoxBBjcckKj/GDgIYoTD4QvuewN934g2uEumVqrp+LQ5yeHP\ncFY3IOREhCi2aJc2fGtIWYQwsycpgKU1PD4NKU7d9+JESwhJdWY8qkn4M8K1ZZ/J\nLqANp9+s1dQO2ZwbRVsc7vJYltvGEWC2t0h2SIBucXSMDHoI5/eFOUjeMQKBgQCb\nZPgLkm6M/i3HfWknbSRu/X/Zw+jjhxHASF5dbpm3+OTeUMsfpWKm5QHUccieaHqJ\nfXrm5g1zv4OxULnF+i/UPBGmOp+sxp8U7M7E3SbBlveTeRSoRekhiuGUT9FTk5If\njrbCNNAR7U+8kauBKibSqrnz6qD5NjCcWTl2sWRJGwKBgGNGsbj8Z8CogkeSbtym\nfoZQgAA7PiUMv2FM9987JooCCvgCBBybFT5YGDcjGJZoGCMFw/8ImIURGlHysoiC\nL/ucIHdHNiQjAheUEcg6B+YouhKx4GGrKKGLO352379UOpzo/vKz/M41ite88DlS\nC6AtpscvOTlaUcKpp/2+17ds\n-----END PRIVATE KEY-----\n",
  "client_email": "expenses@expenses-369306.iam.gserviceaccount.com",
  "client_id": "108208861567294163266",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/expenses%40expenses-369306.iam.gserviceaccount.com"
}
  ''';

  //set up & connect to the spreadsheet
  static final _spreadsheetId = '1zv5y2B1Tce31FpIRumni_WMWiE8GPO7Dgp2brJm9Z7c';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  // some variables to keep track of:
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  //initialize the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Transactions');
    countRows();
  }

  // count the number of notes:
  static Future countRows() async {
    while ((await _worksheet!.values
            .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    loadTransactions();
  }

  // load existing notes from spreadsheet:
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
          await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
          await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
          await _worksheet!.values.value(column: 3, row: i + 1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    print(currentTransactions);
    loading = false;
  }

  // insert a new transaction:
  static Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'Credit' : 'Debit',
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'Credit' : 'Debit',
    ]);
  }

  // CALCULATE THE TOTAL INCOME!
  static double calculateCredit() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'Credit') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateDebit() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'Debit') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}
