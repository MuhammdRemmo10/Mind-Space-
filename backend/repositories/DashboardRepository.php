<?php

declare(strict_types=1);

namespace MindSpace\Repositories;

final class DashboardRepository extends BaseRepository
{
    /** @return array<string, mixed> */
    public function summary(int $userId): array
    {
        $statement = $this->pdo->prepare('SELECT * FROM dashboard_summary_view WHERE user_id = :user_id LIMIT 1');
        $statement->execute(['user_id' => $userId]);
        $summary = $statement->fetch() ?: [];

        $recentNotes = $this->pdo->prepare(
            'SELECT public_id, title, updated_at FROM notes WHERE user_id = :user_id AND status = "active" ORDER BY updated_at DESC LIMIT 5'
        );
        $recentNotes->execute(['user_id' => $userId]);

        $recentTasks = $this->pdo->prepare(
            'SELECT public_id, title, deadline_at, is_completed FROM tasks WHERE user_id = :user_id AND status = "active" ORDER BY updated_at DESC LIMIT 5'
        );
        $recentTasks->execute(['user_id' => $userId]);

        return [
            'summary' => $summary,
            'recent_notes' => $recentNotes->fetchAll(),
            'recent_tasks' => $recentTasks->fetchAll(),
        ];
    }
}
