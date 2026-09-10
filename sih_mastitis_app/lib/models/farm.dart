class Farm {
  final String id;
  final String name;
  final String location;
  final String ownerId;
  final String? vetName;
  final String? vetPhone;
  final String? vetEmail;
  final String? additionalDetails;

  Farm({
    required this.id, 
    required this.name, 
    required this.location, 
    required this.ownerId,
    this.vetName,
    this.vetPhone,
    this.vetEmail,
    this.additionalDetails,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      location: json['location_lat'] != null && json['location_long'] != null 
          ? '${json['location_lat']}, ${json['location_long']}' 
          : 'Not configured',
      ownerId: json['owner_id']?.toString() ?? '',
      vetName: json['vet_name'] as String?,
      vetPhone: json['vet_phone'] as String?,
      vetEmail: json['vet_email'] as String?,
      additionalDetails: json['additional_details'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'vet_name': vetName,
      'vet_phone': vetPhone,
      'vet_email': vetEmail,
      'additional_details': additionalDetails,
    };
  }
}
