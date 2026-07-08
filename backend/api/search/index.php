<?php

require_once dirname(__DIR__, 2) . '/core/bootstrap.php';

MindSpace\Core\Security\Auth::user();
MindSpace\Core\Http\Response::success([], 'Search API is ready.');
