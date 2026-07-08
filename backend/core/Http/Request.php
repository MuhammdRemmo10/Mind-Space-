<?php

declare(strict_types=1);

namespace MindSpace\Core\Http;

final class Request
{
    /** @return array<string, mixed> */
    public static function input(): array
    {
        $raw = file_get_contents('php://input') ?: '';
        $json = json_decode($raw, true);

        if (is_array($json)) {
            return array_merge($_POST, $json);
        }

        return $_POST;
    }

    public static function method(): string
    {
        return strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');
    }

    public static function bearerToken(): ?string
    {
        $header = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';

        if (preg_match('/Bearer\s+(.+)/', $header, $matches) === 1) {
            return trim($matches[1]);
        }

        return null;
    }

    public static function query(string $key, mixed $default = null): mixed
    {
        return $_GET[$key] ?? $default;
    }
}
