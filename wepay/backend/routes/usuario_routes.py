from flask import Blueprint
from controllers.usuario_controller import UsuarioController
from middlewares.auth_middleware import token_required

usuario_bp = Blueprint('usuario_bp', __name__)

usuario_bp.route('/recover', methods=['POST'])(UsuarioController.recuperar_senha)
usuario_bp.route('/recuperar-senha', methods=['POST'])(UsuarioController.recuperar_senha)
usuario_bp.route('/test-email', methods=['POST'])(UsuarioController.testar_email)
usuario_bp.route('/update', methods=['POST'])(UsuarioController.atualizar_senha)

@usuario_bp.route('', methods=['GET'])
@token_required
def listar(current_user_id):
    return UsuarioController.listar()