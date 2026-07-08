USE mind_space;

SET NAMES utf8mb4;
SET foreign_key_checks = 0;

SET @has_profile_photo_id := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'users'
    AND COLUMN_NAME = 'profile_photo_id'
);
SET @sql := IF(
  @has_profile_photo_id = 0,
  'ALTER TABLE users ADD COLUMN profile_photo_id BIGINT UNSIGNED NULL AFTER biography',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @has_cover_photo_id := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'users'
    AND COLUMN_NAME = 'cover_photo_id'
);
SET @sql := IF(
  @has_cover_photo_id = 0,
  'ALTER TABLE users ADD COLUMN cover_photo_id BIGINT UNSIGNED NULL AFTER profile_photo_id',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @has_profile_photo_index := (
  SELECT COUNT(*) FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'users'
    AND INDEX_NAME = 'idx_users_profile_photo_id'
);
SET @sql := IF(
  @has_profile_photo_index = 0,
  'ALTER TABLE users ADD INDEX idx_users_profile_photo_id (profile_photo_id)',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @has_cover_photo_index := (
  SELECT COUNT(*) FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'users'
    AND INDEX_NAME = 'idx_users_cover_photo_id'
);
SET @sql := IF(
  @has_cover_photo_index = 0,
  'ALTER TABLE users ADD INDEX idx_users_cover_photo_id (cover_photo_id)',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

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

SET @has_space_id := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tasks'
    AND COLUMN_NAME = 'space_id'
);
SET @sql := IF(
  @has_space_id > 0,
  'ALTER TABLE tasks MODIFY space_id BIGINT UNSIGNED NULL',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @has_task_list_id := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tasks'
    AND COLUMN_NAME = 'task_list_id'
);
SET @sql := IF(
  @has_task_list_id = 0,
  IF(
    @has_space_id > 0,
    'ALTER TABLE tasks ADD COLUMN task_list_id BIGINT UNSIGNED NULL AFTER space_id',
    'ALTER TABLE tasks ADD COLUMN task_list_id BIGINT UNSIGNED NULL AFTER user_id'
  ),
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @has_task_list_index := (
  SELECT COUNT(*) FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'tasks'
    AND INDEX_NAME = 'idx_tasks_task_list_id'
);
SET @sql := IF(
  @has_task_list_index = 0,
  'ALTER TABLE tasks ADD INDEX idx_tasks_task_list_id (task_list_id)',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

INSERT INTO task_lists (public_id, user_id, name, description, icon, color_hex)
SELECT UUID(), users.id, 'Genel', 'Varsayılan görev listesi', 'check_circle', '#4F46E5'
FROM users
WHERE NOT EXISTS (
  SELECT 1 FROM task_lists WHERE task_lists.user_id = users.id
);

UPDATE tasks
JOIN task_lists ON task_lists.user_id = tasks.user_id
SET tasks.task_list_id = task_lists.id
WHERE tasks.task_list_id IS NULL
  AND task_lists.name = 'Genel';

SET foreign_key_checks = 1;
