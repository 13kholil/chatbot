class PackageItem {
  final int id;
  final String packageName;
  final String satker;
  final String budget;
  final double? budgetValue;
  final String? procurementMethod;
  final String? procurementType;
  final String? caraPengadaan;
  final String? fundingSource;
  final String? workDescription;
  final bool hasRealisasi;
  final double realisasiPersen;
  final double realisasiTotal;
  final String? isUmkm;
  final int tahunAnggaran;

  PackageItem({
    required this.id,
    required this.packageName,
    required this.satker,
    required this.budget,
    this.budgetValue,
    this.procurementMethod,
    this.procurementType,
    this.caraPengadaan,
    this.fundingSource,
    this.workDescription,
    this.hasRealisasi = false,
    this.realisasiPersen = 0,
    this.realisasiTotal = 0,
    this.isUmkm,
    this.tahunAnggaran = 2025,
  });

  factory PackageItem.fromJson(Map<String, dynamic> json) {
    final budgetStr = json['budget'] as String? ?? 'Rp 0';
    return PackageItem(
      id: json['id'] as int? ?? 0,
      packageName: json['package_name'] as String? ?? '',
      satker: json['satker'] as String? ?? '',
      budget: budgetStr,
      budgetValue: _parseBudget(budgetStr),
      procurementMethod: json['procurement_method'] as String?,
      procurementType: json['procurement_type'] as String?,
      caraPengadaan: json['Cara Pengadaan'] as String?,
      fundingSource: json['funding_source'] as String?,
      workDescription: json['work_description'] as String?,
      hasRealisasi: json['has_realisasi'] as bool? ?? false,
      realisasiPersen: (json['realisasi_persen'] as num?)?.toDouble() ?? 0,
      realisasiTotal: (json['realisasi_total'] as num?)?.toDouble() ?? 0,
      isUmkm: json['is_umkm'] as String?,
      tahunAnggaran: json['Tahun Anggaran'] as int? ?? 2025,
    );
  }

  static double _parseBudget(String budgetStr) {
    try {
      return double.parse(
        budgetStr.replaceAll('Rp ', '').replaceAll(',', ''),
      );
    } catch (_) {
      return 0;
    }
  }

  String get budgetFormatted {
    if (budgetValue == null || budgetValue == 0) return budget;
    return 'Rp ${budgetValue!.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  String get realisasiFormatted {
    if (realisasiTotal == 0) return 'Belum realisasi';
    return 'Rp ${realisasiTotal.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  String get satkerShort {
    final parts = satker.split(' - ');
    return parts.isNotEmpty ? parts[0] : satker;
  }
}
