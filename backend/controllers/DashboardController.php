<?php

declare(strict_types=1);

namespace MindSpace\Controllers;

use MindSpace\Core\Http\Response;
use MindSpace\Core\Security\Auth;
use MindSpace\Repositories\DashboardRepository;

final class DashboardController
{
    public function __construct(private readonly DashboardRepository $dashboard = new DashboardRepository())
    {
    }

    public function index(): void
    {
        $user = Auth::user();
        Response::success($this->dashboard->summary($user['id']), 'Dashboard loaded successfully.');
    }
}
