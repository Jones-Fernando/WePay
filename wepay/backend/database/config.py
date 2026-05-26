import os
from pathlib import Path
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent
dotenv_path = BASE_DIR / '.env'
load_dotenv(dotenv_path)

class Config:
    DB_HOST = os.getenv('DB_HOST', 'localhost')
    DB_USER = os.getenv('DB_USER', 'root')
    DB_PASSWORD = os.getenv('DB_PASSWORD', 'jones@123')
    DB_NAME = os.getenv('DB_NAME', 'wepay_db')

    SECRET_KEY = os.getenv(
        'SECRET_KEY',
        'wepay_chave_secreta_2026'
    )

    EMAIL_REMETENTE = os.getenv('EMAIL_REMETENTE', '')
    EMAIL_SENHA_APP = os.getenv('EMAIL_SENHA_APP', '')
    EMAIL_SERVER = os.getenv('EMAIL_SERVER', 'smtp.gmail.com')
    EMAIL_PORT = int(os.getenv('EMAIL_PORT', 465))
