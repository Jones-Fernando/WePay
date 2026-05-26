from database.connection import get_connection_context


class GrupoModel:
    @staticmethod
    def criar(nome, descricao, criado_por):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "INSERT INTO grupos (nome, descricao, criado_por) VALUES (%s, %s, %s)",
                    (nome, descricao, criado_por)
                )
                grupo_id = cursor.lastrowid
                conn.commit()
                return grupo_id
            finally:
                cursor.close()

    @staticmethod
    def listar_por_usuario(usuario_id):
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.execute("""
                    SELECT g.id, g.nome, g.descricao, g.criado_por,
                           COALESCE(s_user.saldo, 0) as saldo,
                           COUNT(DISTINCT p.usuario_id) as participantes
                    FROM grupos g
                    INNER JOIN participantes me ON me.grupo_id = g.id AND me.usuario_id = %s
                    LEFT JOIN saldos s_user ON s_user.grupo_id = g.id AND s_user.usuario_id = %s
                    LEFT JOIN participantes p ON p.grupo_id = g.id
                    GROUP BY g.id
                    ORDER BY g.nome
                """, (usuario_id, usuario_id))
                rows = cursor.fetchall()
                for r in rows:
                    r['saldo'] = float(r['saldo'])
                return rows
            finally:
                cursor.close()

    @staticmethod
    def listar_todos():
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.execute("""
                    SELECT g.id, g.nome, g.descricao, g.criado_por,
                           COALESCE(SUM(s.saldo), 0) as saldo,
                           COUNT(DISTINCT p.usuario_id) as participantes
                    FROM grupos g
                    LEFT JOIN saldos s ON s.grupo_id = g.id
                    LEFT JOIN participantes p ON p.grupo_id = g.id
                    GROUP BY g.id
                """)
                rows = cursor.fetchall()
                for r in rows:
                    r['saldo'] = float(r['saldo'])
                return rows
            finally:
                cursor.close()

    @staticmethod
    def buscar_por_id(grupo_id):
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.execute("SELECT * FROM grupos WHERE id = %s", (grupo_id,))
                return cursor.fetchone()
            finally:
                cursor.close()

    @staticmethod
    def atualizar(grupo_id, nome, descricao):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "UPDATE grupos SET nome = %s, descricao = %s WHERE id = %s",
                    (nome, descricao, grupo_id)
                )
                conn.commit()
            finally:
                cursor.close()

    @staticmethod
    def deletar(grupo_id):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute("DELETE FROM grupos WHERE id = %s", (grupo_id,))
                conn.commit()
            finally:
                cursor.close()
