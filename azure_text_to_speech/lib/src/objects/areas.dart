class Area {
  final String label;
  final String name;

  Area({this.label, this.name});

  @override
  bool operator ==(o) => o is Area && o.label == label && o.name == name;

  int get hasCode => label.hashCode ^ name.hashCode;

  factory Area.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return Area(
      name: json['name'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'name': name};

  static final center_us = Area(label: 'Central US', name: 'centralus');
  static final east_us = Area(label: 'East US', name: 'eastus');
  static final east_us_2 = Area(label: 'East US2', name: 'eastus2');
  static final japan_east = Area(label: 'Japan East', name: 'japaneast');
  static final east_asia = Area(label: 'East Asia', name: 'eastasia');
}
