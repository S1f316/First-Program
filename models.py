from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from typing import Optional, List
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Integer, Text, Boolean, DateTime, ForeignKey

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'users'
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    username: Mapped[str] = mapped_column(String(80), unique=True, nullable=False)
    password: Mapped[str] = mapped_column(String(200), nullable=False)
    login_type: Mapped[str] = mapped_column(String(20), default='birth')
    birthdate: Mapped[Optional[str]] = mapped_column(String(10), nullable=True)
    created_by: Mapped[Optional[str]] = mapped_column(String(80), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    posts: Mapped[List["Post"]] = relationship("Post", back_populates="author", lazy="dynamic")
    todos: Mapped[List["Todo"]] = relationship("Todo", back_populates="user", lazy="dynamic")
    comments: Mapped[List["Comment"]] = relationship("Comment", back_populates="author", lazy="dynamic")
    likes: Mapped[List["Like"]] = relationship("Like", back_populates="user", lazy="dynamic")
    complaints: Mapped[List["Complaint"]] = relationship("Complaint", back_populates="user", lazy="dynamic")

class Post(db.Model):
    __tablename__ = 'posts'
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    author_id: Mapped[int] = mapped_column(Integer, ForeignKey('users.id'), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    author: Mapped["User"] = relationship("User", back_populates="posts")
    comments: Mapped[List["Comment"]] = relationship("Comment", back_populates="post", lazy="dynamic")
    likes: Mapped[List["Like"]] = relationship("Like", back_populates="post", lazy="dynamic")
    complaints: Mapped[List["Complaint"]] = relationship("Complaint", back_populates="post", lazy="dynamic")

class Comment(db.Model):
    __tablename__ = 'comments'
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    post_id: Mapped[int] = mapped_column(Integer, ForeignKey('posts.id'), nullable=False)
    author_id: Mapped[int] = mapped_column(Integer, ForeignKey('users.id'), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    post: Mapped["Post"] = relationship("Post", back_populates="comments")
    author: Mapped["User"] = relationship("User", back_populates="comments")

class Like(db.Model):
    __tablename__ = 'likes'
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    post_id: Mapped[int] = mapped_column(Integer, ForeignKey('posts.id'), nullable=False)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey('users.id'), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    post: Mapped["Post"] = relationship("Post", back_populates="likes")
    user: Mapped["User"] = relationship("User", back_populates="likes")

class Complaint(db.Model):
    __tablename__ = 'complaints'
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    post_id: Mapped[int] = mapped_column(Integer, ForeignKey('posts.id'), nullable=False)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey('users.id'), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    post: Mapped["Post"] = relationship("Post", back_populates="complaints")
    user: Mapped["User"] = relationship("User", back_populates="complaints")

class Todo(db.Model):
    __tablename__ = 'todos'
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    task: Mapped[str] = mapped_column(String(200), nullable=False)
    date: Mapped[Optional[str]] = mapped_column(String(10), nullable=True)
    time: Mapped[Optional[str]] = mapped_column(String(5), nullable=True)
    priority: Mapped[str] = mapped_column(String(10), default='medium')
    completed: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey('users.id'), nullable=False)
    user: Mapped["User"] = relationship("User", back_populates="todos") 