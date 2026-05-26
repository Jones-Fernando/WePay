from functools import wraps
from flask import request
from config import Config
from utils.response_utils import ResponseUtils

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None

        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            parts = auth_header.split()
            if len(parts) == 2 and parts[0] == 'Bearer':
                token = parts[1]

        if not token:
            return ResponseUtils.erro(
                "Token nao fornecido.",
                status=401
            )

        try:
            if token.startswith("token_"):
                token_parts = token.split("_")
                current_user_id = int(token_parts[1])
            else:
                return ResponseUtils.erro(
                    "Token invalido.",
                    status=401
                )
        except Exception:
            return ResponseUtils.erro(
                "Token invalido.",
                status=401
            )

        return f(current_user_id, *args, **kwargs)

    return decorated
