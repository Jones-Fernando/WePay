from flask import request
from services.auth_service import AuthService
from utils.response_utils import ResponseUtils

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