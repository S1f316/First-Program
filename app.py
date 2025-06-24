from flask import Flask, render_template, request, redirect, url_for, session
from werkzeug.security import generate_password_hash, check_password_hash
from functools import wraps
from datetime import datetime
import os
from dotenv import load_dotenv
from models import db, User, Post, Comment, Like, Complaint, Todo

# 加载环境变量
load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv('SECRET_KEY', 'your-secret-key')

# 配置数据库
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL')
if app.config['SQLALCHEMY_DATABASE_URI'] and app.config['SQLALCHEMY_DATABASE_URI'].startswith('postgres://'):
    app.config['SQLALCHEMY_DATABASE_URI'] = app.config['SQLALCHEMY_DATABASE_URI'].replace('postgres://', 'postgresql://', 1)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# 初始化数据库
db.init_app(app)

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'username' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

@app.route('/')
def index():
    if 'username' in session:
        username = session['username']
        user = User.query.filter_by(username=username).first()
        is_admin = user.login_type == 'admin'
        return render_template('dashboard.html', 
                            username=username,
                            is_admin=is_admin)
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    message = ''
    if request.method == 'POST':
        login_type = request.args.get('type', 'birth')
        username = request.form['username']
        password = request.form['password']
        
        user = User.query.filter_by(username=username).first()
        
        if login_type == 'admin':
            if user and user.login_type == 'admin':
                if check_password_hash(user.password, password):
                    session['username'] = username
                    return redirect(url_for('index'))
                else:
                    message = '用户名或密码错误。'
            else:
                message = '用户名或密码错误。'
        
        elif login_type == 'birth':
            birthdate = request.form['birthdate']
            if user and user.login_type == 'birth':
                if check_password_hash(user.password, password) and user.birthdate == birthdate:
                    session['username'] = username
                    return redirect(url_for('index'))
                else:
                    message = '用户名、密码或出生日期不正确。'
            else:
                message = '此用户名未被预设，请联系管理员。'
    
    return render_template('login.html', message=message)

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/todos')
@login_required
def todos():
    username = session['username']
    user = User.query.filter_by(username=username).first()
    todos = Todo.query.filter_by(user_id=user.id).order_by(
        Todo.completed,
        Todo.priority != 'urgent',
        Todo.priority != 'medium',
        Todo.created_at.desc()
    ).all()
    
    return render_template('todos.html', 
                        todos=todos,
                        username=username)

@app.route('/add-todo', methods=['POST'])
@login_required
def add_todo():
    username = session['username']
    user = User.query.filter_by(username=username).first()
    task = request.form.get('task')
    date = request.form.get('date', '')
    time = request.form.get('time', '')
    priority = request.form.get('priority', 'medium')
    
    if task:
        new_todo = Todo(
            task=task,
            date=date,
            time=time,
            priority=priority,
            user_id=user.id
        )
        db.session.add(new_todo)
        db.session.commit()
    
    return redirect(url_for('todos'))

@app.route('/toggle-todo/<int:todo_id>')
@login_required
def toggle_todo(todo_id):
    username = session['username']
    user = User.query.filter_by(username=username).first()
    todo = Todo.query.filter_by(id=todo_id, user_id=user.id).first()
    
    if todo:
        todo.completed = not todo.completed
        db.session.commit()
    
    return redirect(url_for('todos'))

@app.route('/delete-todo/<int:todo_id>')
@login_required
def delete_todo(todo_id):
    username = session['username']
    user = User.query.filter_by(username=username).first()
    todo = Todo.query.filter_by(id=todo_id, user_id=user.id).first()
    
    if todo:
        db.session.delete(todo)
        db.session.commit()
    
    return redirect(url_for('todos'))

@app.route('/user-management')
@login_required
def user_management():
    username = session['username']
    user = User.query.filter_by(username=username).first()
    
    if user.login_type != 'admin':
        return redirect(url_for('index'))
    
    users = User.query.filter_by(login_type='birth').all()
    return render_template('user_management.html', users=users)

@app.route('/create-user', methods=['POST'])
@login_required
def create_user():
    admin_username = session['username']
    admin = User.query.filter_by(username=admin_username).first()
    
    if admin.login_type != 'admin':
        return redirect(url_for('index'))
    
    username = request.form.get('username')
    password = request.form.get('password')
    birthdate = request.form.get('birthdate')
    
    if username and password and birthdate:
        if User.query.filter_by(username=username).first():
            users = User.query.filter_by(login_type='birth').all()
            return render_template('user_management.html', 
                                message='用户名已存在',
                                success=False,
                                users=users)
        
        new_user = User(
            username=username,
            password=generate_password_hash(password),
            birthdate=birthdate,
            login_type='birth',
            created_by=admin_username
        )
        db.session.add(new_user)
        db.session.commit()
        
        users = User.query.filter_by(login_type='birth').all()
        return render_template('user_management.html', 
                            message='用户创建成功',
                            success=True,
                            users=users)
    
    users = User.query.filter_by(login_type='birth').all()
    return render_template('user_management.html', 
                        message='请填写所有必填字段',
                        success=False,
                        users=users)

@app.route('/delete-user/<username>')
@login_required
def delete_user(username):
    admin_username = session['username']
    admin = User.query.filter_by(username=admin_username).first()
    
    if admin.login_type != 'admin':
        return redirect(url_for('index'))
    
    user = User.query.filter_by(username=username).first()
    if user and user.username != admin_username:
        # 删除用户的所有数据
        Todo.query.filter_by(user_id=user.id).delete()
        Like.query.filter_by(user_id=user.id).delete()
        Complaint.query.filter_by(user_id=user.id).delete()
        Comment.query.filter_by(author_id=user.id).delete()
        Post.query.filter_by(author_id=user.id).delete()
        db.session.delete(user)
        db.session.commit()
    
    return redirect(url_for('user_management'))

@app.route('/view-user-todos/<username>')
@login_required
def view_user_todos(username):
    admin_username = session['username']
    admin = User.query.filter_by(username=admin_username).first()
    
    if admin.login_type != 'admin':
        return redirect(url_for('index'))
    
    user = User.query.filter_by(username=username).first()
    if not user:
        return redirect(url_for('user_management'))
    
    todos = Todo.query.filter_by(user_id=user.id).order_by(
        Todo.completed,
        Todo.priority != 'urgent',
        Todo.priority != 'medium',
        Todo.created_at.desc()
    ).all()
    
    return render_template('user_todos.html', 
                        todos=todos,
                        target_username=username,
                        user_data={'username': username})

@app.route('/forum')
@login_required
def forum():
    username = session['username']
    user = User.query.filter_by(username=username).first()
    is_admin = user.login_type == 'admin'
    
    posts = Post.query.order_by(Post.created_at.desc()).all()
    
    # 处理每个帖子的数据
    for post in posts:
        post.like_count = post.likes.count()
        post.complaint_count = post.complaints.count()
        post.is_liked = post.likes.filter_by(user_id=user.id).first() is not None
        post.is_complained = post.complaints.filter_by(user_id=user.id).first() is not None
        post.author_name = post.author.username
    
    return render_template('forum.html', 
                        username=username,
                        is_admin=is_admin,
                        posts=posts)

@app.route('/create-post', methods=['POST'])
@login_required
def create_post():
    username = session['username']
    user = User.query.filter_by(username=username).first()
    content = request.form.get('content')
    
    if content:
        new_post = Post(
            content=content,
            author_id=user.id
        )
        db.session.add(new_post)
        db.session.commit()
    
    return redirect(url_for('forum'))

@app.route('/create-comment/<int:post_id>', methods=['POST'])
@login_required
def create_comment(post_id):
    username = session['username']
    user = User.query.filter_by(username=username).first()
    content = request.form.get('content')
    
    if content:
        new_comment = Comment(
            content=content,
            post_id=post_id,
            author_id=user.id
        )
        db.session.add(new_comment)
        db.session.commit()
    
    return redirect(url_for('forum'))

@app.route('/toggle-like/<int:post_id>')
@login_required
def toggle_like(post_id):
    username = session['username']
    user = User.query.filter_by(username=username).first()
    
    like = Like.query.filter_by(post_id=post_id, user_id=user.id).first()
    if like:
        db.session.delete(like)
    else:
        new_like = Like(post_id=post_id, user_id=user.id)
        db.session.add(new_like)
    
    db.session.commit()
    return redirect(url_for('forum'))

@app.route('/toggle-complaint/<int:post_id>')
@login_required
def toggle_complaint(post_id):
    username = session['username']
    user = User.query.filter_by(username=username).first()
    
    complaint = Complaint.query.filter_by(post_id=post_id, user_id=user.id).first()
    if complaint:
        db.session.delete(complaint)
    else:
        new_complaint = Complaint(post_id=post_id, user_id=user.id)
        db.session.add(new_complaint)
    
    db.session.commit()
    return redirect(url_for('forum'))

@app.route('/delete-post/<int:post_id>')
@login_required
def delete_post(post_id):
    username = session['username']
    user = User.query.filter_by(username=username).first()
    
    if user.login_type != 'admin':
        return redirect(url_for('forum'))
    
    post = Post.query.get(post_id)
    if post:
        # 删除相关的评论、点赞和投诉
        Comment.query.filter_by(post_id=post_id).delete()
        Like.query.filter_by(post_id=post_id).delete()
        Complaint.query.filter_by(post_id=post_id).delete()
        db.session.delete(post)
        db.session.commit()
    
    return redirect(url_for('forum'))

@app.route('/group-leader')
@login_required
def group_leader():
    username = session['username']
    users = User.query.all()
    
    # 计算每个用户的统计数据
    for user in users:
        # 获取用户的所有帖子
        posts = Post.query.filter_by(author_id=user.id).all()
        
        # 计算总点赞和投诉数
        total_likes = sum(post.likes.count() for post in posts)
        total_complaints = sum(post.complaints.count() for post in posts)
        
        # 添加到用户对象
        user.total_likes = total_likes
        user.total_complaints = total_complaints
        user.net_score = total_likes - total_complaints
    
    # 按净得分降序排序
    users.sort(key=lambda x: (-x.net_score, x.username))
    
    return render_template('group_leader.html', users=users)

# 创建数据库表
def init_db():
    with app.app_context():
        db.create_all()
        
        # 检查是否需要创建管理员账户
        admin = User.query.filter_by(username='S1f').first()
        if not admin:
            admin = User(
                username='S1f',
                password=generate_password_hash('yifan0316'),
                login_type='admin'
            )
            db.session.add(admin)
            db.session.commit()

if __name__ == '__main__':
    init_db()  # 初始化数据库
    app.run(debug=True)
