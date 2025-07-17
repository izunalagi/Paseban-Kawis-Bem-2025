class UserModel {
  final int id;
  final String nama;
  final String email;
  final String? telepon;
  final String? foto;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.telepon,
    this.foto,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    nama: json['nama'],
    email: json['email'],
    telepon: json['telepon'],
    foto: json['foto'],
  );
}
