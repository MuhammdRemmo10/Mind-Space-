<?php

declare(strict_types=1);

namespace MindSpace\Repositories;

final class TokenRepository extends BaseRepository
{
    public function storeRefreshToken(int $userId, string $tokenHash, string $expiresAt): void
    {
        $statement = $this->pdo->prepare(
            'INSERT INTO auth_refresh_tokens (user_id, token_hash, expires_at) VALUES (:user_id, :token_hash, :expires_at)'
        );
        $statement->execute([
            'user_id' => $userId,
            'token_hash' => $tokenHash,
            'expires_at' => $expiresAt,
        ]);
    }

    /** @return array<string, mixed>|null */
    public function findValidRefreshToken(string $tokenHash): ?array
    {
        $statement = $this->pdo->prepare(
            'SELECT * FROM auth_refresh_tokens
             WHERE token_hash = :token_hash AND revoked_at IS NULL AND expires_at > UTC_TIMESTAMP()
             LIMIT 1'
        );
        $statement->execute(['token_hash' => $tokenHash]);
        $token = $statement->fetch();

        return is_array($token) ? $token : null;
    }

    public function revoke(string $tokenHash): void
    {
        $statement = $this->pdo->prepare('UPDATE auth_refresh_tokens SET revoked_at = UTC_TIMESTAMP() WHERE token_hash = :token_hash');
        $statement->execute(['token_hash' => $tokenHash]);
    }

    public function revokeAllForUser(int $userId): void
    {
        $statement = $this->pdo->prepare('UPDATE auth_refresh_tokens SET revoked_at = UTC_TIMESTAMP() WHERE user_id = :user_id');
        $statement->execute(['user_id' => $userId]);
    }
}
