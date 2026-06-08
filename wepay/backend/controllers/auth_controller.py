from flask import request
from services.auth_service import AuthService
from utils.response_utils import ResponseUtils
from models.usuario_model import UsuarioModel
from utils.password_utils import hash_password

class AuthController:
    @staticmethod
    def registrar():
        data = request.get_json() or {}
        nome = data.get('nome')
        email = data.get('email')
        senha = data.get('senha')

        if not nome or not email or not senha:
            return ResponseUtils.erro("Campos obrigatorios ausentes.")

        uid, erro = AuthService.registrar_usuario(nome, email, senha)
        if erro:
            return ResponseUtils.erro(erro)
        return ResponseUtils.sucesso(mensagem="Usuario criado com sucesso.", status=201)

    @staticmethod
    def login():
        data = request.get_json() or {}
        email = data.get('email')
        senha = data.get('senha')

        if not email or not senha:
            return ResponseUtils.erro("Email e senha sao obrigatorios.")

        resultado, erro = AuthService.autenticar_usuario(email, senha)
        if erro:
            return ResponseUtils.erro(erro, status=401)
        return ResponseUtils.sucesso(dados=resultado)

    @staticmethod
    def logout():
        return ResponseUtils.sucesso(mensagem="Logoff realizado com sucesso.")

    @staticmethod
    def perfil(current_user_id):
        usuario = UsuarioModel.buscar_por_id(current_user_id)
        if not usuario:
            return ResponseUtils.erro("Usuario nao encontrado.", status=404)
        return ResponseUtils.sucesso(dados=usuario)

    @staticmethod
    def atualizar(current_user_id):
        data = request.get_json() or {}
        nome = data.get('nome')
        email = data.get('email')
        senha = data.get('senha')

        if not nome or not email:
            return ResponseUtils.erro("Nome e email sao obrigatorios.")

        usuario_existente = UsuarioModel.buscar_por_email(email)
        if usuario_existente and usuario_existente['id'] != current_user_id:
            return ResponseUtils.erro("Email ja cadastrado por outro usuario.")

        senha_hash = hash_password(senha) if senha else None
        UsuarioModel.atualizar(current_user_id, nome, email, senha_hash)
        return ResponseUtils.sucesso(mensagem="Perfil atualizado com sucesso.")

    @staticmethod
    def deletar(current_user_id):
        UsuarioModel.deletar(current_user_id)
        return ResponseUtils.sucesso(mensagem="Conta excluida com sucesso.")