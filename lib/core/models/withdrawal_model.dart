import 'package:hive/hive.dart';

part 'withdrawal_model.g.dart';

/// Withdrawal status
enum WithdrawalStatus { pending, processing, completed, rejected }

/// Withdrawal method
enum WithdrawalMethod { upi, bank }

/// Model for withdrawal requests
@HiveType(typeId: 4)
class WithdrawalModel {
  @HiveField(0)
  final String requestId;

  @HiveField(1)
  final String uid;

  @HiveField(2)
  final int amountCoins;

  @HiveField(3)
  final double amountINR;

  @HiveField(4)
  final double processingFee;

  @HiveField(5)
  final double netAmount;

  @HiveField(6)
  final String method; // 'upi' or 'bank'

  @HiveField(7)
  final String? upiId;

  @HiveField(8)
  final String? accountNumber;

  @HiveField(9)
  final String? ifscCode;

  @HiveField(10)
  final String? accountName;

  @HiveField(11)
  final String status; // 'pending', 'processing', 'completed', 'rejected'

  @HiveField(12)
  final DateTime submittedAt;

  @HiveField(13)
  final DateTime? processedAt;

  @HiveField(14)
  final DateTime? completedAt;

  @HiveField(15)
  final String? rejectionReason;

  @HiveField(16)
  final String? transactionId;

  WithdrawalModel({
    required this.requestId,
    required this.uid,
    required this.amountCoins,
    required this.amountINR,
    required this.processingFee,
    required this.netAmount,
    required this.method,
    this.upiId,
    this.accountNumber,
    this.ifscCode,
    this.accountName,
    required this.status,
    required this.submittedAt,
    this.processedAt,
    this.completedAt,
    this.rejectionReason,
    this.transactionId,
  });

  WithdrawalModel copyWith({
    String? requestId,
    String? uid,
    int? amountCoins,
    double? amountINR,
    double? processingFee,
    double? netAmount,
    String? method,
    String? upiId,
    String? accountNumber,
    String? ifscCode,
    String? accountName,
    String? status,
    DateTime? submittedAt,
    DateTime? processedAt,
    DateTime? completedAt,
    String? rejectionReason,
    String? transactionId,
  }) {
    return WithdrawalModel(
      requestId: requestId ?? this.requestId,
      uid: uid ?? this.uid,
      amountCoins: amountCoins ?? this.amountCoins,
      amountINR: amountINR ?? this.amountINR,
      processingFee: processingFee ?? this.processingFee,
      netAmount: netAmount ?? this.netAmount,
      method: method ?? this.method,
      upiId: upiId ?? this.upiId,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      accountName: accountName ?? this.accountName,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      processedAt: processedAt ?? this.processedAt,
      completedAt: completedAt ?? this.completedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected';
  bool get isUpi => method == 'upi';
  bool get isBank => method == 'bank';

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  String get paymentDetails {
    if (isUpi && upiId != null) {
      return 'UPI: $upiId';
    } else if (isBank && accountNumber != null) {
      return 'Bank: ****${accountNumber!.substring(accountNumber!.length - 4)}';
    }
    return 'N/A';
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'uid': uid,
      'amountCoins': amountCoins,
      'amountINR': amountINR,
      'processingFee': processingFee,
      'netAmount': netAmount,
      'method': method,
      'upiId': upiId,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'accountName': accountName,
      'status': status,
      'submittedAt': submittedAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'transactionId': transactionId,
    };
  }

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      requestId: json['requestId'] as String,
      uid: json['uid'] as String,
      amountCoins: (json['amountCoins'] as num?)?.toInt() ?? 0,
      amountINR: (json['amountINR'] as num?)?.toDouble() ?? 0,
      processingFee: (json['processingFee'] as num?)?.toDouble() ?? 10,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0,
      method: json['method'] as String? ?? 'upi',
      upiId: json['upiId'] as String?,
      accountNumber: json['accountNumber'] as String?,
      ifscCode: json['ifscCode'] as String?,
      accountName: json['accountName'] as String?,
      status: json['status'] as String? ?? 'pending',
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : DateTime.now(),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      transactionId: json['transactionId'] as String?,
    );
  }
}

/// Transaction model for history
@HiveType(typeId: 5)
class TransactionModel {
  @HiveField(0)
  final String transactionId;

  @HiveField(1)
  final String uid;

  @HiveField(2)
  final String type; // 'earn', 'spend', 'withdraw'

  @HiveField(3)
  final int amount;

  @HiveField(4)
  final String source; // 'tap', 'passive', 'achievement', 'referral', 'purchase', 'upgrade', 'withdrawal'

  @HiveField(5)
  final String description;

  @HiveField(6)
  final int balanceBefore;

  @HiveField(7)
  final int balanceAfter;

  @HiveField(8)
  final DateTime createdAt;

  TransactionModel({
    required this.transactionId,
    required this.uid,
    required this.type,
    required this.amount,
    required this.source,
    required this.description,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.createdAt,
  });

  bool get isEarning => type == 'earn';
  bool get isSpending => type == 'spend';
  bool get isWithdrawal => type == 'withdraw';

  String get typeIcon {
    switch (type) {
      case 'earn':
        return '📈';
      case 'spend':
        return '📉';
      case 'withdraw':
        return '💸';
      default:
        return '💰';
    }
  }

  String get sourceIcon {
    switch (source) {
      case 'tap':
        return '👆';
      case 'passive':
        return '💤';
      case 'achievement':
        return '🏆';
      case 'referral':
        return '👥';
      case 'purchase':
        return '🛒';
      case 'upgrade':
        return '⬆️';
      case 'withdrawal':
        return '🏦';
      case 'daily_bonus':
        return '📅';
      default:
        return '💰';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'uid': uid,
      'type': type,
      'amount': amount,
      'source': source,
      'description': description,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transactionId'] as String,
      uid: json['uid'] as String,
      type: json['type'] as String? ?? 'earn',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      source: json['source'] as String? ?? 'tap',
      description: json['description'] as String? ?? '',
      balanceBefore: (json['balanceBefore'] as num?)?.toInt() ?? 0,
      balanceAfter: (json['balanceAfter'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
