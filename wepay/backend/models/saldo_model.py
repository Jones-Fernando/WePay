from database.connection import get_connection_context


class SaldoModel:

    @staticmethod
    def buscar_por_usuario(grupo_id, usuario_id):
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.execute(
                    "SELECT * FROM saldos WHERE grupo_id = %s AND usuario_id = %s",
                    (grupo_id, usuario_id)
                )
                return cursor.fetchone()
            finally:
                cursor.close()

    @staticmethod
    def inicializar_saldo(grupo_id, usuario_id):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "INSERT IGNORE INTO saldos (grupo_id, usuario_id, saldo) VALUES (%s, %s, 0.00)",
                    (grupo_id, usuario_id)
                )
                conn.commit()
            finally:
                cursor.close()

    @staticmethod
    def atualizar_saldo(grupo_id, usuario_id, novo_saldo):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "UPDATE saldos SET saldo = %s WHERE grupo_id = %s AND usuario_id = %s",
                    (novo_saldo, grupo_id, usuario_id)
                )
                conn.commit()
            finally:
                cursor.close()

    @staticmethod
    def listar_saldos_grupo(grupo_id):
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.execute("""
                    SELECT s.id, s.usuario_id, s.saldo, u.nome, u.email
                    FROM saldos s
                    JOIN usuarios u ON s.usuario_id = u.id
                    WHERE s.grupo_id = %s
                    ORDER BY s.saldo DESC
                """, (grupo_id,))
                rows = cursor.fetchall()
                for r in rows:
                    r['saldo'] = float(r['saldo'])
                return rows
            finally:
                cursor.close()

    @staticmethod
    def criar(grupo_id, usuario_id, saldo):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "INSERT INTO saldos (grupo_id, usuario_id, saldo) VALUES (%s, %s, %s)",
                    (grupo_id, usuario_id, saldo)
                )
                saldo_id = cursor.lastrowid
                conn.commit()
                return saldo_id
            finally:
                cursor.close()

    @staticmethod
    def buscar_por_id(saldo_id):
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.execute(
                    "SELECT * FROM saldos WHERE id = %s",
                    (saldo_id,)
                )
                row = cursor.fetchone()
                if row:
                    row['saldo'] = float(row['saldo'])
                return row
            finally:
                cursor.close()

    @staticmethod
    def atualizar_por_id(saldo_id, novo_saldo, usuario_id=None):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                if usuario_id is None:
                    cursor.execute(
                        "UPDATE saldos SET saldo = %s WHERE id = %s",
                        (novo_saldo, saldo_id)
                    )
                else:
                    cursor.execute(
                        "UPDATE saldos SET saldo = %s, usuario_id = %s WHERE id = %s",
                        (novo_saldo, usuario_id, saldo_id)
                    )
                conn.commit()
            finally:
                cursor.close()

    @staticmethod
    def deletar_por_id(saldo_id):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "DELETE FROM saldos WHERE id = %s",
                    (saldo_id,)
                )
                conn.commit()
            finally:
                cursor.close()
