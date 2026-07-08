<?php

declare(strict_types=1);

namespace MindSpace\Core\Http;

final class Response
{
    public static function success(mixed $data = null, string $message = 'Başarılı', int $status = 200): void
    {
        self::json(['success' => true, 'message' => $message, 'data' => $data], $status);
    }

    public static function error(string $message, int $status = 400, mixed $errors = null): void
    {
        self::json(['success' => false, 'message' => $message, 'errors' => $errors], $status);
    }

    /** @param array<string, mixed> $payload */
    private static function json(array $payload, int $status): void
    {
        http_response_code($status);
        echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit;
    }
}
