from flask import request
from models.grupo_model import GrupoModel
from models.participante_model import ParticipanteModel
from models.saldo_model import SaldoModel
from utils.response_utils import ResponseUtils


class GrupoController:
    @staticmethod
    def criar(current_user_id):
        data = request.get_json() or {}
        nome = data.get('nome', '').strip()
        descricao = data.get('descricao', '').strip() or None

        if not nome:
            return ResponseUtils.erro("Nome do grupo eh obrigatorio.")
        if len(nome) < 2:
            return ResponseUtils.erro("Nome do grupo deve ter ao menos 2 caracteres.")

        grupo_id = GrupoModel.criar(nome, descricao, current_user_id)
        ParticipanteModel.add_registro_ignore(grupo_id, current_user_id)
        SaldoModel.inicializar_saldo(grupo_id, current_user_id)
        return ResponseUtils.sucesso(dados={'id': grupo_id}, mensagem="Grupo criado.", status=201)

    @staticmethod
    def listar(current_user_id):
        grupos = GrupoModel.listar_por_usuario(current_user_id)
        return ResponseUtils.sucesso(dados=grupos)

    @staticmethod
    def atualizar(current_user_id, grupo_id):
        data = request.get_json() or {}
        nome = data.get('nome', '').strip()
        if not nome:
            return ResponseUtils.erro("Nome do grupo eh obrigatorio.")

        grupo_atual = GrupoModel.buscar_por_id(grupo_id)
        if not grupo_atual:
            return ResponseUtils.erro("Grupo nao encontrado.", status=404)

        descricao = data.get('descricao', grupo_atual.get('descricao'))
        GrupoModel.atualizar(grupo_id, nome, descricao)
        return ResponseUtils.sucesso(mensagem="Grupo atualizado.")

    @staticmethod
    def deletar(current_user_id, grupo_id):
        grupo = GrupoModel.buscar_por_id(grupo_id)
        if not grupo:
            return ResponseUtils.erro("Grupo nao encontrado.", status=404)
        GrupoModel.deletar(grupo_id)
        return ResponseUtils.sucesso(mensagem="Grupo removido.")
