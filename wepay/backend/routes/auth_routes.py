from flask import Blueprint
from controllers.auth_controller import AuthController
from middlewares.auth_middleware import token_required

auth_bp = Blueprint('auth_bp', __name__)

auth_bp.route('/register', methods=['POST'])(AuthController.registrar)
auth_bp.route('/cadastro', methods=['POST'])(AuthController.registrar)
auth_bp.route('/login', methods=['POST'])(AuthController.login)
auth_bp.route('/logout', methods=['POST'])(AuthController.logout)

@auth_bp.route('/me', methods=['GET'])
@token_required
def perfil(current_user_id):
    return AuthController.perfil(current_user_id)

@auth_bp.route('/atualizar', methods=['PUT'])
@token_required
def atualizar(current_user_id):
    return AuthController.atualizar(current_user_id)

@auth_bp.route('/delete', methods=['DELETE'])
@token_required
def deletar(current_user_id):
    return AuthController.deletar(current_user_id)