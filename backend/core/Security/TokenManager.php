<?php

declare(strict_types=1);

namespace MindSpace\Core\Security;

use MindSpace\Core\Support\Config;

final class TokenManager
{
    /** @param array<string, mixed> $payload */
    public static function createAccessToken(array $payload): string
    {
        $payload['exp'] = time() + ((int) Config::get('app', 'access_token_ttl_minutes', 60) * 60);
        $body = self::base64UrlEncode(json_encode($payload, JSON_THROW_ON_ERROR));
        $signature = hash_hmac('sha256', $body, self::secret());

        return "{$body}.{$signature}";
    }

    /** @return array<string, mixed>|null */
    public static function verifyAccessToken(?string $token): ?array
    {
        if ($token === null || !str_contains($token, '.')) {
            return null;
        }

        [$body, $signature] = explode('.', $token, 2);
        $expected = hash_hmac('sha256', $body, self::secret());

        if (!hash_equals($expected, $signature)) {
            return null;
        }

        $payload = json_decode(self::base64UrlDecode($body), true);

        if (!is_array($payload) || (int) ($payload['exp'] ?? 0) < time()) {
            return null;
        }

        return $payload;
    }

    public static function createRefreshToken(): string
    {
        return bin2hex(random_bytes(48));
    }

    public static function hash(string $token): string
    {
        return hash('sha256', $token);
    }

    private static function secret(): string
    {
        return (string) Config::get('app', 'jwt_secret');
    }

    private static function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }

    private static function base64UrlDecode(string $value): string
    {
        return base64_decode(strtr($value, '-_', '+/')) ?: '';
    }
}
