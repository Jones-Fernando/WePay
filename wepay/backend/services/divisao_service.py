from database.connection import get_connection_context


class DivisaoService:

    @staticmethod
    def recalcular_saldos_grupo(grupo_id, valor_total, pagador_id):
        """Distribui o valor da despesa entre os participantes do grupo."""
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.execute("""
                    SELECT p.usuario_id, COALESCE(s.saldo, 0) as saldo
                    FROM participantes p
                    LEFT JOIN saldos s ON s.grupo_id = p.grupo_id AND s.usuario_id = p.usuario_id
                    WHERE p.grupo_id = %s
                """, (grupo_id,))
                participantes = cursor.fetchall()
            finally:
                cursor.close()

        if not participantes:
            return False

        total_membros = len(participantes)
        valor_por_pessoa = round(valor_total / total_membros, 2)

        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                for p in participantes:
                    uid = p['usuario_id']
                    saldo_atual = float(p['saldo'])

                    if int(uid) == int(pagador_id):
                        novo_saldo = round(saldo_atual + (valor_total - valor_por_pessoa), 2)
                    else:
                        novo_saldo = round(saldo_atual - valor_por_pessoa, 2)

                    cursor.execute("""
                        INSERT INTO saldos (grupo_id, usuario_id, saldo)
                        VALUES (%s, %s, %s)
                        ON DUPLICATE KEY UPDATE saldo = %s
                    """, (grupo_id, uid, novo_saldo, novo_saldo))

                conn.commit()
            finally:
                cursor.close()

        return True

    @staticmethod
    def reverter_saldos_grupo(grupo_id, valor_total, pagador_id):
        """Reverte o impacto de uma despesa nos saldos (usado ao editar ou deletar)."""
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.execute("""
                    SELECT p.usuario_id, COALESCE(s.saldo, 0) as saldo
                    FROM participantes p
                    LEFT JOIN saldos s ON s.grupo_id = p.grupo_id AND s.usuario_id = p.usuario_id
                    WHERE p.grupo_id = %s
                """, (grupo_id,))
                participantes = cursor.fetchall()
            finally:
                cursor.close()

        if not participantes:
            return False

        total_membros = len(participantes)
        valor_por_pessoa = round(valor_total / total_membros, 2)

        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                for p in participantes:
                    uid = p['usuario_id']
                    saldo_atual = float(p['saldo'])

                    # Operação inversa do recalcular
                    if int(uid) == int(pagador_id):
                        novo_saldo = round(saldo_atual - (valor_total - valor_por_pessoa), 2)
                    else:
                        novo_saldo = round(saldo_atual + valor_por_pessoa, 2)

                    cursor.execute(
                        "UPDATE saldos SET saldo = %s WHERE grupo_id = %s AND usuario_id = %s",
                        (novo_saldo, grupo_id, uid)
                    )

                conn.commit()
            finally:
                cursor.close()

        return True
