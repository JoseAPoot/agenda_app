import 'package:cloud_firestore/cloud_firestore.dart';

class Contacto {
  String id;
  String nombre;
  String telefono;
  String correo;

  Contacto({
    this.id = '',
    this.nombre = '',
    this.telefono = '',
    this.correo = '',
  });

  factory Contacto.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Contacto(
      id: doc.id,
      nombre: data['nombre'],
      telefono: data['telefono'],
      correo: data['correo'],
    );
  }

  List<String> _arrayList(String nombre) {
    String temp = "";
    List<String> list = [];
    nombre = nombre.toLowerCase();

    for (var i = 0; i < nombre.length; i++) {
      if (nombre[i] == " ") {
        temp = "";
      } else {
        temp = temp + nombre[i];
        list.add(temp);
      }
    }

    return list;
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'telefono': telefono,
        'correo': correo,
        'keywords': _arrayList(nombre),
      };
}
