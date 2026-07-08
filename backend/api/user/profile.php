<?php

require_once dirname(__DIR__, 2) . '/core/bootstrap.php';

$controller = new MindSpace\Controllers\ProfileController();

if (MindSpace\Core\Http\Request::method() === 'GET') {
    $controller->show();
}

$controller->update();
