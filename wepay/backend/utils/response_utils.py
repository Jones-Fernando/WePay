from flask import jsonify

class ResponseUtils:
    @staticmethod
    def sucesso(dados=None, mensagem=None, status=200):
        resposta = {'status': 'sucesso'}
        if mensagem:
            resposta['mensagem'] = mensagem
            resposta['message'] = mensagem
        if dados is not None:
            resposta['data'] = dados
        return jsonify(resposta), status

    @staticmethod
    def erro(mensagem, status=400):
        texto = str(mensagem).replace('"', '').replace("'", "")
        return jsonify({'status': 'erro', 'mensagem': texto, 'message': texto}), status