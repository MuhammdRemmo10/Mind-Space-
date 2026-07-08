<?php

declare(strict_types=1);

namespace MindSpace\Repositories;

use MindSpace\Core\Support\Str;

final class ContentRepository extends BaseRepository
{
    private const TABLES = [
        'notes' => 'notes',
        'tasks' => 'tasks',
        'articles' => 'articles',
        'tags' => 'tags',
    ];

    /** @return list<array<string, mixed>> */
    public function list(string $resource, int $userId): array
    {
        $table = self::TABLES[$resource] ?? null;

        if ($table === null) {
            return [];
        }

        $filterSql = '';
        $filterName = '';
        $resolvedFilterId = null;
        $status = isset($_GET['status']) ? (string) $_GET['status'] : null;
        $favoritesOnly = (string) ($_GET['favorite'] ?? $_GET['favorites'] ?? '') === '1';
        $statusClause = match (true) {
            $table === 'tags' => 'deleted_at IS NULL',
            $favoritesOnly => 'status != "trashed"',
            default => 'status = "active"',
        };

        if ($resource === 'tasks') {
            $taskListId = $_GET['task_list_id'] ?? $_GET['space_id'] ?? null;

            if ($taskListId !== null && $taskListId !== '') {
                $resolvedFilterId = $this->resolveTaskListId($userId, (string) $taskListId);
                $filterSql = $resolvedFilterId === null ? ' AND 1 = 0' : ' AND task_list_id = :filter_id';
                $filterName = 'filter_id';
            }
        } else {
            $spaceId = $_GET['space_id'] ?? null;

            if ($spaceId !== null && $spaceId !== '') {
                $resolvedFilterId = $this->resolveSpaceId($userId, (string) $spaceId);
                $filterSql = $resolvedFilterId === null ? ' AND 1 = 0' : ' AND space_id = :filter_id';
                $filterName = 'filter_id';
            }
        }

        $selectSql = $resource === 'articles'
            ? 'SELECT articles.*, cover_file.storage_path AS cover_image_path
               FROM articles
               LEFT JOIN files AS cover_file ON cover_file.id = articles.cover_file_id'
            : "SELECT * FROM {$table}";
        $userColumn = $resource === 'articles' ? 'articles.user_id' : 'user_id';
        $statusColumn = $resource === 'articles' ? 'articles.status' : 'status';
        $spaceColumn = $resource === 'articles' ? 'articles.space_id' : 'space_id';
        $orderColumn = $resource === 'articles' ? 'articles.updated_at' : 'updated_at';
        $favoriteColumn = $resource === 'articles' ? 'articles.is_favorite' : 'is_favorite';
        $statusClause = $resource === 'articles'
            ? ($favoritesOnly ? "{$statusColumn} != \"trashed\"" : "{$statusColumn} IN (\"active\", \"draft\")")
            : $statusClause;
        if ($status !== null && $status !== '') {
            $statusClause = "{$statusColumn} = :status";
        }
        if ($favoritesOnly && $table !== 'tags') {
            $filterSql .= " AND {$favoriteColumn} = 1";
        }
        $filterSql = $resource === 'articles' && $filterSql !== ''
            ? str_replace('space_id', $spaceColumn, $filterSql)
            : $filterSql;

        $statement = $this->pdo->prepare(
            "{$selectSql} WHERE {$userColumn} = :user_id AND {$statusClause}{$filterSql}
             ORDER BY {$orderColumn} DESC LIMIT :limit OFFSET :offset"
        );
        $statement->bindValue('user_id', $userId, \PDO::PARAM_INT);
        if ($resolvedFilterId !== null && $filterName !== '') {
            $statement->bindValue($filterName, $resolvedFilterId, \PDO::PARAM_INT);
        }
        if ($status !== null && $status !== '') {
            $statement->bindValue('status', $status);
        }
        $statement->bindValue('limit', $this->limit(), \PDO::PARAM_INT);
        $statement->bindValue('offset', $this->offset(), \PDO::PARAM_INT);
        $statement->execute();

        return $statement->fetchAll();
    }

    /** @param array<string, mixed> $data */
    public function createNote(int $userId, array $data): array
    {
        $spaceId = $this->resolveSpaceId($userId, (string) $data['space_id']);

        if ($spaceId === null) {
            return [];
        }

        $statement = $this->pdo->prepare(
            'INSERT INTO notes (public_id, user_id, space_id, title, description, rich_text, plain_text, visibility)
             VALUES (:public_id, :user_id, :space_id, :title, :description, :rich_text, :plain_text, :visibility)'
        );
        $statement->execute([
            'public_id' => Str::uuid(),
            'user_id' => $userId,
            'space_id' => $spaceId,
            'title' => $data['title'],
            'description' => $data['description'] ?? null,
            'rich_text' => $data['rich_text'] ?? null,
            'plain_text' => $data['plain_text'] ?? null,
            'visibility' => $data['visibility'] ?? 'private',
        ]);

        return $this->findById('notes', (int) $this->pdo->lastInsertId(), $userId);
    }

    /** @param array<string, mixed> $data */
    public function createTask(int $userId, array $data): array
    {
        $taskListId = $this->resolveTaskListId($userId, (string) ($data['task_list_id'] ?? $data['space_id'] ?? ''));

        if ($taskListId === null) {
            return [];
        }

        $statement = $this->pdo->prepare(
            'INSERT INTO tasks (public_id, user_id, task_list_id, title, description, priority, deadline_at, reminder_at, repeat_rule)
             VALUES (:public_id, :user_id, :task_list_id, :title, :description, :priority, :deadline_at, :reminder_at, :repeat_rule)'
        );
        $statement->execute([
            'public_id' => Str::uuid(),
            'user_id' => $userId,
            'task_list_id' => $taskListId,
            'title' => $data['title'],
            'description' => $data['description'] ?? null,
            'priority' => $data['priority'] ?? 'medium',
            'deadline_at' => $data['deadline_at'] ?? null,
            'reminder_at' => $data['reminder_at'] ?? null,
            'repeat_rule' => $data['repeat_rule'] ?? null,
        ]);

        return $this->findById('tasks', (int) $this->pdo->lastInsertId(), $userId);
    }

    /** @param array<string, mixed> $data */
    public function createArticle(int $userId, array $data): array
    {
        $spaceId = $this->resolveSpaceId($userId, (string) $data['space_id']);

        if ($spaceId === null) {
            return [];
        }

        $title = (string) $data['title'];
        $plainText = trim((string) ($data['plain_text'] ?? strip_tags((string) ($data['rich_text'] ?? ''))));
        $wordCount = $this->wordCount($plainText);
        $publishNow = !empty($data['publish_now']);
        $statement = $this->pdo->prepare(
            'INSERT INTO articles
             (public_id, user_id, space_id, cover_file_id, title, slug, excerpt, rich_text, plain_text, visibility, status, reading_time_minutes, word_count, published_at)
             VALUES
             (:public_id, :user_id, :space_id, :cover_file_id, :title, :slug, :excerpt, :rich_text, :plain_text, :visibility, :status, :reading_time_minutes, :word_count, :published_at)'
        );
        $statement->execute([
            'public_id' => Str::uuid(),
            'user_id' => $userId,
            'space_id' => $spaceId,
            'cover_file_id' => $data['cover_file_id'] ?? null,
            'title' => $title,
            'slug' => Str::slug($title) . '-' . substr(Str::uuid(), 0, 8),
            'excerpt' => $data['excerpt'] ?? null,
            'rich_text' => $data['rich_text'] ?? null,
            'plain_text' => $plainText,
            'visibility' => $data['visibility'] ?? 'private',
            'status' => $publishNow ? 'active' : 'draft',
            'reading_time_minutes' => max(1, (int) ceil($wordCount / 220)),
            'word_count' => $wordCount,
            'published_at' => $publishNow ? gmdate('Y-m-d H:i:s') : null,
        ]);

        return $this->findById('articles', (int) $this->pdo->lastInsertId(), $userId);
    }

    /** @param array<string, mixed> $file */
    public function createFileRecord(int $userId, array $file): int
    {
        $statement = $this->pdo->prepare(
            'INSERT INTO files (public_id, user_id, original_name, stored_name, mime_type, extension, file_type, file_size, storage_path)
             VALUES (:public_id, :user_id, :original_name, :stored_name, :mime_type, :extension, :file_type, :file_size, :storage_path)'
        );
        $statement->execute($file + [
            'user_id' => $userId,
            'file_type' => 'image',
        ]);

        return (int) $this->pdo->lastInsertId();
    }

    /** @param array<string, mixed> $data */
    public function createTag(int $userId, array $data): array
    {
        $name = (string) $data['name'];
        $statement = $this->pdo->prepare(
            'INSERT INTO tags (public_id, user_id, name, slug, color_hex)
             VALUES (:public_id, :user_id, :name, :slug, :color_hex)'
        );
        $statement->execute([
            'public_id' => Str::uuid(),
            'user_id' => $userId,
            'name' => $name,
            'slug' => Str::slug($name),
            'color_hex' => $data['color_hex'] ?? '#59636E',
        ]);

        return $this->findById('tags', (int) $this->pdo->lastInsertId(), $userId);
    }

    public function trash(string $resource, int $userId, string $publicId): void
    {
        $table = self::TABLES[$resource] ?? null;

        if ($table === null || $table === 'tags') {
            return;
        }

        $statement = $this->pdo->prepare(
            "UPDATE {$table} SET status = 'trashed', deleted_at = UTC_TIMESTAMP(), sync_version = sync_version + 1
             WHERE public_id = :public_id AND user_id = :user_id"
        );
        $statement->execute(['public_id' => $publicId, 'user_id' => $userId]);
    }

    public function archive(string $resource, int $userId, string $publicId): array
    {
        $table = self::TABLES[$resource] ?? null;

        if ($table === null || $table === 'tags') {
            return [];
        }

        $statement = $this->pdo->prepare(
            "UPDATE {$table}
             SET status = 'archived', archived_at = UTC_TIMESTAMP(), deleted_at = NULL, sync_version = sync_version + 1
             WHERE public_id = :public_id AND user_id = :user_id"
        );
        $statement->execute(['public_id' => $publicId, 'user_id' => $userId]);

        return $this->findByPublicId($table, $publicId, $userId);
    }

    public function restore(string $resource, int $userId, string $publicId): array
    {
        $table = self::TABLES[$resource] ?? null;

        if ($table === null || $table === 'tags') {
            return [];
        }

        $statement = $this->pdo->prepare(
            "UPDATE {$table}
             SET status = 'active', archived_at = NULL, deleted_at = NULL, sync_version = sync_version + 1
             WHERE public_id = :public_id AND user_id = :user_id"
        );
        $statement->execute(['public_id' => $publicId, 'user_id' => $userId]);

        return $this->findByPublicId($table, $publicId, $userId);
    }

    public function setFavorite(string $resource, int $userId, string $publicId, bool $isFavorite): array
    {
        $table = self::TABLES[$resource] ?? null;

        if ($table === null || $table === 'tags') {
            return [];
        }

        $statement = $this->pdo->prepare(
            "UPDATE {$table}
             SET is_favorite = :is_favorite, sync_version = sync_version + 1
             WHERE public_id = :public_id AND user_id = :user_id"
        );
        $statement->execute([
            'public_id' => $publicId,
            'user_id' => $userId,
            'is_favorite' => $isFavorite ? 1 : 0,
        ]);

        return $this->findByPublicId($table, $publicId, $userId);
    }

    public function setTaskCompleted(int $userId, string $publicId, bool $isCompleted): array
    {
        $statement = $this->pdo->prepare(
            'UPDATE tasks
             SET is_completed = :is_completed, completed_at = :completed_at, sync_version = sync_version + 1
             WHERE public_id = :public_id AND user_id = :user_id'
        );
        $statement->execute([
            'public_id' => $publicId,
            'user_id' => $userId,
            'is_completed' => $isCompleted ? 1 : 0,
            'completed_at' => $isCompleted ? gmdate('Y-m-d H:i:s') : null,
        ]);

        $task = $this->findByPublicId('tasks', $publicId, $userId);
        $task['completion_percentage'] = ((int) ($task['is_completed'] ?? 0)) === 1 ? 100 : 0;

        return $task;
    }

    public function publishArticle(int $userId, string $publicId, ?string $visibility = null): array
    {
        $visibilitySql = $visibility === null ? '' : ', visibility = :visibility';
        $statement = $this->pdo->prepare(
            "UPDATE articles
             SET status = 'active', published_at = COALESCE(published_at, UTC_TIMESTAMP()), sync_version = sync_version + 1{$visibilitySql}
             WHERE public_id = :public_id AND user_id = :user_id"
        );
        $params = ['public_id' => $publicId, 'user_id' => $userId];
        if ($visibility !== null) {
            $params['visibility'] = $visibility;
        }
        $statement->execute($params);

        return $this->findByPublicId('articles', $publicId, $userId);
    }

    /** @return array<string, mixed> */
    private function findById(string $table, int $id, int $userId): array
    {
        if ($table === 'articles') {
            $statement = $this->pdo->prepare(
                'SELECT articles.*, cover_file.storage_path AS cover_image_path
                 FROM articles
                 LEFT JOIN files AS cover_file ON cover_file.id = articles.cover_file_id
                 WHERE articles.id = :id AND articles.user_id = :user_id LIMIT 1'
            );
            $statement->execute(['id' => $id, 'user_id' => $userId]);

            return $statement->fetch() ?: [];
        }

        $statement = $this->pdo->prepare("SELECT * FROM {$table} WHERE id = :id AND user_id = :user_id LIMIT 1");
        $statement->execute(['id' => $id, 'user_id' => $userId]);

        return $statement->fetch() ?: [];
    }

    /** @return array<string, mixed> */
    private function findByPublicId(string $table, string $publicId, int $userId): array
    {
        if ($table === 'articles') {
            $statement = $this->pdo->prepare(
                'SELECT articles.*, cover_file.storage_path AS cover_image_path
                 FROM articles
                 LEFT JOIN files AS cover_file ON cover_file.id = articles.cover_file_id
                 WHERE articles.public_id = :public_id AND articles.user_id = :user_id LIMIT 1'
            );
            $statement->execute(['public_id' => $publicId, 'user_id' => $userId]);

            return $statement->fetch() ?: [];
        }

        $statement = $this->pdo->prepare("SELECT * FROM {$table} WHERE public_id = :public_id AND user_id = :user_id LIMIT 1");
        $statement->execute(['public_id' => $publicId, 'user_id' => $userId]);

        return $statement->fetch() ?: [];
    }

    private function resolveSpaceId(int $userId, string $spaceId): ?int
    {
        if (ctype_digit($spaceId)) {
            $statement = $this->pdo->prepare('SELECT id FROM spaces WHERE id = :id AND user_id = :user_id LIMIT 1');
            $statement->execute(['id' => (int) $spaceId, 'user_id' => $userId]);
        } else {
            $statement = $this->pdo->prepare('SELECT id FROM spaces WHERE public_id = :id AND user_id = :user_id LIMIT 1');
            $statement->execute(['id' => $spaceId, 'user_id' => $userId]);
        }

        $space = $statement->fetch();

        return is_array($space) ? (int) $space['id'] : null;
    }

    private function resolveTaskListId(int $userId, string $taskListId): ?int
    {
        if ($taskListId === '') {
            return null;
        }

        if (ctype_digit($taskListId)) {
            $statement = $this->pdo->prepare('SELECT id FROM task_lists WHERE id = :id AND user_id = :user_id LIMIT 1');
            $statement->execute(['id' => (int) $taskListId, 'user_id' => $userId]);
        } else {
            $statement = $this->pdo->prepare('SELECT id FROM task_lists WHERE public_id = :id AND user_id = :user_id LIMIT 1');
            $statement->execute(['id' => $taskListId, 'user_id' => $userId]);
        }

        $taskList = $statement->fetch();

        return is_array($taskList) ? (int) $taskList['id'] : null;
    }

    private function wordCount(string $text): int
    {
        $text = trim(preg_replace('/\s+/u', ' ', $text) ?? '');
        if ($text === '') {
            return 0;
        }

        return count(preg_split('/\s+/u', $text) ?: []);
    }
}
