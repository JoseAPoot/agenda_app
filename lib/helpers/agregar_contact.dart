import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agenda_app/widgets/input.dart';

import 'package:agenda_app/models/contacto.dart';

agregarContacto(BuildContext context, Contacto contacto) {
  TextEditingController txtNombre = TextEditingController(
    text: contacto.nombre,
  );
  TextEditingController txtTelefono = TextEditingController(
    text: contacto.telefono,
  );
  TextEditingController txtCorreo = TextEditingController(
    text: contacto.correo,
  );

  final _dialog = WillPopScope(
    onWillPop: () async => false,
    child: AlertDialog(
      clipBehavior: Clip.antiAlias,
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      title: const Text(
        'Contacto',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      content: _FormContacto(
        txtNombre: txtNombre,
        txtTelefono: txtTelefono,
        txtCorreo: txtCorreo,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'CERRAR',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () async {
            contacto.nombre = txtNombre.text.trim();
            contacto.telefono = txtTelefono.text.trim();
            contacto.correo = txtCorreo.text.trim();

            bool ok = await submit(contacto);

            if (ok) {
              Navigator.pop(context);
            }
          },
          child: const Text(
            'GUARDAR',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => _dialog,
  );
}

Future<bool> submit(Contacto c) async {
  if (c.nombre.isNotEmpty && (c.telefono.isNotEmpty || c.correo.isNotEmpty)) {
    CollectionReference cs = FirebaseFirestore.instance.collection('contactos');

    if (c.id.isEmpty) {
      await cs.add(c.toJson());
    } else {
      await cs.doc(c.id).set(c.toJson());
    }

    return true;
  }

  return false;
}

class _FormContacto extends StatelessWidget {
  final TextEditingController txtNombre;
  final TextEditingController txtTelefono;
  final TextEditingController txtCorreo;

  const _FormContacto({
    Key? key,
    required this.txtNombre,
    required this.txtTelefono,
    required this.txtCorreo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180.0,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: [
          Input(
            hintText: 'Nombre',
            prefixIcon: Icons.person_rounded,
            textCapitalization: TextCapitalization.words,
            textEditingController: txtNombre,
          ),
          Input(
            hintText: 'Teléfono',
            prefixIcon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            textEditingController: txtTelefono,
          ),
          Input(
            hintText: 'Correo',
            prefixIcon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textEditingController: txtCorreo,
          ),
        ],
      ),
    );
  }
}
