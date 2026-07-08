<?php

declare(strict_types=1);

namespace MindSpace\Controllers;

use MindSpace\Core\Http\Request;
use MindSpace\Core\Http\Response;
use MindSpace\Core\Security\Auth;
use MindSpace\Core\Validation\Validator;
use MindSpace\Services\AuthService;

final class AuthController
{
    public function __construct(private readonly AuthService $auth = new AuthService())
    {
    }

    public function register(): void
    {
        $data = Request::input();
        $errors = Validator::validate($data, [
            'full_name' => 'required|min:2',
            'username' => 'required|min:3',
            'email' => 'required|email',
            'password' => 'required|min:8',
        ]);

        if ($errors !== []) {
            Response::error('Doğrulama başarısız.', 422, $errors);
        }

        Response::success($this->auth->register($data), 'Kayıt başarıyla oluşturuldu.', 201);
    }

    public function login(): void
    {
        $data = Request::input();
        $errors = Validator::validate($data, [
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if ($errors !== []) {
            Response::error('Doğrulama başarısız.', 422, $errors);
        }

        $session = $this->auth->login($data);

        if ($session === null) {
            Response::error('E-posta veya şifre hatalı.', 401);
        }

        Response::success($session, 'Giriş başarılı.');
    }

    public function refresh(): void
    {
        $data = Request::input();
        $refreshToken = (string) ($data['refresh_token'] ?? '');
        $session = $this->auth->refresh($refreshToken);

        if ($session === null) {
            Response::error('Yenileme anahtarı geçersiz.', 401);
        }

        Response::success($session, 'Oturum başarıyla yenilendi.');
    }

    public function logout(): void
    {
        $data = Request::input();
        $user = Auth::user();
        $this->auth->logout($data['refresh_token'] ?? null, $user['id']);

        Response::success(null, 'Çıkış başarılı.');
    }

    public function accepted(string $message): void
    {
        Response::success(null, $message);
    }
}
