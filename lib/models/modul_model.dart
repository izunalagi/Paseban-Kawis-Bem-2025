class ModulModel {
  final int id;
  final String judulModul;
  final int categoryModulId;
  final String? namaKategori;
  final String linkVideo;
  final String? pathPdf;
  final String? foto;
  final String deskripsiModul;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ModulModel({
    required this.id,
    required this.judulModul,
    required this.categoryModulId,
    this.namaKategori,
    required this.linkVideo,
    this.pathPdf,
    this.foto,
    required this.deskripsiModul,
    this.createdAt,
    this.updatedAt,
  });

  factory ModulModel.fromJson(Map<String, dynamic> json) => ModulModel(
    id: _parseToInt(json['id']),
    judulModul: json['judul_modul'] ?? '',
    categoryModulId: _parseToInt(json['category_modul_id']),
    namaKategori: json['category_modul']?['nama'] ?? json['nama_kategori'],
    linkVideo: json['link_video'] ?? '',
    pathPdf: json['path_pdf'],
    foto: json['foto'],
    deskripsiModul: json['deskripsi_modul'] ?? '',
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null,
  );

  // Helper method untuk konversi yang aman dari dynamic ke int
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'judul_modul': judulModul,
    'category_modul_id': categoryModulId,
    'nama_kategori': namaKategori,
    'link_video': linkVideo,
    'path_pdf': pathPdf,
    'foto': foto,
    'deskripsi_modul': deskripsiModul,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
