from database.connection import get_connection_context


class ParticipanteModel:

    @staticmethod
    def adicionar(grupo_id, usuario_id):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "INSERT INTO participantes (grupo_id, usuario_id) VALUES (%s, %s)",
                    (grupo_id, usuario_id)
                )
                conn.commit()
            finally:
                cursor.close()

    @staticmethod
    def buscar(grupo_id, usuario_id):
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.execute(
                    "SELECT * FROM participantes WHERE grupo_id = %s AND usuario_id = %s",
                    (grupo_id, usuario_id)
                )
                return cursor.fetchone()
            finally:
                cursor.close()

    @staticmethod
    def buscar_por_id(participante_id):
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.execute(
                    "SELECT * FROM participantes WHERE id = %s",
                    (participante_id,)
                )
                return cursor.fetchone()
            finally:
                cursor.close()

    @staticmethod
    def listar_por_grupo(grupo_id):
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.execute("""
                    SELECT p.id, p.grupo_id, p.usuario_id, u.nome, u.email
                    FROM participantes p
                    JOIN usuarios u ON p.usuario_id = u.id
                    WHERE p.grupo_id = %s
                    ORDER BY u.nome
                """, (grupo_id,))
                return cursor.fetchall()
            finally:
                cursor.close()

    @staticmethod
    def remover(grupo_id, usuario_id):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "DELETE FROM participantes WHERE grupo_id = %s AND usuario_id = %s",
                    (grupo_id, usuario_id)
                )
                conn.commit()
            finally:
                cursor.close()

    @staticmethod
    def remover_por_id(participante_id):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "DELETE FROM participantes WHERE id = %s",
                    (participante_id,)
                )
                conn.commit()
            finally:
                cursor.close()

    @staticmethod
    def add_registro_ignore(grupo_id, usuario_id):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "INSERT IGNORE INTO participantes (grupo_id, usuario_id) VALUES (%s, %s)",
                    (grupo_id, usuario_id)
                )
                conn.commit()
            finally:
                cursor.close()
