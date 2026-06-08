import json
import urllib.request
import urllib.error

BASE='http://127.0.0.1:5000'

def post(path, body):
    url = BASE+path
    data = json.dumps(body).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers={'Content-Type':'application/json'}, method='POST')
    try:
        resp = urllib.request.urlopen(req)
        return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        return {'error': e.read().decode(), 'status': e.code}

def get(path, headers=None):
    url = BASE+path
    req = urllib.request.Request(url, headers=headers or {}, method='GET')
    try:
        resp = urllib.request.urlopen(req)
        return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        return {'error': e.read().decode(), 'status': e.code}

if __name__=='__main__':
    print('Criando usuario de teste...')
    r = post('/api/auth/cadastro', {'nome':'Teste API','email':'teste+api@example.com','senha':'123456'})
    print('cadastro:', r)

    print('\nTentando login...')
    r2 = post('/api/auth/login', {'email':'teste+api@example.com','senha':'123456'})
    print('login:', r2)
    token = None
    if isinstance(r2, dict) and r2.get('status')=='sucesso':
        token = r2.get('data',{}).get('token')

    print('\nChamando /api/usuarios (deve exigir token)...')
    headers = {'Authorization': f'Bearer {token}'} if token else {}
    r3 = get('/api/usuarios', headers=headers)
    print('usuarios:', r3)
