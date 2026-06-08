from utils.response_utils import ResponseUtils
from database.connection import get_connection_context

class DashboardController:
    @staticmethod
    def obter_dados(current_user_id):
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)

            cursor.execute(
                "SELECT COALESCE(SUM(s.saldo), 0) as total FROM saldos s WHERE s.usuario_id = %s AND s.saldo > 0",
                (current_user_id,)
            )
            receber = float(cursor.fetchone()['total'])

            cursor.execute(
                "SELECT COALESCE(SUM(ABS(s.saldo)), 0) as total FROM saldos s WHERE s.usuario_id = %s AND s.saldo < 0",
                (current_user_id,)
            )
            pagar = float(cursor.fetchone()['total'])

            cursor.execute(
                "SELECT COUNT(DISTINCT g.id) as qtd FROM grupos g "
                "JOIN participantes p ON p.grupo_id = g.id "
                "WHERE p.usuario_id = %s",
                (current_user_id,)
            )
            total_grupos = cursor.fetchone()['qtd']

            cursor.execute(
                "SELECT COALESCE(SUM(d.valor), 0) as total FROM despesas d "
                "JOIN participantes p ON p.grupo_id = d.grupo_id "
                "WHERE p.usuario_id = %s",
                (current_user_id,)
            )
            total_gasto = float(cursor.fetchone()['total'])

            cursor.close()

        return ResponseUtils.sucesso(dados={
            'receber': receber,
            'pagar': pagar,
            'total_grupos': total_grupos,
            'total_gasto_geral': total_gasto,
        })