"""Local-only API fixture: no external services, database, or credentials."""
import json
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse, parse_qs

state={'mode':'success', 'requests':[]}
lock=threading.Lock()
class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        return
    def do_GET(self):
        url=urlparse(self.path)
        if url.path=='/__audit/mode':
            mode=parse_qs(url.query).get('value',['success'])[0]
            if mode not in {'success','slow_success','unauthorized','invalid_response','server_failure'}:
                self.send_error(400); return
            with lock: state['mode']=mode
            self.reply(200, {'mode':mode}); return
        if url.path=='/__audit/requests':
            with lock: requests=list(state['requests'])
            self.reply(200, requests); return
        with lock:
            mode=state['mode']; state['requests'].append({'path':url.path,'mode':mode,'time':time.time()})
        if mode=='slow_success': time.sleep(.8)
        if mode=='unauthorized': self.reply(401, {'message':'unauthorized'}); return
        if mode=='server_failure': self.reply(503, {'message':'unavailable'}); return
        if mode=='invalid_response': self.reply(200, {'id':False, 'visits':'wrong'}); return
        self.reply(200, {'id':'CLEANY_LOCAL_OK' if url.path=='/home' else 'CATALOG_LOCAL_OK', 'title':'Local API response', 'visits':42})
    def reply(self, code, data):
        body=json.dumps(data).encode()
        self.send_response(code); self.send_header('Content-Type','application/json'); self.send_header('Content-Length',str(len(body)));self.end_headers();self.wfile.write(body)

if __name__=='__main__':
    server=ThreadingHTTPServer(('127.0.0.1',8787),Handler)
    print('Cleany audit API listening on http://127.0.0.1:8787',flush=True)
    server.serve_forever()
