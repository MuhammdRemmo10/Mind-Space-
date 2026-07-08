<?php

declare(strict_types=1);

return [
    'app_name' => 'MindSpace',
    'env' => 'local',
    'debug' => true,
    'timezone' => 'UTC',
    'base_url' => 'http://192.168.0.102/MindSpace',
    'jwt_secret' => 'change_this_mindspace_secret_before_production',
    'access_token_ttl_minutes' => 60,
    'refresh_token_ttl_days' => 30,
    'upload_path' => dirname(__DIR__) . '/storage/uploads',
];
