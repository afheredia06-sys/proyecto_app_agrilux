// lib/models/user_model.dart
class UserModel {
  final String id, nombre, ubicacion, whatsapp, tipo, codigo;
  const UserModel({required this.id, required this.nombre, required this.ubicacion, required this.whatsapp, required this.tipo, required this.codigo});

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'] ?? '', nombre: j['nombre'] ?? '',
    ubicacion: j['ubicacion'] ?? '', whatsapp: j['whatsapp'] ?? '',
    tipo: j['tipo'] ?? 'agricultor', codigo: j['codigo'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'nombre': nombre, 'ubicacion': ubicacion,
    'whatsapp': whatsapp, 'tipo': tipo, 'codigo': codigo,
  };
}
