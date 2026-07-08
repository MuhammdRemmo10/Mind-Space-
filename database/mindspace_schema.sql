CREATE DATABASE IF NOT EXISTS mind_space
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE mind_space;

SET NAMES utf8mb4;
SET time_zone = '+00:00';
SET foreign_key_checks = 1;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  username VARCHAR(60) NOT NULL,
  email VARCHAR(190) NOT NULL,
  phone_number VARCHAR(30) NULL,
  country VARCHAR(80) NULL,
  biography TEXT NULL,
  profile_photo_id BIGINT UNSIGNED NULL,
  cover_photo_id BIGINT UNSIGNED NULL,
  password_hash VARCHAR(255) NOT NULL,
  email_verified_at DATETIME NULL,
  phone_verified_at DATETIME NULL,
  remember_token VARCHAR(255) NULL,
  status ENUM('active', 'blocked', 'disabled', 'deleted') NOT NULL DEFAULT 'active',
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_public_id (public_id),
  UNIQUE KEY uq_users_username (username),
  UNIQUE KEY uq_users_email (email),
  KEY idx_users_profile_photo_id (profile_photo_id),
  KEY idx_users_cover_photo_id (cover_photo_id),
  KEY idx_users_status (status),
  KEY idx_users_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS auth_refresh_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  token_hash VARCHAR(255) NOT NULL,
  device_name VARCHAR(120) NULL,
  device_type ENUM('android', 'ios', 'web', 'desktop', 'unknown') NOT NULL DEFAULT 'unknown',
  ip_address VARCHAR(45) NULL,
  user_agent TEXT NULL,
  expires_at DATETIME NOT NULL,
  revoked_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_auth_refresh_tokens_hash (token_hash),
  KEY idx_auth_refresh_tokens_user_id (user_id),
  KEY idx_auth_refresh_tokens_expires_at (expires_at),
  CONSTRAINT fk_refresh_tokens_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS email_verifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  email VARCHAR(190) NOT NULL,
  verification_code VARCHAR(20) NOT NULL,
  expires_at DATETIME NOT NULL,
  verified_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_email_verifications_user_id (user_id),
  KEY idx_email_verifications_email (email),
  KEY idx_email_verifications_code (verification_code),
  CONSTRAINT fk_email_verifications_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS password_resets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  email VARCHAR(190) NOT NULL,
  token_hash VARCHAR(255) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_password_resets_token_hash (token_hash),
  KEY idx_password_resets_user_id (user_id),
  KEY idx_password_resets_email (email),
  CONSTRAINT fk_password_resets_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_settings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  language_code VARCHAR(10) NOT NULL DEFAULT 'en',
  theme_mode ENUM('system', 'light', 'dark') NOT NULL DEFAULT 'system',
  push_notifications_enabled TINYINT(1) NOT NULL DEFAULT 1,
  local_notifications_enabled TINYINT(1) NOT NULL DEFAULT 1,
  reminder_notifications_enabled TINYINT(1) NOT NULL DEFAULT 1,
  daily_writing_reminder_enabled TINYINT(1) NOT NULL DEFAULT 0,
  daily_writing_reminder_time TIME NULL,
  backup_enabled TINYINT(1) NOT NULL DEFAULT 1,
  auto_sync_enabled TINYINT(1) NOT NULL DEFAULT 1,
  privacy_level ENUM('private', 'friends', 'public') NOT NULL DEFAULT 'private',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_settings_user_id (user_id),
  CONSTRAINT fk_user_settings_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_security_settings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  app_lock_enabled TINYINT(1) NOT NULL DEFAULT 0,
  pin_hash VARCHAR(255) NULL,
  biometric_enabled TINYINT(1) NOT NULL DEFAULT 0,
  fingerprint_enabled TINYINT(1) NOT NULL DEFAULT 0,
  face_id_enabled TINYINT(1) NOT NULL DEFAULT 0,
  lock_after_seconds INT UNSIGNED NOT NULL DEFAULT 300,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_security_settings_user_id (user_id),
  CONSTRAINT fk_user_security_settings_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS files (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  original_name VARCHAR(255) NOT NULL,
  stored_name VARCHAR(255) NOT NULL,
  mime_type VARCHAR(120) NOT NULL,
  extension VARCHAR(20) NULL,
  file_type ENUM('image', 'pdf', 'word', 'excel', 'powerpoint', 'audio', 'video', 'document', 'other') NOT NULL DEFAULT 'other',
  file_size BIGINT UNSIGNED NOT NULL DEFAULT 0,
  storage_disk ENUM('local', 'cloud') NOT NULL DEFAULT 'local',
  storage_path VARCHAR(500) NOT NULL,
  external_url VARCHAR(1000) NULL,
  checksum VARCHAR(128) NULL,
  width INT UNSIGNED NULL,
  height INT UNSIGNED NULL,
  duration_seconds INT UNSIGNED NULL,
  is_favorite TINYINT(1) NOT NULL DEFAULT 0,
  status ENUM('active', 'archived', 'trashed') NOT NULL DEFAULT 'active',
  sync_version BIGINT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_files_public_id (public_id),
  KEY idx_files_user_id (user_id),
  KEY idx_files_type (file_type),
  KEY idx_files_status (status),
  CONSTRAINT fk_files_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE users
  ADD CONSTRAINT fk_users_profile_photo
    FOREIGN KEY (profile_photo_id) REFERENCES files (id)
    ON DELETE SET NULL,
  ADD CONSTRAINT fk_users_cover_photo
    FOREIGN KEY (cover_photo_id) REFERENCES files (id)
    ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS spaces (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  description TEXT NULL,
  icon VARCHAR(80) NOT NULL DEFAULT 'space_dashboard',
  color_hex CHAR(7) NOT NULL DEFAULT '#2E8B74',
  cover_file_id BIGINT UNSIGNED NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_favorite TINYINT(1) NOT NULL DEFAULT 0,
  is_pinned TINYINT(1) NOT NULL DEFAULT 0,
  status ENUM('active', 'archived', 'trashed') NOT NULL DEFAULT 'active',
  sync_version BIGINT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  archived_at DATETIME NULL,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_spaces_public_id (public_id),
  KEY idx_spaces_user_id (user_id),
  KEY idx_spaces_status (status),
  KEY idx_spaces_pinned (is_pinned),
  KEY idx_spaces_favorite (is_favorite),
  CONSTRAINT fk_spaces_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_spaces_cover_file
    FOREIGN KEY (cover_file_id) REFERENCES files (id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tags (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(80) NOT NULL,
  slug VARCHAR(100) NOT NULL,
  color_hex CHAR(7) NOT NULL DEFAULT '#59636E',
  usage_count INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_tags_public_id (public_id),
  UNIQUE KEY uq_tags_user_slug (user_id, slug),
  KEY idx_tags_user_id (user_id),
  CONSTRAINT fk_tags_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  space_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NULL,
  rich_text LONGTEXT NULL,
  plain_text LONGTEXT NULL,
  background_color_hex CHAR(7) NULL,
  visibility ENUM('private', 'friends', 'public') NOT NULL DEFAULT 'private',
  is_checklist TINYINT(1) NOT NULL DEFAULT 0,
  is_favorite TINYINT(1) NOT NULL DEFAULT 0,
  is_pinned TINYINT(1) NOT NULL DEFAULT 0,
  status ENUM('active', 'archived', 'trashed') NOT NULL DEFAULT 'active',
  published_at DATETIME NULL,
  word_count INT UNSIGNED NOT NULL DEFAULT 0,
  reading_time_minutes INT UNSIGNED NOT NULL DEFAULT 0,
  sync_version BIGINT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  archived_at DATETIME NULL,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_notes_public_id (public_id),
  KEY idx_notes_user_id (user_id),
  KEY idx_notes_space_id (space_id),
  KEY idx_notes_visibility (visibility),
  KEY idx_notes_status (status),
  KEY idx_notes_favorite (is_favorite),
  KEY idx_notes_created_at (created_at),
  FULLTEXT KEY ft_notes_search (title, description, plain_text),
  CONSTRAINT fk_notes_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_notes_space
    FOREIGN KEY (space_id) REFERENCES spaces (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS note_versions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  note_id BIGINT UNSIGNED NOT NULL,
  version_number INT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  rich_text LONGTEXT NULL,
  plain_text LONGTEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_note_versions_note_version (note_id, version_number),
  CONSTRAINT fk_note_versions_note
    FOREIGN KEY (note_id) REFERENCES notes (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS note_tags (
  note_id BIGINT UNSIGNED NOT NULL,
  tag_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (note_id, tag_id),
  KEY idx_note_tags_tag_id (tag_id),
  CONSTRAINT fk_note_tags_note
    FOREIGN KEY (note_id) REFERENCES notes (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_note_tags_tag
    FOREIGN KEY (tag_id) REFERENCES tags (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS note_files (
  note_id BIGINT UNSIGNED NOT NULL,
  file_id BIGINT UNSIGNED NOT NULL,
  attachment_role ENUM('image', 'audio_note', 'pdf', 'document', 'video', 'attachment') NOT NULL DEFAULT 'attachment',
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (note_id, file_id),
  KEY idx_note_files_file_id (file_id),
  CONSTRAINT fk_note_files_note
    FOREIGN KEY (note_id) REFERENCES notes (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_note_files_file
    FOREIGN KEY (file_id) REFERENCES files (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS note_links (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  note_id BIGINT UNSIGNED NOT NULL,
  url VARCHAR(1000) NOT NULL,
  title VARCHAR(255) NULL,
  description TEXT NULL,
  image_url VARCHAR(1000) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_note_links_note_id (note_id),
  CONSTRAINT fk_note_links_note
    FOREIGN KEY (note_id) REFERENCES notes (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS checklist_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  note_id BIGINT UNSIGNED NOT NULL,
  parent_item_id BIGINT UNSIGNED NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NULL,
  is_completed TINYINT(1) NOT NULL DEFAULT 0,
  sort_order INT NOT NULL DEFAULT 0,
  completed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_checklist_items_public_id (public_id),
  KEY idx_checklist_items_note_id (note_id),
  KEY idx_checklist_items_parent (parent_item_id),
  CONSTRAINT fk_checklist_items_note
    FOREIGN KEY (note_id) REFERENCES notes (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_checklist_items_parent
    FOREIGN KEY (parent_item_id) REFERENCES checklist_items (id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS articles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  space_id BIGINT UNSIGNED NOT NULL,
  cover_file_id BIGINT UNSIGNED NULL,
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  excerpt TEXT NULL,
  rich_text LONGTEXT NULL,
  plain_text LONGTEXT NULL,
  visibility ENUM('private', 'friends', 'public') NOT NULL DEFAULT 'private',
  is_favorite TINYINT(1) NOT NULL DEFAULT 0,
  status ENUM('draft', 'active', 'archived', 'trashed') NOT NULL DEFAULT 'draft',
  reading_time_minutes INT UNSIGNED NOT NULL DEFAULT 0,
  word_count INT UNSIGNED NOT NULL DEFAULT 0,
  published_at DATETIME NULL,
  sync_version BIGINT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  archived_at DATETIME NULL,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_articles_public_id (public_id),
  UNIQUE KEY uq_articles_user_slug (user_id, slug),
  KEY idx_articles_user_id (user_id),
  KEY idx_articles_space_id (space_id),
  KEY idx_articles_visibility (visibility),
  KEY idx_articles_favorite (is_favorite),
  KEY idx_articles_status (status),
  FULLTEXT KEY ft_articles_search (title, excerpt, plain_text),
  CONSTRAINT fk_articles_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_articles_space
    FOREIGN KEY (space_id) REFERENCES spaces (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_articles_cover_file
    FOREIGN KEY (cover_file_id) REFERENCES files (id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS article_tags (
  article_id BIGINT UNSIGNED NOT NULL,
  tag_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (article_id, tag_id),
  KEY idx_article_tags_tag_id (tag_id),
  CONSTRAINT fk_article_tags_article
    FOREIGN KEY (article_id) REFERENCES articles (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_article_tags_tag
    FOREIGN KEY (tag_id) REFERENCES tags (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS article_files (
  article_id BIGINT UNSIGNED NOT NULL,
  file_id BIGINT UNSIGNED NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (article_id, file_id),
  KEY idx_article_files_file_id (file_id),
  CONSTRAINT fk_article_files_article
    FOREIGN KEY (article_id) REFERENCES articles (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_article_files_file
    FOREIGN KEY (file_id) REFERENCES files (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS task_lists (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  description TEXT NULL,
  icon VARCHAR(80) NOT NULL DEFAULT 'check_circle',
  color_hex CHAR(7) NOT NULL DEFAULT '#4F46E5',
  sort_order INT NOT NULL DEFAULT 0,
  is_pinned TINYINT(1) NOT NULL DEFAULT 0,
  status ENUM('active', 'archived', 'trashed') NOT NULL DEFAULT 'active',
  sync_version BIGINT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  archived_at DATETIME NULL,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_task_lists_public_id (public_id),
  KEY idx_task_lists_user_id (user_id),
  KEY idx_task_lists_status (status),
  KEY idx_task_lists_pinned (is_pinned),
  CONSTRAINT fk_task_lists_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tasks (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  task_list_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NULL,
  priority ENUM('low', 'medium', 'high', 'urgent') NOT NULL DEFAULT 'medium',
  deadline_at DATETIME NULL,
  reminder_at DATETIME NULL,
  repeat_rule VARCHAR(255) NULL,
  is_completed TINYINT(1) NOT NULL DEFAULT 0,
  completed_at DATETIME NULL,
  is_favorite TINYINT(1) NOT NULL DEFAULT 0,
  status ENUM('active', 'archived', 'trashed') NOT NULL DEFAULT 'active',
  sync_version BIGINT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  archived_at DATETIME NULL,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_tasks_public_id (public_id),
  KEY idx_tasks_user_id (user_id),
  KEY idx_tasks_task_list_id (task_list_id),
  KEY idx_tasks_deadline (deadline_at),
  KEY idx_tasks_reminder (reminder_at),
  KEY idx_tasks_completed (is_completed),
  KEY idx_tasks_status (status),
  FULLTEXT KEY ft_tasks_search (title, description),
  CONSTRAINT fk_tasks_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_tasks_task_list
    FOREIGN KEY (task_list_id) REFERENCES task_lists (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS task_tags (
  task_id BIGINT UNSIGNED NOT NULL,
  tag_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (task_id, tag_id),
  KEY idx_task_tags_tag_id (tag_id),
  CONSTRAINT fk_task_tags_task
    FOREIGN KEY (task_id) REFERENCES tasks (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_task_tags_tag
    FOREIGN KEY (tag_id) REFERENCES tags (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS public_follows (
  follower_id BIGINT UNSIGNED NOT NULL,
  followed_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (follower_id, followed_id),
  KEY idx_public_follows_followed_id (followed_id),
  CONSTRAINT fk_public_follows_follower
    FOREIGN KEY (follower_id) REFERENCES users (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_public_follows_followed
    FOREIGN KEY (followed_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS entity_likes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  entity_type ENUM('note', 'article') NOT NULL,
  entity_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_entity_likes_user_entity (user_id, entity_type, entity_id),
  KEY idx_entity_likes_entity (entity_type, entity_id),
  CONSTRAINT fk_entity_likes_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS entity_saves (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  entity_type ENUM('note', 'article') NOT NULL,
  entity_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_entity_saves_user_entity (user_id, entity_type, entity_id),
  KEY idx_entity_saves_entity (entity_type, entity_id),
  CONSTRAINT fk_entity_saves_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS entity_shares (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  entity_type ENUM('note', 'article') NOT NULL,
  entity_id BIGINT UNSIGNED NOT NULL,
  share_channel VARCHAR(80) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_entity_shares_user_id (user_id),
  KEY idx_entity_shares_entity (entity_type, entity_id),
  CONSTRAINT fk_entity_shares_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS comments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  entity_type ENUM('note', 'article') NOT NULL,
  entity_id BIGINT UNSIGNED NOT NULL,
  parent_comment_id BIGINT UNSIGNED NULL,
  body TEXT NOT NULL,
  status ENUM('active', 'hidden', 'deleted') NOT NULL DEFAULT 'active',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_comments_public_id (public_id),
  KEY idx_comments_user_id (user_id),
  KEY idx_comments_entity (entity_type, entity_id),
  KEY idx_comments_parent (parent_comment_id),
  CONSTRAINT fk_comments_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_comments_parent
    FOREIGN KEY (parent_comment_id) REFERENCES comments (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  type VARCHAR(80) NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT NULL,
  data JSON NULL,
  channel ENUM('push', 'local', 'reminder', 'daily_writing') NOT NULL DEFAULT 'push',
  read_at DATETIME NULL,
  scheduled_at DATETIME NULL,
  sent_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_notifications_public_id (public_id),
  KEY idx_notifications_user_id (user_id),
  KEY idx_notifications_channel (channel),
  KEY idx_notifications_read_at (read_at),
  KEY idx_notifications_scheduled_at (scheduled_at),
  CONSTRAINT fk_notifications_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS reminders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  entity_type ENUM('note', 'task', 'article') NOT NULL,
  entity_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  reminder_at DATETIME NOT NULL,
  repeat_rule VARCHAR(255) NULL,
  is_sent TINYINT(1) NOT NULL DEFAULT 0,
  sent_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_reminders_public_id (public_id),
  KEY idx_reminders_user_id (user_id),
  KEY idx_reminders_entity (entity_type, entity_id),
  KEY idx_reminders_reminder_at (reminder_at),
  CONSTRAINT fk_reminders_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS favorites (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  entity_type ENUM('space', 'note', 'article', 'task', 'file', 'tag') NOT NULL,
  entity_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_favorites_user_entity (user_id, entity_type, entity_id),
  KEY idx_favorites_entity (entity_type, entity_id),
  CONSTRAINT fk_favorites_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trash_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  entity_type ENUM('space', 'note', 'article', 'task', 'file', 'tag', 'comment') NOT NULL,
  entity_id BIGINT UNSIGNED NOT NULL,
  deleted_by BIGINT UNSIGNED NULL,
  deleted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  restore_until DATETIME NULL,
  metadata JSON NULL,
  PRIMARY KEY (id),
  KEY idx_trash_items_user_id (user_id),
  KEY idx_trash_items_entity (entity_type, entity_id),
  KEY idx_trash_items_deleted_at (deleted_at),
  CONSTRAINT fk_trash_items_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_trash_items_deleted_by
    FOREIGN KEY (deleted_by) REFERENCES users (id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS calendar_events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  entity_type ENUM('note', 'task', 'article') NOT NULL,
  entity_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  starts_at DATETIME NOT NULL,
  ends_at DATETIME NULL,
  all_day TINYINT(1) NOT NULL DEFAULT 0,
  color_hex CHAR(7) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_calendar_events_public_id (public_id),
  KEY idx_calendar_events_user_date (user_id, starts_at),
  KEY idx_calendar_events_entity (entity_type, entity_id),
  CONSTRAINT fk_calendar_events_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS daily_statistics (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  statistic_date DATE NOT NULL,
  notes_created INT UNSIGNED NOT NULL DEFAULT 0,
  articles_created INT UNSIGNED NOT NULL DEFAULT 0,
  tasks_created INT UNSIGNED NOT NULL DEFAULT 0,
  tasks_completed INT UNSIGNED NOT NULL DEFAULT 0,
  words_written INT UNSIGNED NOT NULL DEFAULT 0,
  files_uploaded INT UNSIGNED NOT NULL DEFAULT 0,
  active_space_id BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_daily_statistics_user_date (user_id, statistic_date),
  KEY idx_daily_statistics_active_space (active_space_id),
  CONSTRAINT fk_daily_statistics_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_daily_statistics_space
    FOREIGN KEY (active_space_id) REFERENCES spaces (id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sync_changes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  device_id VARCHAR(120) NULL,
  entity_type ENUM('user', 'space', 'note', 'article', 'task', 'tag', 'file', 'comment', 'settings') NOT NULL,
  entity_id BIGINT UNSIGNED NOT NULL,
  operation ENUM('create', 'update', 'delete', 'restore') NOT NULL,
  payload JSON NULL,
  sync_version BIGINT UNSIGNED NOT NULL DEFAULT 1,
  synced_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sync_changes_public_id (public_id),
  KEY idx_sync_changes_user_id (user_id),
  KEY idx_sync_changes_entity (entity_type, entity_id),
  KEY idx_sync_changes_created_at (created_at),
  CONSTRAINT fk_sync_changes_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS backups (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  file_id BIGINT UNSIGNED NULL,
  backup_type ENUM('manual', 'automatic', 'restore_point') NOT NULL DEFAULT 'manual',
  status ENUM('pending', 'running', 'completed', 'failed') NOT NULL DEFAULT 'pending',
  started_at DATETIME NULL,
  completed_at DATETIME NULL,
  error_message TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_backups_public_id (public_id),
  KEY idx_backups_user_id (user_id),
  KEY idx_backups_status (status),
  CONSTRAINT fk_backups_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_backups_file
    FOREIGN KEY (file_id) REFERENCES files (id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ai_requests (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id CHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  entity_type ENUM('note', 'article', 'task', 'none') NOT NULL DEFAULT 'none',
  entity_id BIGINT UNSIGNED NULL,
  action ENUM('summarize', 'rewrite', 'grammar_correction', 'translate', 'generate_title', 'extract_keywords', 'note_to_tasks', 'generate_ideas') NOT NULL,
  input_text LONGTEXT NULL,
  output_text LONGTEXT NULL,
  language_code VARCHAR(10) NULL,
  status ENUM('pending', 'completed', 'failed') NOT NULL DEFAULT 'pending',
  error_message TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_ai_requests_public_id (public_id),
  KEY idx_ai_requests_user_id (user_id),
  KEY idx_ai_requests_entity (entity_type, entity_id),
  KEY idx_ai_requests_action (action),
  CONSTRAINT fk_ai_requests_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE VIEW dashboard_summary_view AS
SELECT
  u.id AS user_id,
  COALESCE(space_counts.total_spaces, 0) AS total_spaces,
  COALESCE(note_counts.total_notes, 0) AS total_notes,
  COALESCE(task_counts.total_tasks, 0) AS total_tasks,
  COALESCE(article_counts.total_articles, 0) AS total_articles,
  COALESCE(file_counts.total_files, 0) AS total_files,
  COALESCE(statistics_counts.total_words_written, 0) AS total_words_written
FROM users u
LEFT JOIN (
  SELECT user_id, COUNT(*) AS total_spaces
  FROM spaces
  WHERE status = 'active'
  GROUP BY user_id
) AS space_counts ON space_counts.user_id = u.id
LEFT JOIN (
  SELECT user_id, COUNT(*) AS total_notes
  FROM notes
  WHERE status = 'active'
  GROUP BY user_id
) AS note_counts ON note_counts.user_id = u.id
LEFT JOIN (
  SELECT user_id, COUNT(*) AS total_tasks
  FROM tasks
  WHERE status = 'active'
  GROUP BY user_id
) AS task_counts ON task_counts.user_id = u.id
LEFT JOIN (
  SELECT user_id, COUNT(*) AS total_articles
  FROM articles
  WHERE status IN ('draft', 'active')
  GROUP BY user_id
) AS article_counts ON article_counts.user_id = u.id
LEFT JOIN (
  SELECT user_id, COUNT(*) AS total_files
  FROM files
  WHERE status = 'active'
  GROUP BY user_id
) AS file_counts ON file_counts.user_id = u.id
LEFT JOIN (
  SELECT user_id, SUM(words_written) AS total_words_written
  FROM daily_statistics
  GROUP BY user_id
) AS statistics_counts ON statistics_counts.user_id = u.id
WHERE u.deleted_at IS NULL;
