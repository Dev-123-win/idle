// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upgrade_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpgradeModelAdapter extends TypeAdapter<UpgradeModel> {
  @override
  final int typeId = 1;

  @override
  UpgradeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpgradeModel(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      tier: fields[3] as int,
      baseCost: fields[4] as int,
      baseEffect: fields[5] as double,
      type: fields[6] as String,
      level: fields[7] as int,
      unlocked: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UpgradeModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.tier)
      ..writeByte(4)
      ..write(obj.baseCost)
      ..writeByte(5)
      ..write(obj.baseEffect)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.level)
      ..writeByte(8)
      ..write(obj.unlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpgradeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OwnedUpgradeAdapter extends TypeAdapter<OwnedUpgrade> {
  @override
  final int typeId = 2;

  @override
  OwnedUpgrade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OwnedUpgrade(
      upgradeId: fields[0] as String,
      tier: fields[1] as int,
      level: fields[2] as int,
      purchasedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, OwnedUpgrade obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.upgradeId)
      ..writeByte(1)
      ..write(obj.tier)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.purchasedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedUpgradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
