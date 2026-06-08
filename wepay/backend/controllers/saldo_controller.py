from flask import request
from utils.response_utils import ResponseUtils
from models.saldo_model import SaldoModel
from models.grupo_model import GrupoModel
from models.usuario_model import UsuarioModel
from models.participante_model import ParticipanteModel

class SaldoController:
    @staticmethod
    def ver_saldos(current_user_id, grupo_id):
        grupo = GrupoModel.buscar_por_id(grupo_id)
        if not grupo:
            return ResponseUtils.erro("Grupo nao encontrado.", status=404)
        if not ParticipanteModel.buscar(grupo_id, current_user_id):
            return ResponseUtils.erro("Voce nao participa deste grupo.", status=403)
        saldos = SaldoModel.listar_saldos_grupo(grupo_id)
        return ResponseUtils.sucesso(dados=saldos)

    @staticmethod
    def criar(current_user_id):
        data = request.get_json() or {}
        grupo_id = data.get('grupo_id')
        usuario_id = data.get('usuario_id')
        saldo = data.get('saldo')

        if not grupo_id or not usuario_id or saldo is None:
            return ResponseUtils.erro("grupo_id, usuario_id e saldo sao obrigatorios.")

        grupo = GrupoModel.buscar_por_id(grupo_id)
        if not grupo:
            return ResponseUtils.erro("Grupo nao encontrado.", status=404)
        if not ParticipanteModel.buscar(grupo_id, current_user_id):
            return ResponseUtils.erro("Voce nao participa deste grupo.", status=403)

        try:
            valor_saldo = float(saldo)
        except (ValueError, TypeError):
            return ResponseUtils.erro("Valor de saldo invalido.")

        usuario = UsuarioModel.buscar_por_id(usuario_id)
        if not usuario:
            return ResponseUtils.erro("Usuario nao encontrado.", status=404)

        if not ParticipanteModel.buscar(grupo_id, usuario_id):
            return ResponseUtils.erro("Usuario precisa ser participante do grupo.", status=400)

        saldo_id = SaldoModel.criar(grupo_id, usuario_id, valor_saldo)
        return ResponseUtils.sucesso(dados={'id': saldo_id}, mensagem="Saldo criado.", status=201)

    @staticmethod
    def atualizar(current_user_id, saldo_id):
        data = request.get_json() or {}
        saldo = data.get('saldo')
        usuario_id = data.get('usuario_id')

        if saldo is None:
            return ResponseUtils.erro("Saldo eh obrigatorio.")

        registro = SaldoModel.buscar_por_id(saldo_id)
        if not registro:
            return ResponseUtils.erro("Saldo nao encontrado.", status=404)
        if not ParticipanteModel.buscar(registro['grupo_id'], current_user_id):
            return ResponseUtils.erro("Voce nao participa deste grupo.", status=403)

        try:
            valor_saldo = float(saldo)
        except (ValueError, TypeError):
            return ResponseUtils.erro("Valor de saldo invalido.")

        if usuario_id is not None:
            usuario = UsuarioModel.buscar_por_id(usuario_id)
            if not usuario:
                return ResponseUtils.erro("Usuario nao encontrado.", status=404)
            if not ParticipanteModel.buscar(registro['grupo_id'], usuario_id):
                return ResponseUtils.erro("Usuario precisa ser participante do grupo.", status=400)

        SaldoModel.atualizar_por_id(saldo_id, valor_saldo, usuario_id)
        return ResponseUtils.sucesso(mensagem="Saldo atualizado.")

    @staticmethod
    def deletar(current_user_id, saldo_id):
        registro = SaldoModel.buscar_por_id(saldo_id)
        if not registro:
            return ResponseUtils.erro("Saldo nao encontrado.", status=404)
        if not ParticipanteModel.buscar(registro['grupo_id'], current_user_id):
            return ResponseUtils.erro("Voce nao participa deste grupo.", status=403)

        SaldoModel.deletar_por_id(saldo_id)
        return ResponseUtils.sucesso(mensagem="Saldo removido.")