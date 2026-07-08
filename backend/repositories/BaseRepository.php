<?php

declare(strict_types=1);

namespace MindSpace\Repositories;

use MindSpace\Core\Database\Connection;
use PDO;

abstract class BaseRepository
{
    protected PDO $pdo;

    public function __construct()
    {
        $this->pdo = Connection::pdo();
    }

    protected function page(): int
    {
        return max(1, (int) ($_GET['page'] ?? 1));
    }

    protected function limit(): int
    {
        return min(100, max(1, (int) ($_GET['limit'] ?? 20)));
    }

    protected function offset(): int
    {
        return ($this->page() - 1) * $this->limit();
    }
}
