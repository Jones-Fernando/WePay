from flask import request
from models.usuario_model import UsuarioModel
from utils.response_utils import ResponseUtils
from services.email_service import EmailService
import secrets

class UsuarioController:
    @staticmethod
    def listar():
        usuarios = UsuarioModel.listar_todos()
        return ResponseUtils.sucesso(dados=usuarios)

    @staticmethod
    def recuperar_senha():
        data = request.get_json() or {}
        email = data.get('email')
        if not email:
            return ResponseUtils.erro("O email eh obrigatorio.")
        
        usuario = UsuarioModel.buscar_por_email(email)
        if not usuario:
            return ResponseUtils.erro("Email nao encontrado.")
        
        nova_senha = secrets.token_hex(4)
        from utils.password_utils import hash_password
        UsuarioModel.atualizar_senha(usuario['id'], hash_password(nova_senha))
        
        enviado = EmailService.enviar_recuperacao_senha(email, nova_senha)
        if not enviado:
            return ResponseUtils.erro("Nao foi possivel enviar o email. Verifique as configuracoes de email no servidor.", status=500)
        
        return ResponseUtils.sucesso(mensagem="Uma nova senha foi enviada ao seu email.")

    @staticmethod
    def testar_email():
        data = request.get_json() or {}
        email = data.get('email')
        if not email:
            return ResponseUtils.erro("O email eh obrigatorio para o teste.")

        enviado = EmailService.enviar_email_teste(email)
        if not enviado:
            return ResponseUtils.erro("Nao foi possivel enviar o email de teste. Verifique as configuracoes de email no servidor.", status=500)

        return ResponseUtils.sucesso(mensagem="Email de teste enviado com sucesso.")

    @staticmethod
    def atualizar_senha():
        data = request.get_json() or {}
        usuario_id = data.get('usuario_id')
        nova_senha = data.get('nova_senha')
        
        if not usuario_id or not nova_senha:
            return ResponseUtils.erro("Dados incompletos.")
            
        from utils.password_utils import hash_password
        UsuarioModel.atualizar_senha(usuario_id, hash_password(nova_senha))
        return ResponseUtils.sucesso(mensagem="Senha atualizada com sucesso.")