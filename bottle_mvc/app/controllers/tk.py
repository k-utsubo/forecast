#!/bin/env python
# coding:utf-8

import sys
sys.path.append('libs')

from bottle import route, post, request, redirect, jinja2_template as template

import app.models.tk
model = app.models.tk.Tk()

#@route('/')
#def index():
#    return template('index')

#一覧ページ
#@route('/tk/list')
@route('/tk/list/<page:int>')
def list(page=1):
    result = model.list(page)
    return template('tk/list', result = result)


#編集ページ
@route('/tk/detail/<id:int>')
def detail(id):
    return template('tk/detail', i = model.detail(id))

