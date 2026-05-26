from flask import request
from models.despesa_model import DespesaModel
from models.grupo_model import GrupoModel
from services.divisao_service import DivisaoService
from utils.response_utils import ResponseUtils


class DespesaController:
    @staticmethod
    def criar(current_user_id):
        data = request.get_json() or {}
        grupo_id = data.get('grupo_id')
        descricao = data.get('descricao', '').strip()
        valor = data.get('valor')
        pagador_id = data.get('pagador_id') or current_user_id

        if not grupo_id:
            return ResponseUtils.erro("grupo_id eh obrigatorio.")
        if not descricao:
            return ResponseUtils.erro("Descricao eh obrigatoria.")
        if valor is None:
            return ResponseUtils.erro("Valor eh obrigatorio.")

        try:
            v_float = float(valor)
        except (ValueError, TypeError):
            return ResponseUtils.erro("Valor invalido.")

        if v_float <= 0:
            return ResponseUtils.erro("Valor deve ser maior que zero.")

        grupo = GrupoModel.buscar_por_id(grupo_id)
        if not grupo:
            return ResponseUtils.erro("Grupo nao encontrado.", status=404)

        despesa_id = DespesaModel.criar(grupo_id, int(pagador_id), descricao, v_float)
        DivisaoService.recalcular_saldos_grupo(grupo_id, v_float, int(pagador_id))
        return ResponseUtils.sucesso(dados={'id': despesa_id}, mensagem="Despesa registrada e dividida.", status=201)

    @staticmethod
    def listar(current_user_id, grupo_id):
        grupo = GrupoModel.buscar_por_id(grupo_id)
        if not grupo:
            return ResponseUtils.erro("Grupo nao encontrado.", status=404)
        lista = DespesaModel.listar_por_grupo(grupo_id)
        return ResponseUtils.sucesso(dados=lista)

    @staticmethod
    def atualizar(current_user_id, despesa_id):
        data = request.get_json() or {}
        descricao = data.get('descricao', '').strip()
        valor = data.get('valor')

        if not descricao:
            return ResponseUtils.erro("Descricao eh obrigatoria.")
        if valor is None:
            return ResponseUtils.erro("Valor eh obrigatorio.")

        try:
            v_float = float(valor)
        except (ValueError, TypeError):
            return ResponseUtils.erro("Valor invalido.")

        if v_float <= 0:
            return ResponseUtils.erro("Valor deve ser maior que zero.")

        despesa_atual = DespesaModel.buscar_por_id(despesa_id)
        if not despesa_atual:
            return ResponseUtils.erro("Despesa nao encontrada.", status=404)

        # Reverter saldo do valor antigo antes de aplicar o novo
        valor_antigo = float(despesa_atual['valor'])
        grupo_id = despesa_atual['grupo_id']
        pagador_id = despesa_atual['pagador_id']

        DivisaoService.reverter_saldos_grupo(grupo_id, valor_antigo, pagador_id)
        DespesaModel.atualizar(despesa_id, descricao, v_float)
        DivisaoService.recalcular_saldos_grupo(grupo_id, v_float, pagador_id)

        return ResponseUtils.sucesso(mensagem="Despesa atualizada.")

    @staticmethod
    def deletar(current_user_id, despesa_id):
        despesa = DespesaModel.buscar_por_id(despesa_id)
        if not despesa:
            return ResponseUtils.erro("Despesa nao encontrada.", status=404)

        # Reverter saldos antes de deletar
        DivisaoService.reverter_saldos_grupo(
            despesa['grupo_id'],
            float(despesa['valor']),
            despesa['pagador_id']
        )
        DespesaModel.deletar(despesa_id)
        return ResponseUtils.sucesso(mensagem="Despesa deletada.")
