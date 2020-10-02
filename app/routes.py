from flask import render_template
from app import app
import os
import json

@app.route('/')
@app.route('/index')
def index():
    user = {'username': 'Mundo'}
    posts = [
        {
            'author': {'username': 'Juan'},
            'body': 'Beautiful day in the Philippines!'
        }
    ]
    print(os.environ)
    return render_template('index.html', title='Home', user=user, posts=posts, env=json.dumps(dict(os.environ)))
