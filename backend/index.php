<?php

require_once __DIR__ . '/core/bootstrap.php';

MindSpace\Core\Http\Response::success([
    'name' => 'MindSpace API',
    'status' => 'online',
    'version' => '0.1.0',
], 'MindSpace API is running.');
