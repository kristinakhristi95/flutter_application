class ClinicalData {
  final String? id;
  final String patientId;
  final String userId;
  final DataType type;
  final double reading;
  final DateTime testDate;
  final bool criticalFlag;
  final String? value;
  final String? unit;

  const ClinicalData({
    this.id,
    required this.patientId,
    required this.userId,
    required this.type,
    required this.reading,
    required this.testDate,
    this.criticalFlag = false,
    this.value,
    this.unit,
  });

  factory ClinicalData.fromJson(Map<String, dynamic> json) {
    return ClinicalData(
      id: json['_id'],
      patientId: json['patientId'],
      userId: json['userId'],
      type: _getDataTypeFromString(json['dataType']),
      reading: double.parse(json['reading'].toString()),
      testDate: DateTime.parse(json['testDate']),
      criticalFlag: json['criticalFlag'] ?? false,
      value: json['value'],
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'userId': userId,
      'dataType': type.apiName,
      'reading': reading,
      'testDate': testDate.toIso8601String(),
      'criticalFlag': criticalFlag,
      'value': value ?? reading.toString(),
      'unit': unit ?? type.unit,
    };
  }

  String get readingValue => value ?? reading.toString();
  String get unitValue => unit ?? type.unit;
  DateTime get dateTime => testDate;
}

enum DataType {
  bloodPressure,
  heartBeatRate,
  bloodOxygenLevel,
  respiratoryRate;

  String get name {
    switch (this) {
      case DataType.bloodPressure:
        return 'Blood Pressure';
      case DataType.heartBeatRate:
        return 'Heartbeat Rate';
      case DataType.bloodOxygenLevel:
        return 'Blood Oxygen Level';
      case DataType.respiratoryRate:
        return 'Respiratory Rate';
    }
  }

  String get apiName {
    switch (this) {
      case DataType.bloodPressure:
        return 'Blood Pressure';
      case DataType.respiratoryRate:
        return 'Respiratory Rate';
      case DataType.bloodOxygenLevel:
        return 'Blood Oxygen Level';
      case DataType.heartBeatRate:
        return 'Heartbeat Rate';
    }
  }

  String get unit {
    switch (this) {
      case DataType.bloodPressure:
        return 'mmHg';
      case DataType.respiratoryRate:
        return 'breaths/min';
      case DataType.bloodOxygenLevel:
        return '%';
      case DataType.heartBeatRate:
        return 'bpm';
    }
  }
}

DataType _getDataTypeFromString(String dataType) {
  switch (dataType) {
    case 'Blood Pressure':
      return DataType.bloodPressure;
    case 'Respiratory Rate':
      return DataType.respiratoryRate;
    case 'Blood Oxygen Level':
      return DataType.bloodOxygenLevel;
    case 'Heartbeat Rate':
      return DataType.heartBeatRate;
    default:
      throw Exception('Unknown data type: $dataType');
  }
}
