from database.connection import get_connection_context


class UsuarioModel:

    @staticmethod
    def criar(nome, email, senha_hash):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "INSERT INTO usuarios (nome, email, senha) VALUES (%s, %s, %s)",
                    (nome, email, senha_hash)
                )
                usuario_id = cursor.lastrowid
                conn.commit()
                return usuario_id
            finally:
                cursor.close()

    @staticmethod
    def listar_todos():
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.execute("SELECT id, nome, email FROM usuarios ORDER BY nome")
                return cursor.fetchall()
            finally:
                cursor.close()

    @staticmethod
    def buscar_por_id(usuario_id):
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.execute(
                    "SELECT id, nome, email FROM usuarios WHERE id = %s",
                    (usuario_id,)
                )
                return cursor.fetchone()
            finally:
                cursor.close()

    @staticmethod
    def buscar_por_email(email):
        with get_connection_context() as conn:
            cursor = conn.cursor(dictionary=True)
            try:
                cursor.execute(
                    "SELECT * FROM usuarios WHERE email = %s",
                    (email,)
                )
                return cursor.fetchone()
            finally:
                cursor.close()

    @staticmethod
    def atualizar_senha(usuario_id, nova_senha_hash):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "UPDATE usuarios SET senha = %s WHERE id = %s",
                    (nova_senha_hash, usuario_id)
                )
                conn.commit()
            finally:
                cursor.close()

    @staticmethod
    def atualizar(usuario_id, nome, email, senha_hash=None):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                if senha_hash:
                    cursor.execute(
                        "UPDATE usuarios SET nome = %s, email = %s, senha = %s WHERE id = %s",
                        (nome, email, senha_hash, usuario_id)
                    )
                else:
                    cursor.execute(
                        "UPDATE usuarios SET nome = %s, email = %s WHERE id = %s",
                        (nome, email, usuario_id)
                    )
                conn.commit()
            finally:
                cursor.close()

    @staticmethod
    def deletar(usuario_id):
        with get_connection_context() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    "DELETE FROM usuarios WHERE id = %s",
                    (usuario_id,)
                )
                conn.commit()
            finally:
                cursor.close()
