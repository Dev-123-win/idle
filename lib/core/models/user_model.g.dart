// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      uid: fields[0] as String,
      email: fields[1] as String?,
      phoneNumber: fields[2] as String?,
      displayName: fields[3] as String,
      photoURL: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      referralCode: fields[6] as String,
      referredBy: fields[7] as String?,
      coinBalance: fields[8] as int,
      lifetimeCoinsEarned: fields[9] as int,
      lifetimeCoinsSpent: fields[10] as int,
      totalTaps: fields[11] as int,
      dailyTaps: fields[12] as int,
      lastTapSync: fields[13] as DateTime?,
      tapPower: fields[14] as double,
      passiveRate: fields[15] as double,
      lastPassiveClaim: fields[16] as DateTime?,
      dailyPassiveEarned: fields[17] as int,
      loginStreak: fields[18] as int,
      lastLoginDate: fields[19] as String?,
      adsRemoved: fields[20] as bool,
      vipUntil: fields[21] as DateTime?,
      boostMultiplier: fields[22] as double,
      boostUntil: fields[23] as DateTime?,
      emailVerified: fields[24] as bool,
      totalPassiveEarned: fields[25] as int,
      claimedReferrals: (fields[26] as List).cast<String>(),
      hasPassiveUpgrade: fields[27] as bool,
      ownedUpgrades: (fields[28] as List).cast<OwnedUpgrade>(),
      achievements: (fields[29] as List).cast<AchievementModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(30)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.displayName)
      ..writeByte(4)
      ..write(obj.photoURL)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.referralCode)
      ..writeByte(7)
      ..write(obj.referredBy)
      ..writeByte(8)
      ..write(obj.coinBalance)
      ..writeByte(9)
      ..write(obj.lifetimeCoinsEarned)
      ..writeByte(10)
      ..write(obj.lifetimeCoinsSpent)
      ..writeByte(11)
      ..write(obj.totalTaps)
      ..writeByte(12)
      ..write(obj.dailyTaps)
      ..writeByte(13)
      ..write(obj.lastTapSync)
      ..writeByte(14)
      ..write(obj.tapPower)
      ..writeByte(15)
      ..write(obj.passiveRate)
      ..writeByte(16)
      ..write(obj.lastPassiveClaim)
      ..writeByte(17)
      ..write(obj.dailyPassiveEarned)
      ..writeByte(18)
      ..write(obj.loginStreak)
      ..writeByte(19)
      ..write(obj.lastLoginDate)
      ..writeByte(20)
      ..write(obj.adsRemoved)
      ..writeByte(21)
      ..write(obj.vipUntil)
      ..writeByte(22)
      ..write(obj.boostMultiplier)
      ..writeByte(23)
      ..write(obj.boostUntil)
      ..writeByte(24)
      ..write(obj.emailVerified)
      ..writeByte(25)
      ..write(obj.totalPassiveEarned)
      ..writeByte(26)
      ..write(obj.claimedReferrals)
      ..writeByte(27)
      ..write(obj.hasPassiveUpgrade)
      ..writeByte(28)
      ..write(obj.ownedUpgrades)
      ..writeByte(29)
      ..write(obj.achievements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
