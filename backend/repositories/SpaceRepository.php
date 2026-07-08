<?php

declare(strict_types=1);

namespace MindSpace\Repositories;

use MindSpace\Core\Support\Str;

final class SpaceRepository extends BaseRepository
{
    /** @return list<array<string, mixed>> */
    public function list(int $userId): array
    {
        $statement = $this->pdo->prepare(
            'SELECT * FROM spaces WHERE user_id = :user_id AND status != "trashed"
             ORDER BY is_pinned DESC, sort_order ASC, updated_at DESC LIMIT :limit OFFSET :offset'
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
            'INSERT INTO spaces (public_id, user_id, name, description, icon, color_hex)
             VALUES (:public_id, :user_id, :name, :description, :icon, :color_hex)'
        );
        $statement->execute([
            'public_id' => Str::uuid(),
            'user_id' => $userId,
            'name' => $data['name'],
            'description' => $data['description'] ?? null,
            'icon' => $data['icon'] ?? 'space_dashboard',
            'color_hex' => $data['color_hex'] ?? '#2E8B74',
        ]);

        return $this->findOwned((int) $this->pdo->lastInsertId(), $userId);
    }

    /** @param array<string, mixed> $data */
    public function update(int $userId, string $publicId, array $data): array
    {
        $statement = $this->pdo->prepare(
            'UPDATE spaces
             SET name = :name, description = :description, icon = :icon, color_hex = :color_hex, sync_version = sync_version + 1
             WHERE public_id = :public_id AND user_id = :user_id'
        );
        $statement->execute([
            'public_id' => $publicId,
            'user_id' => $userId,
            'name' => $data['name'],
            'description' => $data['description'] ?? null,
            'icon' => $data['icon'] ?? 'space_dashboard',
            'color_hex' => $data['color_hex'] ?? '#4A4DD8',
        ]);

        return $this->findOwnedByPublicId($publicId, $userId);
    }

    public function trash(int $userId, string $publicId): void
    {
        $statement = $this->pdo->prepare(
            'UPDATE spaces SET status = "trashed", deleted_at = UTC_TIMESTAMP(), sync_version = sync_version + 1
             WHERE public_id = :public_id AND user_id = :user_id'
        );
        $statement->execute(['public_id' => $publicId, 'user_id' => $userId]);
    }

    /** @return array<string, mixed> */
    public function findOwned(int $id, int $userId): array
    {
        $statement = $this->pdo->prepare('SELECT * FROM spaces WHERE id = :id AND user_id = :user_id LIMIT 1');
        $statement->execute(['id' => $id, 'user_id' => $userId]);

        return $statement->fetch() ?: [];
    }

    /** @return array<string, mixed> */
    public function findOwnedByPublicId(string $publicId, int $userId): array
    {
        $statement = $this->pdo->prepare('SELECT * FROM spaces WHERE public_id = :public_id AND user_id = :user_id LIMIT 1');
        $statement->execute(['public_id' => $publicId, 'user_id' => $userId]);

        return $statement->fetch() ?: [];
    }
}
