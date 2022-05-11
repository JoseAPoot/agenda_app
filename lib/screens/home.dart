import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agenda_app/helpers/agregar_contact.dart';

import 'package:agenda_app/models/contacto.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _BuscarProvider(),
      child: Builder(builder: (context) {
        final bool buscar = Provider.of<_BuscarProvider>(context).buscar;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: buscar ? _appBarBuscar(context) : _appBarTitulo(context),
          body: const _ListaContactos(),
          floatingActionButton: const _AgregarContacto(),
        );
      }),
    );
  }

  AppBar _appBarTitulo(BuildContext context) {
    return AppBar(
      title: const Hero(tag: 1, child: Text('Agenda')),
      actions: [
        FadeIn(
          child: IconButton(
            onPressed: () {
              final _provider = Provider.of<_BuscarProvider>(
                context,
                listen: false,
              );

              _provider.buscar = !_provider.buscar;
              _provider.cambiaTexto('');
            },
            icon: const Icon(Icons.search_rounded),
          ),
        )
      ],
    );
  }

  AppBar _appBarBuscar(BuildContext context) {
    final _provider = Provider.of<_BuscarProvider>(
      context,
    );

    return AppBar(
      leading: FadeIn(
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black38),
          onPressed: () {
            _provider.buscar = !_provider.buscar;
            _provider.cambiaTexto('');
          },
        ),
      ),
      title: Center(
        child: Hero(
          tag: 1,
          child: TextField(
            //controller: _provider.txtBuscar,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Buscar...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.black38),
            ),
            onChanged: (String text) {
              _provider.cambiaTexto(text.trim());
            },
          ),
        ),
      ),
      actions: _provider.txtBuscar.text == ''
          ? null
          : [
              SlideInRight(
                duration: const Duration(milliseconds: 100),
                child: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black38),
                  onPressed: () {
                    _provider.cambiaTexto('');
                  },
                ),
              ),
            ],
    );
  }
}

class _ListaContactos extends StatelessWidget {
  const _ListaContactos({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _provider = Provider.of<_BuscarProvider>(
      context,
    );

    return StreamBuilder<QuerySnapshot>(
      stream: _provider.txtBuscar.text != ''
          ? FirebaseFirestore.instance
              .collection('contactos')
              .where('keywords', arrayContains: _provider.txtBuscar.text)
              .snapshots()
          : FirebaseFirestore.instance
              .collection('contactos')
              .orderBy('nombre')
              .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Ocurrio error'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return _TileContacto(contacto: Contacto.fromFirestore(docs[index]));
          },
        );
      },
    );
  }
}

class _TileContacto extends StatelessWidget {
  final Contacto contacto;

  const _TileContacto({
    Key? key,
    required this.contacto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      leading: const CircleAvatar(
        child: Icon(Icons.person),
        foregroundColor: Colors.teal,
      ),
      title: Text(contacto.nombre),
      subtitle: SizedBox(
        height: 40.0,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ContactoPropiedad(
              icon: Icons.phone_rounded,
              data: contacto.telefono,
            ),
            _ContactoPropiedad(
              icon: Icons.alternate_email_rounded,
              data: contacto.correo,
            ),
          ],
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_rounded, color: Colors.grey),
        onPressed: () async {
          await FirebaseFirestore.instance
              .collection('contactos')
              .doc(contacto.id)
              .delete();
        },
      ),
      onTap: () => agregarContacto(context, contacto),
    );
  }
}

class _ContactoPropiedad extends StatelessWidget {
  final IconData icon;
  final String data;

  const _ContactoPropiedad({
    Key? key,
    required this.icon,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12.0,
          color: Theme.of(context).primaryColor.withOpacity(0.6),
        ),
        const SizedBox(width: 5.0),
        Text(
          data,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _AgregarContacto extends StatelessWidget {
  const _AgregarContacto({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      icon: const Icon(Icons.add),
      label: const Text('Agregar'),
      onPressed: () => agregarContacto(context, Contacto()),
    );
  }
}

class _BuscarProvider with ChangeNotifier {
  bool _buscar = false;
  final TextEditingController _txtBuscar = TextEditingController(text: '');

  bool get buscar => _buscar;
  set buscar(bool value) {
    _buscar = value;

    notifyListeners();
  }

  void cambiaTexto(String text) {
    _txtBuscar.text = text;
    notifyListeners();
  }

  TextEditingController get txtBuscar => _txtBuscar;
}
