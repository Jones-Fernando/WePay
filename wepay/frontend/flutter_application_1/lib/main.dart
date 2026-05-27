import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/auth/login_views.dart';
import 'package:flutter_application_1/views/auth/cadastro_views.dart';
import 'package:flutter_application_1/views/auth/recuperar_senha_view.dart';
import 'package:flutter_application_1/views/home/dashboard_views.dart';
import 'package:flutter_application_1/views/grupos/grupo_form_view.dart';
import 'package:flutter_application_1/views/grupos/grupo_lista_view.dart';
import 'package:flutter_application_1/views/despesas/despesa_lista_view.dart';
import 'package:flutter_application_1/views/despesas/despesa_form_view.dart';
import 'package:flutter_application_1/views/participantes/participante_lista_view.dart';
import 'package:flutter_application_1/views/saldos/saldo_lista_view.dart';

void main() {
  runApp(const WePayApp());
}

class WePayApp extends StatelessWidget {
  const WePayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WePay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginView(),
        '/cadastro': (context) => CadastroView(),
        '/recuperar': (context) => RecuperarSenhaView(),
        '/dashboard': (context) => DashboardView(),
        '/grupos': (context) => GrupoListaView(),
        '/grupo-form': (context) => GrupoFormView(),
        '/despesas': (context) => DespesaListaView(),
        '/despesa-form': (context) => DespesaFormView(),
        '/participantes': (context) => ParticipanteListaView(),
        '/saldos': (context) => SaldoListaView(),
      },
    );
  }
}
