// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WithdrawalModelAdapter extends TypeAdapter<WithdrawalModel> {
  @override
  final int typeId = 4;

  @override
  WithdrawalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WithdrawalModel(
      requestId: fields[0] as String,
      uid: fields[1] as String,
      amountCoins: fields[2] as int,
      amountINR: fields[3] as double,
      processingFee: fields[4] as double,
      netAmount: fields[5] as double,
      method: fields[6] as String,
      upiId: fields[7] as String?,
      accountNumber: fields[8] as String?,
      ifscCode: fields[9] as String?,
      accountName: fields[10] as String?,
      status: fields[11] as String,
      submittedAt: fields[12] as DateTime,
      processedAt: fields[13] as DateTime?,
      completedAt: fields[14] as DateTime?,
      rejectionReason: fields[15] as String?,
      transactionId: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WithdrawalModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.requestId)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.amountCoins)
      ..writeByte(3)
      ..write(obj.amountINR)
      ..writeByte(4)
      ..write(obj.processingFee)
      ..writeByte(5)
      ..write(obj.netAmount)
      ..writeByte(6)
      ..write(obj.method)
      ..writeByte(7)
      ..write(obj.upiId)
      ..writeByte(8)
      ..write(obj.accountNumber)
      ..writeByte(9)
      ..write(obj.ifscCode)
      ..writeByte(10)
      ..write(obj.accountName)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.submittedAt)
      ..writeByte(13)
      ..write(obj.processedAt)
      ..writeByte(14)
      ..write(obj.completedAt)
      ..writeByte(15)
      ..write(obj.rejectionReason)
      ..writeByte(16)
      ..write(obj.transactionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WithdrawalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 5;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      transactionId: fields[0] as String,
      uid: fields[1] as String,
      type: fields[2] as String,
      amount: fields[3] as int,
      source: fields[4] as String,
      description: fields[5] as String,
      balanceBefore: fields[6] as int,
      balanceAfter: fields[7] as int,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.transactionId)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.source)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.balanceBefore)
      ..writeByte(7)
      ..write(obj.balanceAfter)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
