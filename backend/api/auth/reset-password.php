<?php

require_once dirname(__DIR__, 2) . '/core/bootstrap.php';

(new MindSpace\Controllers\AuthController())->accepted('Password reset endpoint is ready.');
