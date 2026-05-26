from flask import request
from models.participante_model import ParticipanteModel
from models.grupo_model import GrupoModel
from models.usuario_model import UsuarioModel
from models.saldo_model import SaldoModel
from utils.response_utils import ResponseUtils


class ParticipanteController:
    @staticmethod
    def adicionar(current_user_id):
        data = request.get_json() or {}
        grupo_id = data.get('grupo_id')
        usuario_id = data.get('usuario_id')

        if not grupo_id or not usuario_id:
            return ResponseUtils.erro("grupo_id e usuario_id sao obrigatorios.")

        grupo = GrupoModel.buscar_por_id(grupo_id)
        if not grupo:
            return ResponseUtils.erro("Grupo nao encontrado.", status=404)

        usuario = UsuarioModel.buscar_por_id(usuario_id)
        if not usuario:
            return ResponseUtils.erro("Usuario nao encontrado.", status=404)

        ja_existe = ParticipanteModel.buscar(grupo_id, usuario_id)
        if ja_existe:
            return ResponseUtils.erro("Usuario ja e participante deste grupo.")

        ParticipanteModel.adicionar(grupo_id, usuario_id)
        SaldoModel.inicializar_saldo(grupo_id, usuario_id)
        return ResponseUtils.sucesso(mensagem="Participante adicionado.", status=201)

    @staticmethod
    def listar(current_user_id, grupo_id):
        grupo = GrupoModel.buscar_por_id(grupo_id)
        if not grupo:
            return ResponseUtils.erro("Grupo nao encontrado.", status=404)
        lista = ParticipanteModel.listar_por_grupo(grupo_id)
        return ResponseUtils.sucesso(dados=lista)

    @staticmethod
    def remover(current_user_id, participante_id):
        participante = ParticipanteModel.buscar_por_id(participante_id)
        if not participante:
            return ResponseUtils.erro("Participante nao encontrado.", status=404)
        ParticipanteModel.remover_por_id(participante_id)
        return ResponseUtils.sucesso(mensagem="Participante removido.")
