<?php

declare(strict_types=1);

namespace MindSpace\Services;

use MindSpace\Core\Security\TokenManager;
use MindSpace\Core\Support\Config;
use MindSpace\Core\Support\Str;
use MindSpace\Core\Http\Response;
use MindSpace\Repositories\TokenRepository;
use MindSpace\Repositories\UserRepository;

final class AuthService
{
    public function __construct(
        private readonly UserRepository $users = new UserRepository(),
        private readonly TokenRepository $tokens = new TokenRepository(),
    ) {
    }

    /** @param array<string, mixed> $data */
    public function register(array $data): array
    {
        $email = mb_strtolower(trim((string) $data['email']));
        $username = trim((string) $data['username']);

        if ($this->users->findByEmail($email) !== null) {
            Response::error('Bu e-posta adresi zaten kullanılıyor.', 409);
        }

        if ($this->users->findByUsername($username) !== null) {
            Response::error('Bu kullanıcı adı zaten kullanılıyor.', 409);
        }

        $userId = $this->users->create([
            'public_id' => Str::uuid(),
            'full_name' => trim((string) $data['full_name']),
            'username' => $username,
            'email' => $email,
            'password_hash' => password_hash((string) $data['password'], PASSWORD_DEFAULT),
        ]);

        return $this->session($this->users->findById($userId));
    }

    /** @param array<string, mixed> $data */
    public function login(array $data): ?array
    {
        $user = $this->users->findByEmail(mb_strtolower(trim((string) $data['email'])));

        if ($user === null || !password_verify((string) $data['password'], (string) $user['password_hash'])) {
            return null;
        }

        return $this->session($user);
    }

    public function refresh(string $refreshToken): ?array
    {
        $token = $this->tokens->findValidRefreshToken(TokenManager::hash($refreshToken));

        if ($token === null) {
            return null;
        }

        $user = $this->users->findById((int) $token['user_id']);

        return $user === null ? null : $this->session($user);
    }

    public function logout(?string $refreshToken, ?int $userId): void
    {
        if ($refreshToken !== null) {
            $this->tokens->revoke(TokenManager::hash($refreshToken));
            return;
        }

        if ($userId !== null) {
            $this->tokens->revokeAllForUser($userId);
        }
    }

    /** @param array<string, mixed>|null $user */
    private function session(?array $user): array
    {
        if ($user === null) {
            return [];
        }

        $accessToken = TokenManager::createAccessToken([
            'sub' => (int) $user['id'],
            'public_id' => (string) $user['public_id'],
            'email' => (string) $user['email'],
        ]);
        $refreshToken = TokenManager::createRefreshToken();
        $expiresAt = gmdate('Y-m-d H:i:s', time() + ((int) Config::get('app', 'refresh_token_ttl_days', 30) * 86400));

        $this->tokens->storeRefreshToken((int) $user['id'], TokenManager::hash($refreshToken), $expiresAt);

        return [
            'user' => $this->publicUser($user),
            'access_token' => $accessToken,
            'refresh_token' => $refreshToken,
        ];
    }

    /** @param array<string, mixed> $user */
    private function publicUser(array $user): array
    {
        return [
            'id' => (string) $user['public_id'],
            'full_name' => $user['full_name'],
            'username' => $user['username'],
            'email' => $user['email'],
            'phone_number' => $user['phone_number'],
            'country' => $user['country'],
            'biography' => $user['biography'],
            'join_date' => $user['created_at'],
        ];
    }
}
