<?php

declare(strict_types=1);

namespace MindSpace\Controllers;

use MindSpace\Core\Http\Response;
use MindSpace\Core\Security\Auth;

final class FileController
{
    public function index(): void
    {
        Auth::user();
        Response::success([], 'File API is ready. Upload handling will be connected to the storage service.');
    }
}
