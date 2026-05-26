import 'package:intl/intl.dart';

class Formatters {
  static String valorMonetario(double valor) {
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatador.format(valor);
  }

  static String dataFormatada(DateTime data) {
    return DateFormat('dd/MM/yyyy').format(data);
  }
}
