<?php

declare(strict_types=1);

namespace MindSpace\Repositories;

use MindSpace\Core\Support\Str;

final class TaskListRepository extends BaseRepository
{
    /** @return list<array<string, mixed>> */
    public function list(int $userId): array
    {
        $statement = $this->pdo->prepare(
            'SELECT task_lists.*,
              COALESCE(task_counts.total_tasks, 0) AS total_tasks,
              COALESCE(task_counts.completed_tasks, 0) AS completed_tasks
             FROM task_lists
             LEFT JOIN (
               SELECT task_list_id,
                 COUNT(*) AS total_tasks,
                 SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) AS completed_tasks
               FROM tasks
               WHERE status != "trashed" AND task_list_id IS NOT NULL
               GROUP BY task_list_id
             ) AS task_counts ON task_counts.task_list_id = task_lists.id
             WHERE task_lists.user_id = :user_id AND task_lists.status != "trashed"
             ORDER BY task_lists.is_pinned DESC, task_lists.updated_at DESC
             LIMIT :limit OFFSET :offset'
        );
        $statement->bindValue('user_id', $userId, \PDO::PARAM_INT);
        $statement->bindValue('limit', $this->limit(), \PDO::PARAM_INT);
        $statement->bindValue('offset', $this->offset(), \PDO::PARAM_INT);
        $statement->execute();

        return $statement->fetchAll();
    }

    /** @param array<string, mixed> $data */
    public function create(int $userId, array $data): array
    {
        $statement = $this->pdo->prepare(
            'INSERT INTO task_lists (public_id, user_id, name, description, icon, color_hex)
             VALUES (:public_id, :user_id, :name, :description, :icon, :color_hex)'
        );
        $statement->execute([
            'public_id' => Str::uuid(),
            'user_id' => $userId,
            'name' => $data['name'],
            'description' => $data['description'] ?? null,
            'icon' => $data['icon'] ?? 'check_circle',
            'color_hex' => $data['color_hex'] ?? '#4F46E5',
        ]);

        return $this->findById((int) $this->pdo->lastInsertId(), $userId);
    }

    /** @param array<string, mixed> $data */
    public function update(int $userId, string $publicId, array $data): array
    {
        $statement = $this->pdo->prepare(
            'UPDATE task_lists
             SET name = :name, description = :description, icon = :icon, color_hex = :color_hex,
                 is_pinned = :is_pinned, sync_version = sync_version + 1
             WHERE public_id = :public_id AND user_id = :user_id'
        );
        $statement->execute([
            'public_id' => $publicId,
            'user_id' => $userId,
            'name' => $data['name'],
            'description' => $data['description'] ?? null,
            'icon' => $data['icon'] ?? 'check_circle',
            'color_hex' => $data['color_hex'] ?? '#4F46E5',
            'is_pinned' => !empty($data['is_pinned']) ? 1 : 0,
        ]);

        return $this->findByPublicId($publicId, $userId);
    }

    public function trash(int $userId, string $publicId): void
    {
        $statement = $this->pdo->prepare(
            'UPDATE task_lists
             SET status = "trashed", deleted_at = UTC_TIMESTAMP(), sync_version = sync_version + 1
             WHERE public_id = :public_id AND user_id = :user_id'
        );
        $statement->execute(['public_id' => $publicId, 'user_id' => $userId]);
    }

    public function resolveId(int $userId, string $publicId): ?int
    {
        if (ctype_digit($publicId)) {
            $statement = $this->pdo->prepare('SELECT id FROM task_lists WHERE id = :id AND user_id = :user_id LIMIT 1');
            $statement->execute(['id' => (int) $publicId, 'user_id' => $userId]);
        } else {
            $statement = $this->pdo->prepare('SELECT id FROM task_lists WHERE public_id = :id AND user_id = :user_id LIMIT 1');
            $statement->execute(['id' => $publicId, 'user_id' => $userId]);
        }

        $taskList = $statement->fetch();

        return is_array($taskList) ? (int) $taskList['id'] : null;
    }

    /** @return array<string, mixed> */
    private function findById(int $id, int $userId): array
    {
        $statement = $this->pdo->prepare('SELECT * FROM task_lists WHERE id = :id AND user_id = :user_id LIMIT 1');
        $statement->execute(['id' => $id, 'user_id' => $userId]);

        return $statement->fetch() ?: [];
    }

    /** @return array<string, mixed> */
    private function findByPublicId(string $publicId, int $userId): array
    {
        $statement = $this->pdo->prepare('SELECT * FROM task_lists WHERE public_id = :public_id AND user_id = :user_id LIMIT 1');
        $statement->execute(['public_id' => $publicId, 'user_id' => $userId]);

        return $statement->fetch() ?: [];
    }
}
