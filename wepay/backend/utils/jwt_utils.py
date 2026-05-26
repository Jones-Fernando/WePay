import secrets

def generate_token(usuario_id):
    return f"token_{usuario_id}_{secrets.token_hex(16)}"