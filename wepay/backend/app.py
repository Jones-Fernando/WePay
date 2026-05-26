from flask import Flask
from flask_cors import CORS
from config import Config

from routes.auth_routes import auth_bp
from routes.usuario_routes import usuario_bp
from routes.grupo_routes import grupo_bp
from routes.participante_routes import participante_bp
from routes.despesa_routes import despesa_bp
from routes.saldo_routes import saldo_bp
from routes.dashboard_routes import dashboard_bp

app = Flask(__name__)
app.config.from_object(Config)
CORS(app)

app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(usuario_bp, url_prefix='/api/usuarios')
app.register_blueprint(grupo_bp, url_prefix='/api/grupos')
app.register_blueprint(participante_bp, url_prefix='/api/participantes')
app.register_blueprint(despesa_bp, url_prefix='/api/despesas')
app.register_blueprint(saldo_bp, url_prefix='/api/saldos')
app.register_blueprint(dashboard_bp, url_prefix='/api/dashboard')

@app.route('/', methods=['GET'])
def index():
    return {"status": "Online", "projeto": "wepay"}, 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)