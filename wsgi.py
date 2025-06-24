from app import app, db, init_db

# 确保数据库表被创建
with app.app_context():
    init_db()

if __name__ == "__main__":
    app.run()
