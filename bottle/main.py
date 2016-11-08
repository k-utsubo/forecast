from bottle import route,get,post,request, run

import w2v
import tkd2v

@route('/')
def root():
  return """
    <a href='w2v'>Wikipedia,Word2Vec</a><br>
    <a href='tkd2v'>Shikiho,Doc2Vec</a><br>
  """

@get('/w2v')
def get_w2v():
    return w2v.get()
@post('/w2v')
def post_w2v():
    return w2v.post(request)

@get('/tkd2v')
def get_tkd2v():
    return tkd2v.get()
@post('/tkd2v')
def post_tkd2v():
    return tkd2v.post(request)

run(host='localhost', port=8080, debug=True, reloader=True)
