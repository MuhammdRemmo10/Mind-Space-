<?php

declare(strict_types=1);

date_default_timezone_set('UTC');

spl_autoload_register(static function (string $class): void {
    $prefix = 'MindSpace\\';
    $baseDir = dirname(__DIR__) . '/';

    if (strncmp($prefix, $class, strlen($prefix)) !== 0) {
        return;
    }

    $relativeClass = substr($class, strlen($prefix));
    $file = $baseDir . str_replace('\\', '/', $relativeClass) . '.php';

    if (is_file($file)) {
        require_once $file;
    }
});

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Authorization, Content-Type, Accept');
header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
header('Content-Type: application/json; charset=utf-8');

set_exception_handler(static function (Throwable $exception): void {
    $config = is_file(dirname(__DIR__) . '/config/app.php')
        ? require dirname(__DIR__) . '/config/app.php'
        : ['debug' => false];

    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Sunucu hatası.',
        'errors' => ($config['debug'] ?? false) ? $exception->getMessage() : null,
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
});

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}
