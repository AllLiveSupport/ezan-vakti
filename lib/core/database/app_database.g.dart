// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PrayerTimesTableTable extends PrayerTimesTable
    with TableInfo<$PrayerTimesTableTable, PrayerTimesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerTimesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cityIdMeta = const VerificationMeta('cityId');
  @override
  late final GeneratedColumn<String> cityId = GeneratedColumn<String>(
    'city_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fajrMeta = const VerificationMeta('fajr');
  @override
  late final GeneratedColumn<String> fajr = GeneratedColumn<String>(
    'fajr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sunriseMeta = const VerificationMeta(
    'sunrise',
  );
  @override
  late final GeneratedColumn<String> sunrise = GeneratedColumn<String>(
    'sunrise',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dhuhrMeta = const VerificationMeta('dhuhr');
  @override
  late final GeneratedColumn<String> dhuhr = GeneratedColumn<String>(
    'dhuhr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _asrMeta = const VerificationMeta('asr');
  @override
  late final GeneratedColumn<String> asr = GeneratedColumn<String>(
    'asr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maghribMeta = const VerificationMeta(
    'maghrib',
  );
  @override
  late final GeneratedColumn<String> maghrib = GeneratedColumn<String>(
    'maghrib',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ishaMeta = const VerificationMeta('isha');
  @override
  late final GeneratedColumn<String> isha = GeneratedColumn<String>(
    'isha',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hijriDateMeta = const VerificationMeta(
    'hijriDate',
  );
  @override
  late final GeneratedColumn<String> hijriDate = GeneratedColumn<String>(
    'hijri_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _calculationMethodMeta = const VerificationMeta(
    'calculationMethod',
  );
  @override
  late final GeneratedColumn<String> calculationMethod =
      GeneratedColumn<String>(
        'calculation_method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('Turkey'),
      );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cityId,
    date,
    fajr,
    sunrise,
    dhuhr,
    asr,
    maghrib,
    isha,
    hijriDate,
    calculationMethod,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_times';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerTimesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('city_id')) {
      context.handle(
        _cityIdMeta,
        cityId.isAcceptableOrUnknown(data['city_id']!, _cityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cityIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('fajr')) {
      context.handle(
        _fajrMeta,
        fajr.isAcceptableOrUnknown(data['fajr']!, _fajrMeta),
      );
    } else if (isInserting) {
      context.missing(_fajrMeta);
    }
    if (data.containsKey('sunrise')) {
      context.handle(
        _sunriseMeta,
        sunrise.isAcceptableOrUnknown(data['sunrise']!, _sunriseMeta),
      );
    } else if (isInserting) {
      context.missing(_sunriseMeta);
    }
    if (data.containsKey('dhuhr')) {
      context.handle(
        _dhuhrMeta,
        dhuhr.isAcceptableOrUnknown(data['dhuhr']!, _dhuhrMeta),
      );
    } else if (isInserting) {
      context.missing(_dhuhrMeta);
    }
    if (data.containsKey('asr')) {
      context.handle(
        _asrMeta,
        asr.isAcceptableOrUnknown(data['asr']!, _asrMeta),
      );
    } else if (isInserting) {
      context.missing(_asrMeta);
    }
    if (data.containsKey('maghrib')) {
      context.handle(
        _maghribMeta,
        maghrib.isAcceptableOrUnknown(data['maghrib']!, _maghribMeta),
      );
    } else if (isInserting) {
      context.missing(_maghribMeta);
    }
    if (data.containsKey('isha')) {
      context.handle(
        _ishaMeta,
        isha.isAcceptableOrUnknown(data['isha']!, _ishaMeta),
      );
    } else if (isInserting) {
      context.missing(_ishaMeta);
    }
    if (data.containsKey('hijri_date')) {
      context.handle(
        _hijriDateMeta,
        hijriDate.isAcceptableOrUnknown(data['hijri_date']!, _hijriDateMeta),
      );
    }
    if (data.containsKey('calculation_method')) {
      context.handle(
        _calculationMethodMeta,
        calculationMethod.isAcceptableOrUnknown(
          data['calculation_method']!,
          _calculationMethodMeta,
        ),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {cityId, date},
  ];
  @override
  PrayerTimesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerTimesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      fajr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fajr'],
      )!,
      sunrise: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sunrise'],
      )!,
      dhuhr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dhuhr'],
      )!,
      asr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asr'],
      )!,
      maghrib: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maghrib'],
      )!,
      isha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isha'],
      )!,
      hijriDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hijri_date'],
      )!,
      calculationMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calculation_method'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $PrayerTimesTableTable createAlias(String alias) {
    return $PrayerTimesTableTable(attachedDatabase, alias);
  }
}

class PrayerTimesTableData extends DataClass
    implements Insertable<PrayerTimesTableData> {
  final int id;
  final String cityId;
  final String date;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String hijriDate;
  final String calculationMethod;
  final int fetchedAt;
  const PrayerTimesTableData({
    required this.id,
    required this.cityId,
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriDate,
    required this.calculationMethod,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['city_id'] = Variable<String>(cityId);
    map['date'] = Variable<String>(date);
    map['fajr'] = Variable<String>(fajr);
    map['sunrise'] = Variable<String>(sunrise);
    map['dhuhr'] = Variable<String>(dhuhr);
    map['asr'] = Variable<String>(asr);
    map['maghrib'] = Variable<String>(maghrib);
    map['isha'] = Variable<String>(isha);
    map['hijri_date'] = Variable<String>(hijriDate);
    map['calculation_method'] = Variable<String>(calculationMethod);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  PrayerTimesTableCompanion toCompanion(bool nullToAbsent) {
    return PrayerTimesTableCompanion(
      id: Value(id),
      cityId: Value(cityId),
      date: Value(date),
      fajr: Value(fajr),
      sunrise: Value(sunrise),
      dhuhr: Value(dhuhr),
      asr: Value(asr),
      maghrib: Value(maghrib),
      isha: Value(isha),
      hijriDate: Value(hijriDate),
      calculationMethod: Value(calculationMethod),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory PrayerTimesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerTimesTableData(
      id: serializer.fromJson<int>(json['id']),
      cityId: serializer.fromJson<String>(json['cityId']),
      date: serializer.fromJson<String>(json['date']),
      fajr: serializer.fromJson<String>(json['fajr']),
      sunrise: serializer.fromJson<String>(json['sunrise']),
      dhuhr: serializer.fromJson<String>(json['dhuhr']),
      asr: serializer.fromJson<String>(json['asr']),
      maghrib: serializer.fromJson<String>(json['maghrib']),
      isha: serializer.fromJson<String>(json['isha']),
      hijriDate: serializer.fromJson<String>(json['hijriDate']),
      calculationMethod: serializer.fromJson<String>(json['calculationMethod']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cityId': serializer.toJson<String>(cityId),
      'date': serializer.toJson<String>(date),
      'fajr': serializer.toJson<String>(fajr),
      'sunrise': serializer.toJson<String>(sunrise),
      'dhuhr': serializer.toJson<String>(dhuhr),
      'asr': serializer.toJson<String>(asr),
      'maghrib': serializer.toJson<String>(maghrib),
      'isha': serializer.toJson<String>(isha),
      'hijriDate': serializer.toJson<String>(hijriDate),
      'calculationMethod': serializer.toJson<String>(calculationMethod),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  PrayerTimesTableData copyWith({
    int? id,
    String? cityId,
    String? date,
    String? fajr,
    String? sunrise,
    String? dhuhr,
    String? asr,
    String? maghrib,
    String? isha,
    String? hijriDate,
    String? calculationMethod,
    int? fetchedAt,
  }) => PrayerTimesTableData(
    id: id ?? this.id,
    cityId: cityId ?? this.cityId,
    date: date ?? this.date,
    fajr: fajr ?? this.fajr,
    sunrise: sunrise ?? this.sunrise,
    dhuhr: dhuhr ?? this.dhuhr,
    asr: asr ?? this.asr,
    maghrib: maghrib ?? this.maghrib,
    isha: isha ?? this.isha,
    hijriDate: hijriDate ?? this.hijriDate,
    calculationMethod: calculationMethod ?? this.calculationMethod,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  PrayerTimesTableData copyWithCompanion(PrayerTimesTableCompanion data) {
    return PrayerTimesTableData(
      id: data.id.present ? data.id.value : this.id,
      cityId: data.cityId.present ? data.cityId.value : this.cityId,
      date: data.date.present ? data.date.value : this.date,
      fajr: data.fajr.present ? data.fajr.value : this.fajr,
      sunrise: data.sunrise.present ? data.sunrise.value : this.sunrise,
      dhuhr: data.dhuhr.present ? data.dhuhr.value : this.dhuhr,
      asr: data.asr.present ? data.asr.value : this.asr,
      maghrib: data.maghrib.present ? data.maghrib.value : this.maghrib,
      isha: data.isha.present ? data.isha.value : this.isha,
      hijriDate: data.hijriDate.present ? data.hijriDate.value : this.hijriDate,
      calculationMethod: data.calculationMethod.present
          ? data.calculationMethod.value
          : this.calculationMethod,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerTimesTableData(')
          ..write('id: $id, ')
          ..write('cityId: $cityId, ')
          ..write('date: $date, ')
          ..write('fajr: $fajr, ')
          ..write('sunrise: $sunrise, ')
          ..write('dhuhr: $dhuhr, ')
          ..write('asr: $asr, ')
          ..write('maghrib: $maghrib, ')
          ..write('isha: $isha, ')
          ..write('hijriDate: $hijriDate, ')
          ..write('calculationMethod: $calculationMethod, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cityId,
    date,
    fajr,
    sunrise,
    dhuhr,
    asr,
    maghrib,
    isha,
    hijriDate,
    calculationMethod,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerTimesTableData &&
          other.id == this.id &&
          other.cityId == this.cityId &&
          other.date == this.date &&
          other.fajr == this.fajr &&
          other.sunrise == this.sunrise &&
          other.dhuhr == this.dhuhr &&
          other.asr == this.asr &&
          other.maghrib == this.maghrib &&
          other.isha == this.isha &&
          other.hijriDate == this.hijriDate &&
          other.calculationMethod == this.calculationMethod &&
          other.fetchedAt == this.fetchedAt);
}

class PrayerTimesTableCompanion extends UpdateCompanion<PrayerTimesTableData> {
  final Value<int> id;
  final Value<String> cityId;
  final Value<String> date;
  final Value<String> fajr;
  final Value<String> sunrise;
  final Value<String> dhuhr;
  final Value<String> asr;
  final Value<String> maghrib;
  final Value<String> isha;
  final Value<String> hijriDate;
  final Value<String> calculationMethod;
  final Value<int> fetchedAt;
  const PrayerTimesTableCompanion({
    this.id = const Value.absent(),
    this.cityId = const Value.absent(),
    this.date = const Value.absent(),
    this.fajr = const Value.absent(),
    this.sunrise = const Value.absent(),
    this.dhuhr = const Value.absent(),
    this.asr = const Value.absent(),
    this.maghrib = const Value.absent(),
    this.isha = const Value.absent(),
    this.hijriDate = const Value.absent(),
    this.calculationMethod = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  PrayerTimesTableCompanion.insert({
    this.id = const Value.absent(),
    required String cityId,
    required String date,
    required String fajr,
    required String sunrise,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
    this.hijriDate = const Value.absent(),
    this.calculationMethod = const Value.absent(),
    required int fetchedAt,
  }) : cityId = Value(cityId),
       date = Value(date),
       fajr = Value(fajr),
       sunrise = Value(sunrise),
       dhuhr = Value(dhuhr),
       asr = Value(asr),
       maghrib = Value(maghrib),
       isha = Value(isha),
       fetchedAt = Value(fetchedAt);
  static Insertable<PrayerTimesTableData> custom({
    Expression<int>? id,
    Expression<String>? cityId,
    Expression<String>? date,
    Expression<String>? fajr,
    Expression<String>? sunrise,
    Expression<String>? dhuhr,
    Expression<String>? asr,
    Expression<String>? maghrib,
    Expression<String>? isha,
    Expression<String>? hijriDate,
    Expression<String>? calculationMethod,
    Expression<int>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cityId != null) 'city_id': cityId,
      if (date != null) 'date': date,
      if (fajr != null) 'fajr': fajr,
      if (sunrise != null) 'sunrise': sunrise,
      if (dhuhr != null) 'dhuhr': dhuhr,
      if (asr != null) 'asr': asr,
      if (maghrib != null) 'maghrib': maghrib,
      if (isha != null) 'isha': isha,
      if (hijriDate != null) 'hijri_date': hijriDate,
      if (calculationMethod != null) 'calculation_method': calculationMethod,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  PrayerTimesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? cityId,
    Value<String>? date,
    Value<String>? fajr,
    Value<String>? sunrise,
    Value<String>? dhuhr,
    Value<String>? asr,
    Value<String>? maghrib,
    Value<String>? isha,
    Value<String>? hijriDate,
    Value<String>? calculationMethod,
    Value<int>? fetchedAt,
  }) {
    return PrayerTimesTableCompanion(
      id: id ?? this.id,
      cityId: cityId ?? this.cityId,
      date: date ?? this.date,
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      hijriDate: hijriDate ?? this.hijriDate,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cityId.present) {
      map['city_id'] = Variable<String>(cityId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (fajr.present) {
      map['fajr'] = Variable<String>(fajr.value);
    }
    if (sunrise.present) {
      map['sunrise'] = Variable<String>(sunrise.value);
    }
    if (dhuhr.present) {
      map['dhuhr'] = Variable<String>(dhuhr.value);
    }
    if (asr.present) {
      map['asr'] = Variable<String>(asr.value);
    }
    if (maghrib.present) {
      map['maghrib'] = Variable<String>(maghrib.value);
    }
    if (isha.present) {
      map['isha'] = Variable<String>(isha.value);
    }
    if (hijriDate.present) {
      map['hijri_date'] = Variable<String>(hijriDate.value);
    }
    if (calculationMethod.present) {
      map['calculation_method'] = Variable<String>(calculationMethod.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerTimesTableCompanion(')
          ..write('id: $id, ')
          ..write('cityId: $cityId, ')
          ..write('date: $date, ')
          ..write('fajr: $fajr, ')
          ..write('sunrise: $sunrise, ')
          ..write('dhuhr: $dhuhr, ')
          ..write('asr: $asr, ')
          ..write('maghrib: $maghrib, ')
          ..write('isha: $isha, ')
          ..write('hijriDate: $hijriDate, ')
          ..write('calculationMethod: $calculationMethod, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $SavedLocationsTableTable extends SavedLocationsTable
    with TableInfo<$SavedLocationsTableTable, SavedLocationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedLocationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cityIdMeta = const VerificationMeta('cityId');
  @override
  late final GeneratedColumn<String> cityId = GeneratedColumn<String>(
    'city_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cityId,
    name,
    latitude,
    longitude,
    timezone,
    region,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedLocationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('city_id')) {
      context.handle(
        _cityIdMeta,
        cityId.isAcceptableOrUnknown(data['city_id']!, _cityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cityIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedLocationsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedLocationsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SavedLocationsTableTable createAlias(String alias) {
    return $SavedLocationsTableTable(attachedDatabase, alias);
  }
}

class SavedLocationsTableData extends DataClass
    implements Insertable<SavedLocationsTableData> {
  final int id;
  final String cityId;
  final String name;
  final double latitude;
  final double longitude;
  final String timezone;
  final String region;
  final bool isActive;
  final int createdAt;
  const SavedLocationsTableData({
    required this.id,
    required this.cityId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.region,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['city_id'] = Variable<String>(cityId);
    map['name'] = Variable<String>(name);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['timezone'] = Variable<String>(timezone);
    map['region'] = Variable<String>(region);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SavedLocationsTableCompanion toCompanion(bool nullToAbsent) {
    return SavedLocationsTableCompanion(
      id: Value(id),
      cityId: Value(cityId),
      name: Value(name),
      latitude: Value(latitude),
      longitude: Value(longitude),
      timezone: Value(timezone),
      region: Value(region),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory SavedLocationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedLocationsTableData(
      id: serializer.fromJson<int>(json['id']),
      cityId: serializer.fromJson<String>(json['cityId']),
      name: serializer.fromJson<String>(json['name']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      timezone: serializer.fromJson<String>(json['timezone']),
      region: serializer.fromJson<String>(json['region']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cityId': serializer.toJson<String>(cityId),
      'name': serializer.toJson<String>(name),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'timezone': serializer.toJson<String>(timezone),
      'region': serializer.toJson<String>(region),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SavedLocationsTableData copyWith({
    int? id,
    String? cityId,
    String? name,
    double? latitude,
    double? longitude,
    String? timezone,
    String? region,
    bool? isActive,
    int? createdAt,
  }) => SavedLocationsTableData(
    id: id ?? this.id,
    cityId: cityId ?? this.cityId,
    name: name ?? this.name,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    timezone: timezone ?? this.timezone,
    region: region ?? this.region,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  SavedLocationsTableData copyWithCompanion(SavedLocationsTableCompanion data) {
    return SavedLocationsTableData(
      id: data.id.present ? data.id.value : this.id,
      cityId: data.cityId.present ? data.cityId.value : this.cityId,
      name: data.name.present ? data.name.value : this.name,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      region: data.region.present ? data.region.value : this.region,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedLocationsTableData(')
          ..write('id: $id, ')
          ..write('cityId: $cityId, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timezone: $timezone, ')
          ..write('region: $region, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cityId,
    name,
    latitude,
    longitude,
    timezone,
    region,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedLocationsTableData &&
          other.id == this.id &&
          other.cityId == this.cityId &&
          other.name == this.name &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.timezone == this.timezone &&
          other.region == this.region &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class SavedLocationsTableCompanion
    extends UpdateCompanion<SavedLocationsTableData> {
  final Value<int> id;
  final Value<String> cityId;
  final Value<String> name;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> timezone;
  final Value<String> region;
  final Value<bool> isActive;
  final Value<int> createdAt;
  const SavedLocationsTableCompanion({
    this.id = const Value.absent(),
    this.cityId = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.timezone = const Value.absent(),
    this.region = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SavedLocationsTableCompanion.insert({
    this.id = const Value.absent(),
    required String cityId,
    required String name,
    required double latitude,
    required double longitude,
    required String timezone,
    this.region = const Value.absent(),
    this.isActive = const Value.absent(),
    required int createdAt,
  }) : cityId = Value(cityId),
       name = Value(name),
       latitude = Value(latitude),
       longitude = Value(longitude),
       timezone = Value(timezone),
       createdAt = Value(createdAt);
  static Insertable<SavedLocationsTableData> custom({
    Expression<int>? id,
    Expression<String>? cityId,
    Expression<String>? name,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? timezone,
    Expression<String>? region,
    Expression<bool>? isActive,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cityId != null) 'city_id': cityId,
      if (name != null) 'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (timezone != null) 'timezone': timezone,
      if (region != null) 'region': region,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SavedLocationsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? cityId,
    Value<String>? name,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? timezone,
    Value<String>? region,
    Value<bool>? isActive,
    Value<int>? createdAt,
  }) {
    return SavedLocationsTableCompanion(
      id: id ?? this.id,
      cityId: cityId ?? this.cityId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      region: region ?? this.region,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cityId.present) {
      map['city_id'] = Variable<String>(cityId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedLocationsTableCompanion(')
          ..write('id: $id, ')
          ..write('cityId: $cityId, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timezone: $timezone, ')
          ..write('region: $region, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TasbihSessionsTableTable extends TasbihSessionsTable
    with TableInfo<$TasbihSessionsTableTable, TasbihSessionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasbihSessionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subhanallahMeta = const VerificationMeta(
    'subhanallah',
  );
  @override
  late final GeneratedColumn<int> subhanallah = GeneratedColumn<int>(
    'subhanallah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _alhamdulillahMeta = const VerificationMeta(
    'alhamdulillah',
  );
  @override
  late final GeneratedColumn<int> alhamdulillah = GeneratedColumn<int>(
    'alhamdulillah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _allahuakbarMeta = const VerificationMeta(
    'allahuakbar',
  );
  @override
  late final GeneratedColumn<int> allahuakbar = GeneratedColumn<int>(
    'allahuakbar',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCyclesMeta = const VerificationMeta(
    'totalCycles',
  );
  @override
  late final GeneratedColumn<int> totalCycles = GeneratedColumn<int>(
    'total_cycles',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    subhanallah,
    alhamdulillah,
    allahuakbar,
    totalCycles,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasbih_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TasbihSessionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('subhanallah')) {
      context.handle(
        _subhanallahMeta,
        subhanallah.isAcceptableOrUnknown(
          data['subhanallah']!,
          _subhanallahMeta,
        ),
      );
    }
    if (data.containsKey('alhamdulillah')) {
      context.handle(
        _alhamdulillahMeta,
        alhamdulillah.isAcceptableOrUnknown(
          data['alhamdulillah']!,
          _alhamdulillahMeta,
        ),
      );
    }
    if (data.containsKey('allahuakbar')) {
      context.handle(
        _allahuakbarMeta,
        allahuakbar.isAcceptableOrUnknown(
          data['allahuakbar']!,
          _allahuakbarMeta,
        ),
      );
    }
    if (data.containsKey('total_cycles')) {
      context.handle(
        _totalCyclesMeta,
        totalCycles.isAcceptableOrUnknown(
          data['total_cycles']!,
          _totalCyclesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {date},
  ];
  @override
  TasbihSessionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasbihSessionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      subhanallah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subhanallah'],
      )!,
      alhamdulillah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alhamdulillah'],
      )!,
      allahuakbar: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}allahuakbar'],
      )!,
      totalCycles: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cycles'],
      )!,
    );
  }

  @override
  $TasbihSessionsTableTable createAlias(String alias) {
    return $TasbihSessionsTableTable(attachedDatabase, alias);
  }
}

class TasbihSessionsTableData extends DataClass
    implements Insertable<TasbihSessionsTableData> {
  final int id;
  final String date;
  final int subhanallah;
  final int alhamdulillah;
  final int allahuakbar;
  final int totalCycles;
  const TasbihSessionsTableData({
    required this.id,
    required this.date,
    required this.subhanallah,
    required this.alhamdulillah,
    required this.allahuakbar,
    required this.totalCycles,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['subhanallah'] = Variable<int>(subhanallah);
    map['alhamdulillah'] = Variable<int>(alhamdulillah);
    map['allahuakbar'] = Variable<int>(allahuakbar);
    map['total_cycles'] = Variable<int>(totalCycles);
    return map;
  }

  TasbihSessionsTableCompanion toCompanion(bool nullToAbsent) {
    return TasbihSessionsTableCompanion(
      id: Value(id),
      date: Value(date),
      subhanallah: Value(subhanallah),
      alhamdulillah: Value(alhamdulillah),
      allahuakbar: Value(allahuakbar),
      totalCycles: Value(totalCycles),
    );
  }

  factory TasbihSessionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasbihSessionsTableData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      subhanallah: serializer.fromJson<int>(json['subhanallah']),
      alhamdulillah: serializer.fromJson<int>(json['alhamdulillah']),
      allahuakbar: serializer.fromJson<int>(json['allahuakbar']),
      totalCycles: serializer.fromJson<int>(json['totalCycles']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'subhanallah': serializer.toJson<int>(subhanallah),
      'alhamdulillah': serializer.toJson<int>(alhamdulillah),
      'allahuakbar': serializer.toJson<int>(allahuakbar),
      'totalCycles': serializer.toJson<int>(totalCycles),
    };
  }

  TasbihSessionsTableData copyWith({
    int? id,
    String? date,
    int? subhanallah,
    int? alhamdulillah,
    int? allahuakbar,
    int? totalCycles,
  }) => TasbihSessionsTableData(
    id: id ?? this.id,
    date: date ?? this.date,
    subhanallah: subhanallah ?? this.subhanallah,
    alhamdulillah: alhamdulillah ?? this.alhamdulillah,
    allahuakbar: allahuakbar ?? this.allahuakbar,
    totalCycles: totalCycles ?? this.totalCycles,
  );
  TasbihSessionsTableData copyWithCompanion(TasbihSessionsTableCompanion data) {
    return TasbihSessionsTableData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      subhanallah: data.subhanallah.present
          ? data.subhanallah.value
          : this.subhanallah,
      alhamdulillah: data.alhamdulillah.present
          ? data.alhamdulillah.value
          : this.alhamdulillah,
      allahuakbar: data.allahuakbar.present
          ? data.allahuakbar.value
          : this.allahuakbar,
      totalCycles: data.totalCycles.present
          ? data.totalCycles.value
          : this.totalCycles,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasbihSessionsTableData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('subhanallah: $subhanallah, ')
          ..write('alhamdulillah: $alhamdulillah, ')
          ..write('allahuakbar: $allahuakbar, ')
          ..write('totalCycles: $totalCycles')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    subhanallah,
    alhamdulillah,
    allahuakbar,
    totalCycles,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasbihSessionsTableData &&
          other.id == this.id &&
          other.date == this.date &&
          other.subhanallah == this.subhanallah &&
          other.alhamdulillah == this.alhamdulillah &&
          other.allahuakbar == this.allahuakbar &&
          other.totalCycles == this.totalCycles);
}

class TasbihSessionsTableCompanion
    extends UpdateCompanion<TasbihSessionsTableData> {
  final Value<int> id;
  final Value<String> date;
  final Value<int> subhanallah;
  final Value<int> alhamdulillah;
  final Value<int> allahuakbar;
  final Value<int> totalCycles;
  const TasbihSessionsTableCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.subhanallah = const Value.absent(),
    this.alhamdulillah = const Value.absent(),
    this.allahuakbar = const Value.absent(),
    this.totalCycles = const Value.absent(),
  });
  TasbihSessionsTableCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    this.subhanallah = const Value.absent(),
    this.alhamdulillah = const Value.absent(),
    this.allahuakbar = const Value.absent(),
    this.totalCycles = const Value.absent(),
  }) : date = Value(date);
  static Insertable<TasbihSessionsTableData> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<int>? subhanallah,
    Expression<int>? alhamdulillah,
    Expression<int>? allahuakbar,
    Expression<int>? totalCycles,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (subhanallah != null) 'subhanallah': subhanallah,
      if (alhamdulillah != null) 'alhamdulillah': alhamdulillah,
      if (allahuakbar != null) 'allahuakbar': allahuakbar,
      if (totalCycles != null) 'total_cycles': totalCycles,
    });
  }

  TasbihSessionsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<int>? subhanallah,
    Value<int>? alhamdulillah,
    Value<int>? allahuakbar,
    Value<int>? totalCycles,
  }) {
    return TasbihSessionsTableCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      subhanallah: subhanallah ?? this.subhanallah,
      alhamdulillah: alhamdulillah ?? this.alhamdulillah,
      allahuakbar: allahuakbar ?? this.allahuakbar,
      totalCycles: totalCycles ?? this.totalCycles,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (subhanallah.present) {
      map['subhanallah'] = Variable<int>(subhanallah.value);
    }
    if (alhamdulillah.present) {
      map['alhamdulillah'] = Variable<int>(alhamdulillah.value);
    }
    if (allahuakbar.present) {
      map['allahuakbar'] = Variable<int>(allahuakbar.value);
    }
    if (totalCycles.present) {
      map['total_cycles'] = Variable<int>(totalCycles.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasbihSessionsTableCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('subhanallah: $subhanallah, ')
          ..write('alhamdulillah: $alhamdulillah, ')
          ..write('allahuakbar: $allahuakbar, ')
          ..write('totalCycles: $totalCycles')
          ..write(')'))
        .toString();
  }
}

class $MosqueCacheTableTable extends MosqueCacheTable
    with TableInfo<$MosqueCacheTableTable, MosqueCacheTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MosqueCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _osmIdMeta = const VerificationMeta('osmId');
  @override
  late final GeneratedColumn<String> osmId = GeneratedColumn<String>(
    'osm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<int> lastUpdated = GeneratedColumn<int>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    osmId,
    name,
    address,
    latitude,
    longitude,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mosque_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<MosqueCacheTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('osm_id')) {
      context.handle(
        _osmIdMeta,
        osmId.isAcceptableOrUnknown(data['osm_id']!, _osmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_osmIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MosqueCacheTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MosqueCacheTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      osmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}osm_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $MosqueCacheTableTable createAlias(String alias) {
    return $MosqueCacheTableTable(attachedDatabase, alias);
  }
}

class MosqueCacheTableData extends DataClass
    implements Insertable<MosqueCacheTableData> {
  final int id;
  final String osmId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int lastUpdated;
  const MosqueCacheTableData({
    required this.id,
    required this.osmId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['osm_id'] = Variable<String>(osmId);
    map['name'] = Variable<String>(name);
    map['address'] = Variable<String>(address);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['last_updated'] = Variable<int>(lastUpdated);
    return map;
  }

  MosqueCacheTableCompanion toCompanion(bool nullToAbsent) {
    return MosqueCacheTableCompanion(
      id: Value(id),
      osmId: Value(osmId),
      name: Value(name),
      address: Value(address),
      latitude: Value(latitude),
      longitude: Value(longitude),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory MosqueCacheTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MosqueCacheTableData(
      id: serializer.fromJson<int>(json['id']),
      osmId: serializer.fromJson<String>(json['osmId']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String>(json['address']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      lastUpdated: serializer.fromJson<int>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'osmId': serializer.toJson<String>(osmId),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String>(address),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'lastUpdated': serializer.toJson<int>(lastUpdated),
    };
  }

  MosqueCacheTableData copyWith({
    int? id,
    String? osmId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? lastUpdated,
  }) => MosqueCacheTableData(
    id: id ?? this.id,
    osmId: osmId ?? this.osmId,
    name: name ?? this.name,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  MosqueCacheTableData copyWithCompanion(MosqueCacheTableCompanion data) {
    return MosqueCacheTableData(
      id: data.id.present ? data.id.value : this.id,
      osmId: data.osmId.present ? data.osmId.value : this.osmId,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MosqueCacheTableData(')
          ..write('id: $id, ')
          ..write('osmId: $osmId, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, osmId, name, address, latitude, longitude, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MosqueCacheTableData &&
          other.id == this.id &&
          other.osmId == this.osmId &&
          other.name == this.name &&
          other.address == this.address &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.lastUpdated == this.lastUpdated);
}

class MosqueCacheTableCompanion extends UpdateCompanion<MosqueCacheTableData> {
  final Value<int> id;
  final Value<String> osmId;
  final Value<String> name;
  final Value<String> address;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<int> lastUpdated;
  const MosqueCacheTableCompanion({
    this.id = const Value.absent(),
    this.osmId = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  MosqueCacheTableCompanion.insert({
    this.id = const Value.absent(),
    required String osmId,
    required String name,
    this.address = const Value.absent(),
    required double latitude,
    required double longitude,
    required int lastUpdated,
  }) : osmId = Value(osmId),
       name = Value(name),
       latitude = Value(latitude),
       longitude = Value(longitude),
       lastUpdated = Value(lastUpdated);
  static Insertable<MosqueCacheTableData> custom({
    Expression<int>? id,
    Expression<String>? osmId,
    Expression<String>? name,
    Expression<String>? address,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (osmId != null) 'osm_id': osmId,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  MosqueCacheTableCompanion copyWith({
    Value<int>? id,
    Value<String>? osmId,
    Value<String>? name,
    Value<String>? address,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<int>? lastUpdated,
  }) {
    return MosqueCacheTableCompanion(
      id: id ?? this.id,
      osmId: osmId ?? this.osmId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (osmId.present) {
      map['osm_id'] = Variable<String>(osmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<int>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MosqueCacheTableCompanion(')
          ..write('id: $id, ')
          ..write('osmId: $osmId, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

class $MonthlyCalendarTableTable extends MonthlyCalendarTable
    with TableInfo<$MonthlyCalendarTableTable, MonthlyCalendarTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthlyCalendarTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cityIdMeta = const VerificationMeta('cityId');
  @override
  late final GeneratedColumn<String> cityId = GeneratedColumn<String>(
    'city_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonDataMeta = const VerificationMeta(
    'jsonData',
  );
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
    'json_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cityId,
    year,
    month,
    jsonData,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monthly_calendar';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonthlyCalendarTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('city_id')) {
      context.handle(
        _cityIdMeta,
        cityId.isAcceptableOrUnknown(data['city_id']!, _cityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cityIdMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('json_data')) {
      context.handle(
        _jsonDataMeta,
        jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {cityId, year, month},
  ];
  @override
  MonthlyCalendarTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthlyCalendarTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_id'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      jsonData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_data'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $MonthlyCalendarTableTable createAlias(String alias) {
    return $MonthlyCalendarTableTable(attachedDatabase, alias);
  }
}

class MonthlyCalendarTableData extends DataClass
    implements Insertable<MonthlyCalendarTableData> {
  final int id;
  final String cityId;
  final int year;
  final int month;
  final String jsonData;
  final int fetchedAt;
  const MonthlyCalendarTableData({
    required this.id,
    required this.cityId,
    required this.year,
    required this.month,
    required this.jsonData,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['city_id'] = Variable<String>(cityId);
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    map['json_data'] = Variable<String>(jsonData);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  MonthlyCalendarTableCompanion toCompanion(bool nullToAbsent) {
    return MonthlyCalendarTableCompanion(
      id: Value(id),
      cityId: Value(cityId),
      year: Value(year),
      month: Value(month),
      jsonData: Value(jsonData),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory MonthlyCalendarTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthlyCalendarTableData(
      id: serializer.fromJson<int>(json['id']),
      cityId: serializer.fromJson<String>(json['cityId']),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
      jsonData: serializer.fromJson<String>(json['jsonData']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cityId': serializer.toJson<String>(cityId),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
      'jsonData': serializer.toJson<String>(jsonData),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  MonthlyCalendarTableData copyWith({
    int? id,
    String? cityId,
    int? year,
    int? month,
    String? jsonData,
    int? fetchedAt,
  }) => MonthlyCalendarTableData(
    id: id ?? this.id,
    cityId: cityId ?? this.cityId,
    year: year ?? this.year,
    month: month ?? this.month,
    jsonData: jsonData ?? this.jsonData,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  MonthlyCalendarTableData copyWithCompanion(
    MonthlyCalendarTableCompanion data,
  ) {
    return MonthlyCalendarTableData(
      id: data.id.present ? data.id.value : this.id,
      cityId: data.cityId.present ? data.cityId.value : this.cityId,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      jsonData: data.jsonData.present ? data.jsonData.value : this.jsonData,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyCalendarTableData(')
          ..write('id: $id, ')
          ..write('cityId: $cityId, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('jsonData: $jsonData, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cityId, year, month, jsonData, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthlyCalendarTableData &&
          other.id == this.id &&
          other.cityId == this.cityId &&
          other.year == this.year &&
          other.month == this.month &&
          other.jsonData == this.jsonData &&
          other.fetchedAt == this.fetchedAt);
}

class MonthlyCalendarTableCompanion
    extends UpdateCompanion<MonthlyCalendarTableData> {
  final Value<int> id;
  final Value<String> cityId;
  final Value<int> year;
  final Value<int> month;
  final Value<String> jsonData;
  final Value<int> fetchedAt;
  const MonthlyCalendarTableCompanion({
    this.id = const Value.absent(),
    this.cityId = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  MonthlyCalendarTableCompanion.insert({
    this.id = const Value.absent(),
    required String cityId,
    required int year,
    required int month,
    required String jsonData,
    required int fetchedAt,
  }) : cityId = Value(cityId),
       year = Value(year),
       month = Value(month),
       jsonData = Value(jsonData),
       fetchedAt = Value(fetchedAt);
  static Insertable<MonthlyCalendarTableData> custom({
    Expression<int>? id,
    Expression<String>? cityId,
    Expression<int>? year,
    Expression<int>? month,
    Expression<String>? jsonData,
    Expression<int>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cityId != null) 'city_id': cityId,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (jsonData != null) 'json_data': jsonData,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  MonthlyCalendarTableCompanion copyWith({
    Value<int>? id,
    Value<String>? cityId,
    Value<int>? year,
    Value<int>? month,
    Value<String>? jsonData,
    Value<int>? fetchedAt,
  }) {
    return MonthlyCalendarTableCompanion(
      id: id ?? this.id,
      cityId: cityId ?? this.cityId,
      year: year ?? this.year,
      month: month ?? this.month,
      jsonData: jsonData ?? this.jsonData,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cityId.present) {
      map['city_id'] = Variable<String>(cityId.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (jsonData.present) {
      map['json_data'] = Variable<String>(jsonData.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyCalendarTableCompanion(')
          ..write('id: $id, ')
          ..write('cityId: $cityId, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('jsonData: $jsonData, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PrayerTimesTableTable prayerTimesTable = $PrayerTimesTableTable(
    this,
  );
  late final $SavedLocationsTableTable savedLocationsTable =
      $SavedLocationsTableTable(this);
  late final $TasbihSessionsTableTable tasbihSessionsTable =
      $TasbihSessionsTableTable(this);
  late final $MosqueCacheTableTable mosqueCacheTable = $MosqueCacheTableTable(
    this,
  );
  late final $MonthlyCalendarTableTable monthlyCalendarTable =
      $MonthlyCalendarTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    prayerTimesTable,
    savedLocationsTable,
    tasbihSessionsTable,
    mosqueCacheTable,
    monthlyCalendarTable,
  ];
}

typedef $$PrayerTimesTableTableCreateCompanionBuilder =
    PrayerTimesTableCompanion Function({
      Value<int> id,
      required String cityId,
      required String date,
      required String fajr,
      required String sunrise,
      required String dhuhr,
      required String asr,
      required String maghrib,
      required String isha,
      Value<String> hijriDate,
      Value<String> calculationMethod,
      required int fetchedAt,
    });
typedef $$PrayerTimesTableTableUpdateCompanionBuilder =
    PrayerTimesTableCompanion Function({
      Value<int> id,
      Value<String> cityId,
      Value<String> date,
      Value<String> fajr,
      Value<String> sunrise,
      Value<String> dhuhr,
      Value<String> asr,
      Value<String> maghrib,
      Value<String> isha,
      Value<String> hijriDate,
      Value<String> calculationMethod,
      Value<int> fetchedAt,
    });

class $$PrayerTimesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerTimesTableTable> {
  $$PrayerTimesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cityId => $composableBuilder(
    column: $table.cityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fajr => $composableBuilder(
    column: $table.fajr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sunrise => $composableBuilder(
    column: $table.sunrise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dhuhr => $composableBuilder(
    column: $table.dhuhr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get asr => $composableBuilder(
    column: $table.asr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maghrib => $composableBuilder(
    column: $table.maghrib,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isha => $composableBuilder(
    column: $table.isha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hijriDate => $composableBuilder(
    column: $table.hijriDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calculationMethod => $composableBuilder(
    column: $table.calculationMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrayerTimesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerTimesTableTable> {
  $$PrayerTimesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cityId => $composableBuilder(
    column: $table.cityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fajr => $composableBuilder(
    column: $table.fajr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sunrise => $composableBuilder(
    column: $table.sunrise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dhuhr => $composableBuilder(
    column: $table.dhuhr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get asr => $composableBuilder(
    column: $table.asr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maghrib => $composableBuilder(
    column: $table.maghrib,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isha => $composableBuilder(
    column: $table.isha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hijriDate => $composableBuilder(
    column: $table.hijriDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calculationMethod => $composableBuilder(
    column: $table.calculationMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrayerTimesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerTimesTableTable> {
  $$PrayerTimesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cityId =>
      $composableBuilder(column: $table.cityId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get fajr =>
      $composableBuilder(column: $table.fajr, builder: (column) => column);

  GeneratedColumn<String> get sunrise =>
      $composableBuilder(column: $table.sunrise, builder: (column) => column);

  GeneratedColumn<String> get dhuhr =>
      $composableBuilder(column: $table.dhuhr, builder: (column) => column);

  GeneratedColumn<String> get asr =>
      $composableBuilder(column: $table.asr, builder: (column) => column);

  GeneratedColumn<String> get maghrib =>
      $composableBuilder(column: $table.maghrib, builder: (column) => column);

  GeneratedColumn<String> get isha =>
      $composableBuilder(column: $table.isha, builder: (column) => column);

  GeneratedColumn<String> get hijriDate =>
      $composableBuilder(column: $table.hijriDate, builder: (column) => column);

  GeneratedColumn<String> get calculationMethod => $composableBuilder(
    column: $table.calculationMethod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$PrayerTimesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerTimesTableTable,
          PrayerTimesTableData,
          $$PrayerTimesTableTableFilterComposer,
          $$PrayerTimesTableTableOrderingComposer,
          $$PrayerTimesTableTableAnnotationComposer,
          $$PrayerTimesTableTableCreateCompanionBuilder,
          $$PrayerTimesTableTableUpdateCompanionBuilder,
          (
            PrayerTimesTableData,
            BaseReferences<
              _$AppDatabase,
              $PrayerTimesTableTable,
              PrayerTimesTableData
            >,
          ),
          PrayerTimesTableData,
          PrefetchHooks Function()
        > {
  $$PrayerTimesTableTableTableManager(
    _$AppDatabase db,
    $PrayerTimesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerTimesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerTimesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerTimesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cityId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> fajr = const Value.absent(),
                Value<String> sunrise = const Value.absent(),
                Value<String> dhuhr = const Value.absent(),
                Value<String> asr = const Value.absent(),
                Value<String> maghrib = const Value.absent(),
                Value<String> isha = const Value.absent(),
                Value<String> hijriDate = const Value.absent(),
                Value<String> calculationMethod = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
              }) => PrayerTimesTableCompanion(
                id: id,
                cityId: cityId,
                date: date,
                fajr: fajr,
                sunrise: sunrise,
                dhuhr: dhuhr,
                asr: asr,
                maghrib: maghrib,
                isha: isha,
                hijriDate: hijriDate,
                calculationMethod: calculationMethod,
                fetchedAt: fetchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cityId,
                required String date,
                required String fajr,
                required String sunrise,
                required String dhuhr,
                required String asr,
                required String maghrib,
                required String isha,
                Value<String> hijriDate = const Value.absent(),
                Value<String> calculationMethod = const Value.absent(),
                required int fetchedAt,
              }) => PrayerTimesTableCompanion.insert(
                id: id,
                cityId: cityId,
                date: date,
                fajr: fajr,
                sunrise: sunrise,
                dhuhr: dhuhr,
                asr: asr,
                maghrib: maghrib,
                isha: isha,
                hijriDate: hijriDate,
                calculationMethod: calculationMethod,
                fetchedAt: fetchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrayerTimesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerTimesTableTable,
      PrayerTimesTableData,
      $$PrayerTimesTableTableFilterComposer,
      $$PrayerTimesTableTableOrderingComposer,
      $$PrayerTimesTableTableAnnotationComposer,
      $$PrayerTimesTableTableCreateCompanionBuilder,
      $$PrayerTimesTableTableUpdateCompanionBuilder,
      (
        PrayerTimesTableData,
        BaseReferences<
          _$AppDatabase,
          $PrayerTimesTableTable,
          PrayerTimesTableData
        >,
      ),
      PrayerTimesTableData,
      PrefetchHooks Function()
    >;
typedef $$SavedLocationsTableTableCreateCompanionBuilder =
    SavedLocationsTableCompanion Function({
      Value<int> id,
      required String cityId,
      required String name,
      required double latitude,
      required double longitude,
      required String timezone,
      Value<String> region,
      Value<bool> isActive,
      required int createdAt,
    });
typedef $$SavedLocationsTableTableUpdateCompanionBuilder =
    SavedLocationsTableCompanion Function({
      Value<int> id,
      Value<String> cityId,
      Value<String> name,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> timezone,
      Value<String> region,
      Value<bool> isActive,
      Value<int> createdAt,
    });

class $$SavedLocationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SavedLocationsTableTable> {
  $$SavedLocationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cityId => $composableBuilder(
    column: $table.cityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedLocationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedLocationsTableTable> {
  $$SavedLocationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cityId => $composableBuilder(
    column: $table.cityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedLocationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedLocationsTableTable> {
  $$SavedLocationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cityId =>
      $composableBuilder(column: $table.cityId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SavedLocationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedLocationsTableTable,
          SavedLocationsTableData,
          $$SavedLocationsTableTableFilterComposer,
          $$SavedLocationsTableTableOrderingComposer,
          $$SavedLocationsTableTableAnnotationComposer,
          $$SavedLocationsTableTableCreateCompanionBuilder,
          $$SavedLocationsTableTableUpdateCompanionBuilder,
          (
            SavedLocationsTableData,
            BaseReferences<
              _$AppDatabase,
              $SavedLocationsTableTable,
              SavedLocationsTableData
            >,
          ),
          SavedLocationsTableData,
          PrefetchHooks Function()
        > {
  $$SavedLocationsTableTableTableManager(
    _$AppDatabase db,
    $SavedLocationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedLocationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedLocationsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SavedLocationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cityId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => SavedLocationsTableCompanion(
                id: id,
                cityId: cityId,
                name: name,
                latitude: latitude,
                longitude: longitude,
                timezone: timezone,
                region: region,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cityId,
                required String name,
                required double latitude,
                required double longitude,
                required String timezone,
                Value<String> region = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required int createdAt,
              }) => SavedLocationsTableCompanion.insert(
                id: id,
                cityId: cityId,
                name: name,
                latitude: latitude,
                longitude: longitude,
                timezone: timezone,
                region: region,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedLocationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedLocationsTableTable,
      SavedLocationsTableData,
      $$SavedLocationsTableTableFilterComposer,
      $$SavedLocationsTableTableOrderingComposer,
      $$SavedLocationsTableTableAnnotationComposer,
      $$SavedLocationsTableTableCreateCompanionBuilder,
      $$SavedLocationsTableTableUpdateCompanionBuilder,
      (
        SavedLocationsTableData,
        BaseReferences<
          _$AppDatabase,
          $SavedLocationsTableTable,
          SavedLocationsTableData
        >,
      ),
      SavedLocationsTableData,
      PrefetchHooks Function()
    >;
typedef $$TasbihSessionsTableTableCreateCompanionBuilder =
    TasbihSessionsTableCompanion Function({
      Value<int> id,
      required String date,
      Value<int> subhanallah,
      Value<int> alhamdulillah,
      Value<int> allahuakbar,
      Value<int> totalCycles,
    });
typedef $$TasbihSessionsTableTableUpdateCompanionBuilder =
    TasbihSessionsTableCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<int> subhanallah,
      Value<int> alhamdulillah,
      Value<int> allahuakbar,
      Value<int> totalCycles,
    });

class $$TasbihSessionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TasbihSessionsTableTable> {
  $$TasbihSessionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subhanallah => $composableBuilder(
    column: $table.subhanallah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alhamdulillah => $composableBuilder(
    column: $table.alhamdulillah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get allahuakbar => $composableBuilder(
    column: $table.allahuakbar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCycles => $composableBuilder(
    column: $table.totalCycles,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasbihSessionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TasbihSessionsTableTable> {
  $$TasbihSessionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subhanallah => $composableBuilder(
    column: $table.subhanallah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alhamdulillah => $composableBuilder(
    column: $table.alhamdulillah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get allahuakbar => $composableBuilder(
    column: $table.allahuakbar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCycles => $composableBuilder(
    column: $table.totalCycles,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasbihSessionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasbihSessionsTableTable> {
  $$TasbihSessionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get subhanallah => $composableBuilder(
    column: $table.subhanallah,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alhamdulillah => $composableBuilder(
    column: $table.alhamdulillah,
    builder: (column) => column,
  );

  GeneratedColumn<int> get allahuakbar => $composableBuilder(
    column: $table.allahuakbar,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCycles => $composableBuilder(
    column: $table.totalCycles,
    builder: (column) => column,
  );
}

class $$TasbihSessionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasbihSessionsTableTable,
          TasbihSessionsTableData,
          $$TasbihSessionsTableTableFilterComposer,
          $$TasbihSessionsTableTableOrderingComposer,
          $$TasbihSessionsTableTableAnnotationComposer,
          $$TasbihSessionsTableTableCreateCompanionBuilder,
          $$TasbihSessionsTableTableUpdateCompanionBuilder,
          (
            TasbihSessionsTableData,
            BaseReferences<
              _$AppDatabase,
              $TasbihSessionsTableTable,
              TasbihSessionsTableData
            >,
          ),
          TasbihSessionsTableData,
          PrefetchHooks Function()
        > {
  $$TasbihSessionsTableTableTableManager(
    _$AppDatabase db,
    $TasbihSessionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasbihSessionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasbihSessionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TasbihSessionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> subhanallah = const Value.absent(),
                Value<int> alhamdulillah = const Value.absent(),
                Value<int> allahuakbar = const Value.absent(),
                Value<int> totalCycles = const Value.absent(),
              }) => TasbihSessionsTableCompanion(
                id: id,
                date: date,
                subhanallah: subhanallah,
                alhamdulillah: alhamdulillah,
                allahuakbar: allahuakbar,
                totalCycles: totalCycles,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                Value<int> subhanallah = const Value.absent(),
                Value<int> alhamdulillah = const Value.absent(),
                Value<int> allahuakbar = const Value.absent(),
                Value<int> totalCycles = const Value.absent(),
              }) => TasbihSessionsTableCompanion.insert(
                id: id,
                date: date,
                subhanallah: subhanallah,
                alhamdulillah: alhamdulillah,
                allahuakbar: allahuakbar,
                totalCycles: totalCycles,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasbihSessionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasbihSessionsTableTable,
      TasbihSessionsTableData,
      $$TasbihSessionsTableTableFilterComposer,
      $$TasbihSessionsTableTableOrderingComposer,
      $$TasbihSessionsTableTableAnnotationComposer,
      $$TasbihSessionsTableTableCreateCompanionBuilder,
      $$TasbihSessionsTableTableUpdateCompanionBuilder,
      (
        TasbihSessionsTableData,
        BaseReferences<
          _$AppDatabase,
          $TasbihSessionsTableTable,
          TasbihSessionsTableData
        >,
      ),
      TasbihSessionsTableData,
      PrefetchHooks Function()
    >;
typedef $$MosqueCacheTableTableCreateCompanionBuilder =
    MosqueCacheTableCompanion Function({
      Value<int> id,
      required String osmId,
      required String name,
      Value<String> address,
      required double latitude,
      required double longitude,
      required int lastUpdated,
    });
typedef $$MosqueCacheTableTableUpdateCompanionBuilder =
    MosqueCacheTableCompanion Function({
      Value<int> id,
      Value<String> osmId,
      Value<String> name,
      Value<String> address,
      Value<double> latitude,
      Value<double> longitude,
      Value<int> lastUpdated,
    });

class $$MosqueCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $MosqueCacheTableTable> {
  $$MosqueCacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get osmId => $composableBuilder(
    column: $table.osmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MosqueCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MosqueCacheTableTable> {
  $$MosqueCacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get osmId => $composableBuilder(
    column: $table.osmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MosqueCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MosqueCacheTableTable> {
  $$MosqueCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get osmId =>
      $composableBuilder(column: $table.osmId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$MosqueCacheTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MosqueCacheTableTable,
          MosqueCacheTableData,
          $$MosqueCacheTableTableFilterComposer,
          $$MosqueCacheTableTableOrderingComposer,
          $$MosqueCacheTableTableAnnotationComposer,
          $$MosqueCacheTableTableCreateCompanionBuilder,
          $$MosqueCacheTableTableUpdateCompanionBuilder,
          (
            MosqueCacheTableData,
            BaseReferences<
              _$AppDatabase,
              $MosqueCacheTableTable,
              MosqueCacheTableData
            >,
          ),
          MosqueCacheTableData,
          PrefetchHooks Function()
        > {
  $$MosqueCacheTableTableTableManager(
    _$AppDatabase db,
    $MosqueCacheTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MosqueCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MosqueCacheTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MosqueCacheTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> osmId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<int> lastUpdated = const Value.absent(),
              }) => MosqueCacheTableCompanion(
                id: id,
                osmId: osmId,
                name: name,
                address: address,
                latitude: latitude,
                longitude: longitude,
                lastUpdated: lastUpdated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String osmId,
                required String name,
                Value<String> address = const Value.absent(),
                required double latitude,
                required double longitude,
                required int lastUpdated,
              }) => MosqueCacheTableCompanion.insert(
                id: id,
                osmId: osmId,
                name: name,
                address: address,
                latitude: latitude,
                longitude: longitude,
                lastUpdated: lastUpdated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MosqueCacheTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MosqueCacheTableTable,
      MosqueCacheTableData,
      $$MosqueCacheTableTableFilterComposer,
      $$MosqueCacheTableTableOrderingComposer,
      $$MosqueCacheTableTableAnnotationComposer,
      $$MosqueCacheTableTableCreateCompanionBuilder,
      $$MosqueCacheTableTableUpdateCompanionBuilder,
      (
        MosqueCacheTableData,
        BaseReferences<
          _$AppDatabase,
          $MosqueCacheTableTable,
          MosqueCacheTableData
        >,
      ),
      MosqueCacheTableData,
      PrefetchHooks Function()
    >;
typedef $$MonthlyCalendarTableTableCreateCompanionBuilder =
    MonthlyCalendarTableCompanion Function({
      Value<int> id,
      required String cityId,
      required int year,
      required int month,
      required String jsonData,
      required int fetchedAt,
    });
typedef $$MonthlyCalendarTableTableUpdateCompanionBuilder =
    MonthlyCalendarTableCompanion Function({
      Value<int> id,
      Value<String> cityId,
      Value<int> year,
      Value<int> month,
      Value<String> jsonData,
      Value<int> fetchedAt,
    });

class $$MonthlyCalendarTableTableFilterComposer
    extends Composer<_$AppDatabase, $MonthlyCalendarTableTable> {
  $$MonthlyCalendarTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cityId => $composableBuilder(
    column: $table.cityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonthlyCalendarTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MonthlyCalendarTableTable> {
  $$MonthlyCalendarTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cityId => $composableBuilder(
    column: $table.cityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonthlyCalendarTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonthlyCalendarTableTable> {
  $$MonthlyCalendarTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cityId =>
      $composableBuilder(column: $table.cityId, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get jsonData =>
      $composableBuilder(column: $table.jsonData, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$MonthlyCalendarTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonthlyCalendarTableTable,
          MonthlyCalendarTableData,
          $$MonthlyCalendarTableTableFilterComposer,
          $$MonthlyCalendarTableTableOrderingComposer,
          $$MonthlyCalendarTableTableAnnotationComposer,
          $$MonthlyCalendarTableTableCreateCompanionBuilder,
          $$MonthlyCalendarTableTableUpdateCompanionBuilder,
          (
            MonthlyCalendarTableData,
            BaseReferences<
              _$AppDatabase,
              $MonthlyCalendarTableTable,
              MonthlyCalendarTableData
            >,
          ),
          MonthlyCalendarTableData,
          PrefetchHooks Function()
        > {
  $$MonthlyCalendarTableTableTableManager(
    _$AppDatabase db,
    $MonthlyCalendarTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthlyCalendarTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthlyCalendarTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MonthlyCalendarTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cityId = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<String> jsonData = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
              }) => MonthlyCalendarTableCompanion(
                id: id,
                cityId: cityId,
                year: year,
                month: month,
                jsonData: jsonData,
                fetchedAt: fetchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cityId,
                required int year,
                required int month,
                required String jsonData,
                required int fetchedAt,
              }) => MonthlyCalendarTableCompanion.insert(
                id: id,
                cityId: cityId,
                year: year,
                month: month,
                jsonData: jsonData,
                fetchedAt: fetchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonthlyCalendarTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonthlyCalendarTableTable,
      MonthlyCalendarTableData,
      $$MonthlyCalendarTableTableFilterComposer,
      $$MonthlyCalendarTableTableOrderingComposer,
      $$MonthlyCalendarTableTableAnnotationComposer,
      $$MonthlyCalendarTableTableCreateCompanionBuilder,
      $$MonthlyCalendarTableTableUpdateCompanionBuilder,
      (
        MonthlyCalendarTableData,
        BaseReferences<
          _$AppDatabase,
          $MonthlyCalendarTableTable,
          MonthlyCalendarTableData
        >,
      ),
      MonthlyCalendarTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PrayerTimesTableTableTableManager get prayerTimesTable =>
      $$PrayerTimesTableTableTableManager(_db, _db.prayerTimesTable);
  $$SavedLocationsTableTableTableManager get savedLocationsTable =>
      $$SavedLocationsTableTableTableManager(_db, _db.savedLocationsTable);
  $$TasbihSessionsTableTableTableManager get tasbihSessionsTable =>
      $$TasbihSessionsTableTableTableManager(_db, _db.tasbihSessionsTable);
  $$MosqueCacheTableTableTableManager get mosqueCacheTable =>
      $$MosqueCacheTableTableTableManager(_db, _db.mosqueCacheTable);
  $$MonthlyCalendarTableTableTableManager get monthlyCalendarTable =>
      $$MonthlyCalendarTableTableTableManager(_db, _db.monthlyCalendarTable);
}
