import os
import json
from functools import wraps
from flask import Flask, render_template, request, redirect, url_for, session
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', '你可以换成一个更随机的字符串')

# 配置生产环境设置
if os.environ.get('FLASK_ENV') == 'production':
    app.config['SESSION_COOKIE_SECURE'] = True
    app.config['SESSION_COOKIE_HTTPONLY'] = True
    app.config['PERMANENT_SESSION_LIFETIME'] = 1800  # 30分钟session过期

USERS_FILE = 'users.json'
# 如果 users.json 不存在，初始化一个空字典
if not os.path.exists(USERS_FILE):
    with open(USERS_FILE, 'w') as f:
        json.dump({}, f)

def load_users():
    with open(USERS_FILE, 'r') as f:
        return json.load(f)

def save_users(users):
    with open(USERS_FILE, 'w') as f:
        json.dump(users, f)

def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'username' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated

# 内存中的 To-Do 列表（示例）
todo_list = []

@app.route('/')
@login_required
def index():
    return render_template('index.html', todos=todo_list, user=session['username'])

@app.route('/add', methods=['POST'])
@login_required
def add():
    task = request.form.get('task')
    if task:
        todo_list.append({'task': task, 'done': False})
    return redirect(url_for('index'))

@app.route('/done/<int:index>')
@login_required
def mark_done(index):
    if 0 <= index < len(todo_list):
        todo_list[index]['done'] = True
    return redirect(url_for('index'))

@app.route('/delete/<int:index>')
@login_required
def delete(index):
    if 0 <= index < len(todo_list):
        todo_list.pop(index)
    return redirect(url_for('index'))

@app.route('/register', methods=['GET', 'POST'])
def register():
    message = ''
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        users = load_users()
        if username in users:
            message = '用户名已存在，请换一个。'
        else:
            users[username] = generate_password_hash(password)
            save_users(users)
            return redirect(url_for('login'))
    return render_template('register.html', message=message)

@app.route('/login', methods=['GET', 'POST'])
def login():
    message = ''
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        users = load_users()
        hash_pw = users.get(username)
        if hash_pw and check_password_hash(hash_pw, password):
            session['username'] = username
            return redirect(url_for('index'))
        else:
            message = '用户名或密码错误。'
    return render_template('login.html', message=message)

@app.route('/logout')
@login_required
def logout():
    session.pop('username', None)
    return redirect(url_for('login'))

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
