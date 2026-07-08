<?php

declare(strict_types=1);

namespace MindSpace\Controllers;

use MindSpace\Core\Http\Request;
use MindSpace\Core\Http\Response;
use MindSpace\Core\Security\Auth;
use MindSpace\Core\Support\Str;
use MindSpace\Core\Validation\Validator;
use MindSpace\Repositories\ContentRepository;

final class ContentController
{
    public function __construct(private readonly ContentRepository $content = new ContentRepository())
    {
    }

    public function notes(): void
    {
        $this->handle('notes', 'createNote', ['space_id' => 'required', 'title' => 'required|min:1']);
    }

    public function tasks(): void
    {
        $this->handle('tasks', 'createTask', ['task_list_id' => 'required', 'title' => 'required|min:1']);
    }

    public function articles(): void
    {
        $this->handle('articles', 'createArticle', ['space_id' => 'required', 'title' => 'required|min:1']);
    }

    public function tags(): void
    {
        $this->handle('tags', 'createTag', ['name' => 'required|min:1']);
    }

    /** @param array<string, string> $rules */
    private function handle(string $resource, string $createMethod, array $rules): void
    {
        $user = Auth::user();

        if (Request::method() === 'POST') {
            $data = Request::input();
            $errors = Validator::validate($data, $rules);

            if ($errors !== []) {
                Response::error('Doğrulama başarısız.', 422, $errors);
            }

            if ($resource === 'articles' && isset($_FILES['cover_image']) && is_uploaded_file($_FILES['cover_image']['tmp_name'])) {
                $data['cover_file_id'] = $this->storeUploadedImage($user['id'], $_FILES['cover_image'], 'article');
            }

            $created = $this->content->{$createMethod}($user['id'], $data);
            Response::success($this->decorate($resource, $created), $this->singularLabel($resource) . ' başarıyla oluşturuldu.', 201);
        }

        if (in_array(Request::method(), ['PUT', 'PATCH'], true)) {
            $data = Request::input();
            $id = (string) ($data['id'] ?? Request::query('id', ''));

            if ($id === '') {
                Response::error('Kayıt kimliği zorunludur.', 422);
            }

            $action = (string) ($data['action'] ?? '');
            if ($action !== '') {
                $item = $this->performAction($resource, $user['id'], $id, $action, $data);
                Response::success($this->decorate($resource, $item), 'İşlem başarıyla tamamlandı.');
            }

            if ($resource === 'tasks') {
                $task = $this->content->setTaskCompleted($user['id'], $id, (bool) ($data['is_completed'] ?? false));
                Response::success($task, 'Görev durumu güncellendi.');
            }

            if ($resource === 'articles') {
                $article = $this->content->publishArticle(
                    $user['id'],
                    $id,
                    isset($data['visibility']) ? (string) $data['visibility'] : null
                );
                Response::success($this->decorate($resource, $article), 'Makale başarıyla yayınlandı.');
            }

            Response::error('İşlem zorunludur.', 422);
        }

        if (Request::method() === 'DELETE') {
            $data = Request::input();
            $id = (string) ($data['id'] ?? Request::query('id', ''));

            if ($id === '') {
                Response::error('Kayıt kimliği zorunludur.', 422);
            }

            $this->content->trash($resource, $user['id'], $id);
            Response::success(null, $this->singularLabel($resource) . ' çöp kutusuna taşındı.');
        }

        Response::success(
            $this->decorateList($resource, $this->content->list($resource, $user['id'])),
            $this->pluralLabel($resource) . ' başarıyla yüklendi.'
        );
    }

    /** @param array<string, mixed> $data */
    private function performAction(string $resource, int $userId, string $id, string $action, array $data): array
    {
        return match ($action) {
            'favorite' => $this->content->setFavorite($resource, $userId, $id, (bool) ($data['is_favorite'] ?? true)),
            'archive' => $this->content->archive($resource, $userId, $id),
            'restore' => $this->content->restore($resource, $userId, $id),
            default => Response::error('Geçersiz işlem.', 422),
        };
    }

    private function singularLabel(string $resource): string
    {
        return match ($resource) {
            'notes' => 'Not',
            'tasks' => 'Görev',
            'articles' => 'Makale',
            'tags' => 'Etiket',
            default => 'Kayıt',
        };
    }

    private function pluralLabel(string $resource): string
    {
        return match ($resource) {
            'notes' => 'Notlar',
            'tasks' => 'Görevler',
            'articles' => 'Makaleler',
            'tags' => 'Etiketler',
            default => 'Kayıtlar',
        };
    }

    /** @param array<string, mixed> $file */
    private function storeUploadedImage(int $userId, array $file, string $role): int
    {
        $mimeType = mime_content_type($file['tmp_name']) ?: 'application/octet-stream';
        $allowed = ['image/jpeg', 'image/png', 'image/webp'];

        if (!in_array($mimeType, $allowed, true)) {
            Response::error('Yalnızca JPG, PNG veya WEBP görselleri yüklenebilir.', 422);
        }

        $extension = match ($mimeType) {
            'image/jpeg' => 'jpg',
            'image/png' => 'png',
            'image/webp' => 'webp',
            default => 'bin',
        };
        $storedName = $role . '_' . Str::uuid() . '.' . $extension;
        $relativePath = 'storage/uploads/articles/' . $storedName;
        $destination = dirname(__DIR__) . '/' . $relativePath;
        $directory = dirname($destination);

        if (!is_dir($directory)) {
            mkdir($directory, 0775, true);
        }

        if (!move_uploaded_file($file['tmp_name'], $destination)) {
            Response::error('Görsel yüklenemedi.', 500);
        }

        return $this->content->createFileRecord($userId, [
            'public_id' => Str::uuid(),
            'original_name' => $file['name'] ?? $storedName,
            'stored_name' => $storedName,
            'mime_type' => $mimeType,
            'extension' => $extension,
            'file_size' => (int) ($file['size'] ?? 0),
            'storage_path' => $relativePath,
        ]);
    }

    /** @param array<string, mixed> $item */
    private function decorate(string $resource, array $item): array
    {
        if ($resource !== 'articles' || $item === []) {
            return $item;
        }

        $item['cover_image_url'] = $this->assetUrl($item['cover_image_path'] ?? null);

        return $item;
    }

    /**
     * @param list<array<string, mixed>> $items
     * @return list<array<string, mixed>>
     */
    private function decorateList(string $resource, array $items): array
    {
        return array_map(fn (array $item): array => $this->decorate($resource, $item), $items);
    }

    private function assetUrl(mixed $path): ?string
    {
        if (!is_string($path) || $path === '') {
            return null;
        }

        $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
        $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
        $script = $_SERVER['SCRIPT_NAME'] ?? '';
        $basePath = explode('/api/', $script)[0] ?? '';

        return $scheme . '://' . $host . $basePath . '/' . ltrim($path, '/');
    }
}
