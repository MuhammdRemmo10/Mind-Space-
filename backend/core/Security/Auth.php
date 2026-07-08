<?php

declare(strict_types=1);

namespace MindSpace\Core\Security;

use MindSpace\Core\Http\Request;
use MindSpace\Core\Http\Response;

final class Auth
{
    /** @return array{id:int, public_id:string, email:string} */
    public static function user(): array
    {
        $payload = TokenManager::verifyAccessToken(Request::bearerToken());

        if ($payload === null) {
            Response::error('Oturum doğrulanamadı.', 401);
        }

        return [
            'id' => (int) $payload['sub'],
            'public_id' => (string) ($payload['public_id'] ?? ''),
            'email' => (string) ($payload['email'] ?? ''),
        ];
    }
}
