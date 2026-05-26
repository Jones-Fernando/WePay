from database.connection import get_connection, get_connection_context

class DespesaModel:
    @staticmethod
    def criar(grupo_id, pagador_id, descricao, valor):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                query = "INSERT INTO despesas (grupo_id, pagador_id, descricao, valor) VALUES (%s, %s, %s, %s)"
                cursor.execute(query, (grupo_id, pagador_id, descricao, valor))
                despesa_id = cursor.lastrowid
                conn.commit()
                return despesa_id
            finally:
                cursor.close()

    @staticmethod
    def listar_por_grupo(grupo_id):
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                query = """
                    SELECT d.id, d.grupo_id, d.pagador_id, d.descricao, d.valor,
                           d.data_despesa as data, u.nome as pagador
                    FROM despesas d
                    JOIN usuarios u ON d.pagador_id = u.id
                    WHERE d.grupo_id = %s
                    ORDER BY d.data_despesa DESC
                """
                cursor.execute(query, (grupo_id,))
                rows = cursor.fetchall()
                for r in rows:
                    if r.get('data'):
                        r['data'] = str(r['data'])
                    if r.get('valor'):
                        r['valor'] = float(r['valor'])
                return rows
            finally:
                cursor.close()

    @staticmethod
    def buscar_por_id(despesa_id):
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                query = "SELECT * FROM despesas WHERE id = %s"
                cursor.execute(query, (despesa_id,))
                return cursor.fetchone()
            finally:
                cursor.close()

    @staticmethod
    def atualizar(despesa_id, descricao, valor):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                query = "UPDATE despesas SET descricao = %s, valor = %s WHERE id = %s"
                cursor.execute(query, (descricao, valor, despesa_id))
                conn.commit()
            finally:
                cursor.close()

    @staticmethod
    def deletar(despesa_id):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                query = "DELETE FROM despesas WHERE id = %s"
                cursor.execute(query, (despesa_id,))
                conn.commit()
            finally:
                cursor.close()