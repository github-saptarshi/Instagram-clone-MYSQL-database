CREATE DATABASE social_media;
USE social_media;

CREATE TABLE users (
    user_id INTEGER AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE content_post (
    content_id INTEGER AUTO_INCREMENT PRIMARY KEY,
    content_url VARCHAR(255) NOT NULL,
    user_id INTEGER NOT NULL,
    created_date TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY(user_id) REFERENCES users(user_id)
);

CREATE TABLE comments (
    commnet_id INTEGER AUTO_INCREMENT PRIMARY KEY,
    comment_text VARCHAR(255) NOT NULL,
    content_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY(content_id) REFERENCES content_post(content_id),
    FOREIGN KEY(user_id) REFERENCES users(user_id)
);

CREATE TABLE likes (
    user_id INTEGER NOT NULL,
    content_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(content_id) REFERENCES content_post(content_id),
    PRIMARY KEY(user_id, content_id)
);

CREATE TABLE follows (
    follower_id INTEGER NOT NULL,
    followee_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY(follower_id) REFERENCES users(user_id),
    FOREIGN KEY(followee_id) REFERENCES users(user_id),
    PRIMARY KEY(follower_id, followee_id)
);

CREATE TABLE tags (
  tag_id INTEGER AUTO_INCREMENT PRIMARY KEY,
  tag_name VARCHAR(255) UNIQUE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE post_tags (
    content_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    FOREIGN KEY(content_id)  REFERENCES content_post(content_id),
    FOREIGN KEY(tag_id) REFERENCES tags(tag_id),
    PRIMARY KEY(content_id, tag_id)
);
