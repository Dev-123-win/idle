import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/models/withdrawal_model.dart';

/// Withdrawal history screen showing all transaction history
class WithdrawalHistoryScreen extends ConsumerWidget {
  const WithdrawalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view history')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Withdrawal History', style: AppTextStyles.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('withdrawalRequests')
            .where('uid', isEqualTo: user.uid)
            .orderBy('submittedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              // Add ID from doc if needed, though model usually has it
              // WithdrawalModel.fromMap needs to handle timestamps properly
              final withdrawal = _mapToWithdrawal(data);

              return _WithdrawalCard(
                    withdrawal: withdrawal,
                    onTap: () => _showWithdrawalDetails(context, withdrawal),
                  )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: index * 100))
                  .slideX(begin: 0.1, end: 0);
            },
          );
        },
      ),
    );
  }

  WithdrawalModel _mapToWithdrawal(Map<String, dynamic> data) {
    // Helper to safety parse timestamps
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return WithdrawalModel(
      requestId: data['requestId'] ?? '',
      uid: data['uid'] ?? '',
      amountCoins: data['amount'] ?? 0,
      amountINR: (data['amountINR'] ?? 0).toDouble(),
      processingFee: (data['processingFee'] ?? 0).toDouble(),
      netAmount: (data['netAmount'] ?? 0).toDouble(),
      method: data['method'] ?? 'bank',
      upiId: data['upiId'],
      accountNumber: data['accountNumber'],
      status: data['status'] ?? 'pending',
      submittedAt: parseDate(data['submittedAt']),
      processedAt: data['processedAt'] != null
          ? parseDate(data['processedAt'])
          : null,
      completedAt: data['completedAt'] != null
          ? parseDate(data['completedAt'])
          : null,
      transactionId: data['transactionId'],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text('No withdrawals yet', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Your withdrawal history will appear here',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showWithdrawalDetails(
    BuildContext context,
    WithdrawalModel withdrawal,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _WithdrawalDetailsSheet(withdrawal: withdrawal),
    );
  }
}

class _WithdrawalCard extends StatelessWidget {
  final WithdrawalModel withdrawal;
  final VoidCallback onTap;

  const _WithdrawalCard({required this.withdrawal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '₹${withdrawal.netAmount.toStringAsFixed(0)}',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: withdrawal.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${withdrawal.method.toUpperCase()} • ${DateFormat('MMM dd, yyyy').format(withdrawal.submittedAt)}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (withdrawal.status) {
      case 'completed':
        return AppColors.success;
      case 'processing':
        return AppColors.info;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.coinGold;
    }
  }

  IconData _getStatusIcon() {
    switch (withdrawal.status) {
      case 'completed':
        return Icons.check_circle;
      case 'processing':
        return Icons.sync;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: _getColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'processing':
        return AppColors.info;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.coinGold;
    }
  }
}

class _WithdrawalDetailsSheet extends StatelessWidget {
  final WithdrawalModel withdrawal;

  const _WithdrawalDetailsSheet({required this.withdrawal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Status icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_getStatusIcon(), color: _getStatusColor(), size: 40),
            ),
            const SizedBox(height: 16),

            // Amount
            Text(
              '₹${withdrawal.netAmount.toStringAsFixed(2)}',
              style: AppTextStyles.displaySmall.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            _StatusBadge(status: withdrawal.status),

            const SizedBox(height: 32),

            // Timeline
            _buildTimeline(),

            const SizedBox(height: 24),

            // Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _DetailRow(label: 'Request ID', value: withdrawal.requestId),
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'Amount',
                    value: '₹${withdrawal.amountINR.toStringAsFixed(2)}',
                  ),
                  _DetailRow(
                    label: 'Processing Fee',
                    value: '-₹${withdrawal.processingFee.toStringAsFixed(2)}',
                    valueColor: AppColors.error,
                  ),
                  _DetailRow(
                    label: 'Net Amount',
                    value: '₹${withdrawal.netAmount.toStringAsFixed(2)}',
                    valueColor: AppColors.success,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'Method',
                    value: withdrawal.method.toUpperCase(),
                  ),
                  if (withdrawal.upiId != null)
                    _DetailRow(label: 'UPI ID', value: withdrawal.upiId!),
                  if (withdrawal.accountNumber != null)
                    _DetailRow(
                      label: 'Account',
                      value: withdrawal.accountNumber!,
                    ),
                  if (withdrawal.transactionId != null) ...[
                    const Divider(height: 24),
                    _DetailRow(
                      label: 'Transaction ID',
                      value: withdrawal.transactionId!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Support button
            if (withdrawal.status == 'pending' ||
                withdrawal.status == 'processing')
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.support_agent),
                label: const Text('Contact Support'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final steps = <_TimelineStep>[
      _TimelineStep(
        title: 'Request Submitted',
        date: withdrawal.submittedAt,
        isComplete: true,
      ),
      _TimelineStep(
        title: 'Under Review',
        date: withdrawal.status != 'pending' ? withdrawal.submittedAt : null,
        isComplete: withdrawal.status != 'pending',
      ),
      _TimelineStep(
        title: 'Processing Payment',
        date:
            withdrawal.status == 'processing' ||
                withdrawal.status == 'completed'
            ? withdrawal.processedAt
            : null,
        isComplete:
            withdrawal.status == 'processing' ||
            withdrawal.status == 'completed',
      ),
      _TimelineStep(
        title: 'Completed',
        date: withdrawal.status == 'completed' ? withdrawal.completedAt : null,
        isComplete: withdrawal.status == 'completed',
      ),
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final isLast = entry.key == steps.length - 1;
        return _TimelineStepWidget(step: entry.value, isLast: isLast);
      }).toList(),
    );
  }

  Color _getStatusColor() {
    switch (withdrawal.status) {
      case 'completed':
        return AppColors.success;
      case 'processing':
        return AppColors.info;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.coinGold;
    }
  }

  IconData _getStatusIcon() {
    switch (withdrawal.status) {
      case 'completed':
        return Icons.check_circle;
      case 'processing':
        return Icons.sync;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String title;
  final DateTime? date;
  final bool isComplete;

  _TimelineStep({required this.title, this.date, required this.isComplete});
}

class _TimelineStepWidget extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;

  const _TimelineStepWidget({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: step.isComplete ? AppColors.success : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.isComplete
                      ? AppColors.success
                      : AppColors.cardBorder,
                  width: 2,
                ),
              ),
              child: step.isComplete
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: step.isComplete
                    ? AppColors.success
                    : AppColors.cardBorder,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: step.isComplete ? null : AppColors.textMuted,
                  ),
                ),
                if (step.date != null)
                  Text(
                    DateFormat('MMM dd, yyyy • HH:mm').format(step.date!),
                    style: AppTextStyles.bodySmall,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
