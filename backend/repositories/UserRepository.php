<?php

declare(strict_types=1);

namespace MindSpace\Repositories;

final class UserRepository extends BaseRepository
{
    /** @return array<string, mixed>|null */
    public function findByEmail(string $email): ?array
    {
        $statement = $this->pdo->prepare('SELECT * FROM users WHERE email = :email AND deleted_at IS NULL LIMIT 1');
        $statement->execute(['email' => $email]);
        $user = $statement->fetch();

        return is_array($user) ? $user : null;
    }

    /** @return array<string, mixed>|null */
    public function findByUsername(string $username): ?array
    {
        $statement = $this->pdo->prepare('SELECT * FROM users WHERE username = :username AND deleted_at IS NULL LIMIT 1');
        $statement->execute(['username' => $username]);
        $user = $statement->fetch();

        return is_array($user) ? $user : null;
    }

    /** @return array<string, mixed>|null */
    public function findById(int $id): ?array
    {
        $statement = $this->pdo->prepare(
            'SELECT users.*,
              profile_file.storage_path AS profile_photo_path,
              cover_file.storage_path AS cover_photo_path
             FROM users
             LEFT JOIN files AS profile_file ON profile_file.id = users.profile_photo_id
             LEFT JOIN files AS cover_file ON cover_file.id = users.cover_photo_id
             WHERE users.id = :id AND users.deleted_at IS NULL
             LIMIT 1'
        );
        $statement->execute(['id' => $id]);
        $user = $statement->fetch();

        return is_array($user) ? $user : null;
    }

    /** @param array<string, mixed> $data */
    public function create(array $data): int
    {
        $statement = $this->pdo->prepare(
            'INSERT INTO users (public_id, full_name, username, email, password_hash)
             VALUES (:public_id, :full_name, :username, :email, :password_hash)'
        );
        $statement->execute($data);

        return (int) $this->pdo->lastInsertId();
    }

    /** @param array<string, mixed> $data */
    public function updateProfile(int $id, array $data): void
    {
        $statement = $this->pdo->prepare(
            'UPDATE users SET full_name = :full_name, username = :username, phone_number = :phone_number,
             country = :country, biography = :biography WHERE id = :id'
        );
        $statement->execute([
            'id' => $id,
            'full_name' => $data['full_name'],
            'username' => $data['username'],
            'phone_number' => $data['phone_number'] ?? null,
            'country' => $data['country'] ?? null,
            'biography' => $data['biography'] ?? null,
        ]);
    }

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

    public function updateProfilePhoto(int $id, int $fileId): void
    {
        $statement = $this->pdo->prepare('UPDATE users SET profile_photo_id = :file_id WHERE id = :id');
        $statement->execute(['id' => $id, 'file_id' => $fileId]);
    }

    public function updateCoverPhoto(int $id, int $fileId): void
    {
        $statement = $this->pdo->prepare('UPDATE users SET cover_photo_id = :file_id WHERE id = :id');
        $statement->execute(['id' => $id, 'file_id' => $fileId]);
    }
}
