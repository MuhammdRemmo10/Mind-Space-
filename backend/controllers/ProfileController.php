<?php

declare(strict_types=1);

namespace MindSpace\Controllers;

use MindSpace\Core\Http\Request;
use MindSpace\Core\Http\Response;
use MindSpace\Core\Security\Auth;
use MindSpace\Core\Support\Str;
use MindSpace\Core\Validation\Validator;
use MindSpace\Repositories\UserRepository;

final class ProfileController
{
    public function __construct(private readonly UserRepository $users = new UserRepository())
    {
    }

    public function show(): void
    {
        $authUser = Auth::user();
        $user = $this->users->findById($authUser['id']);

        Response::success($this->publicUser($user), 'Profil başarıyla yüklendi.');
    }

    public function update(): void
    {
        $authUser = Auth::user();
        $data = Request::input();
        $errors = Validator::validate($data, [
            'full_name' => 'required|min:2',
            'username' => 'required|min:3',
        ]);

        if ($errors !== []) {
            Response::error('Doğrulama başarısız.', 422, $errors);
        }

        $this->users->updateProfile($authUser['id'], $data);

        if (isset($_FILES['profile_photo']) && is_uploaded_file($_FILES['profile_photo']['tmp_name'])) {
            $fileId = $this->storeUploadedImage($authUser['id'], $_FILES['profile_photo'], 'profile');
            $this->users->updateProfilePhoto($authUser['id'], $fileId);
        }

        if (isset($_FILES['cover_photo']) && is_uploaded_file($_FILES['cover_photo']['tmp_name'])) {
            $fileId = $this->storeUploadedImage($authUser['id'], $_FILES['cover_photo'], 'cover');
            $this->users->updateCoverPhoto($authUser['id'], $fileId);
        }

        Response::success($this->publicUser($this->users->findById($authUser['id'])), 'Profil başarıyla güncellendi.');
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
        $relativePath = 'storage/uploads/profile/' . $storedName;
        $destination = dirname(__DIR__) . '/' . $relativePath;
        $directory = dirname($destination);

        if (!is_dir($directory)) {
            mkdir($directory, 0775, true);
        }

        if (!move_uploaded_file($file['tmp_name'], $destination)) {
            Response::error('Görsel yüklenemedi.', 500);
        }

        return $this->users->createFileRecord($userId, [
            'public_id' => Str::uuid(),
            'original_name' => $file['name'] ?? $storedName,
            'stored_name' => $storedName,
            'mime_type' => $mimeType,
            'extension' => $extension,
            'file_size' => (int) ($file['size'] ?? 0),
            'storage_path' => $relativePath,
        ]);
    }

    /** @param array<string, mixed>|null $user */
    private function publicUser(?array $user): array
    {
        if ($user === null) {
            return [];
        }

        return [
            'id' => (string) $user['public_id'],
            'full_name' => $user['full_name'],
            'username' => $user['username'],
            'email' => $user['email'],
            'phone_number' => $user['phone_number'],
            'country' => $user['country'],
            'biography' => $user['biography'],
            'profile_photo_url' => $this->assetUrl($user['profile_photo_path'] ?? null),
            'cover_photo_url' => $this->assetUrl($user['cover_photo_path'] ?? null),
            'join_date' => $user['created_at'],
        ];
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
