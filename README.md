# Web Beta 项目

这是一个基于 Flask 的 Web 应用程序，包含用户管理、待办事项、论坛等功能。

## 功能特点

- 用户管理（管理员和普通用户）
- 待办事项管理
- 论坛功能（发帖、评论、点赞、投诉）
- 群主评选系统

## 技术栈

- Python 3.8+
- Flask
- PostgreSQL
- SQLAlchemy
- Gunicorn

## 本地开发

1. 创建虚拟环境：
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate  # Windows
```

2. 安装依赖：
```bash
pip install -r requirements.txt
```

3. 设置环境变量：
创建 `.env` 文件并添加以下内容：
```
DATABASE_URL=your_database_url
SECRET_KEY=your_secret_key
```

4. 运行应用：
```bash
python app.py
```

## 部署到 Render

1. 在 Render 上创建一个新的 Web Service
2. 连接你的 GitHub 仓库
3. 设置以下配置：
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `gunicorn wsgi:app`
4. 添加环境变量：
   - `DATABASE_URL`：PostgreSQL 数据库 URL
   - `SECRET_KEY`：用于会话加密的密钥

## 初始管理员账户

- 用户名：S1f
- 密码：yifan0316

## 注意事项

- 首次运行时会自动创建数据库表和管理员账户
- 确保 PostgreSQL 数据库已创建并可访问
- 部署时注意设置正确的环境变量
