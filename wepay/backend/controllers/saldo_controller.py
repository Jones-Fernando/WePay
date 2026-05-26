from utils.response_utils import ResponseUtils
from models.saldo_model import SaldoModel

class SaldoController:
    @staticmethod
    def ver_saldos(current_user_id, grupo_id):
        saldos = SaldoModel.listar_saldos_grupo(grupo_id)
        return ResponseUtils.sucesso(dados=saldos)