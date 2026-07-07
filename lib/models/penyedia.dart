class Penyedia {
  final String? id;
  final String nama;
  final String? npwp;
  final String? jenisUsaha;
  final String? status;
  final String? email;
  final String? telepon;
  final String? alamat;
  final String? tanggalDaftar;
  final bool isVerified;

  Penyedia({
    this.id,
    required this.nama,
    this.npwp,
    this.jenisUsaha,
    this.status,
    this.email,
    this.telepon,
    this.alamat,
    this.tanggalDaftar,
    this.isVerified = false,
  });

  factory Penyedia.fromJson(Map<String, dynamic> json) {
    return Penyedia(
      id: json['id']?.toString(),
      nama: json['nama'] as String? ?? json['name'] as String? ?? '',
      npwp: json['npwp'] as String?,
      jenisUsaha: json['jenis_usaha'] as String? ?? json['jenis'] as String?,
      status: json['status'] as String?,
      email: json['email'] as String?,
      telepon: json['telepon'] as String? ?? json['phone'] as String?,
      alamat: json['alamat'] as String? ?? json['address'] as String?,
      tanggalDaftar: json['tanggal_daftar'] as String? ?? json['created_at'] as String?,
      isVerified: json['is_verified'] as bool? ?? json['verified'] as bool? ?? false,
    );
  }

  String get initialLetters {
    if (nama.isEmpty) return '?';
    final words = nama.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return nama.substring(0, nama.length > 1 ? 2 : 1).toUpperCase();
  }
}
