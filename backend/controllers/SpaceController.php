<?php

declare(strict_types=1);

namespace MindSpace\Controllers;

use MindSpace\Core\Http\Request;
use MindSpace\Core\Http\Response;
use MindSpace\Core\Security\Auth;
use MindSpace\Core\Validation\Validator;
use MindSpace\Repositories\SpaceRepository;

final class SpaceController
{
    public function __construct(private readonly SpaceRepository $spaces = new SpaceRepository())
    {
    }

    public function index(): void
    {
        $user = Auth::user();

        if (Request::method() === 'POST') {
            $this->store($user['id']);
            return;
        }

        if (in_array(Request::method(), ['PUT', 'PATCH'], true)) {
            $this->update($user['id']);
            return;
        }

        if (Request::method() === 'DELETE') {
            $this->delete($user['id']);
            return;
        }

        Response::success($this->spaces->list($user['id']), 'Alanlar başarıyla yüklendi.');
    }

    private function store(int $userId): void
    {
        $data = Request::input();
        $errors = Validator::validate($data, ['name' => 'required|min:2']);

        if ($errors !== []) {
            Response::error('Doğrulama başarısız.', 422, $errors);
        }

        Response::success($this->spaces->create($userId, $data), 'Alan başarıyla oluşturuldu.', 201);
    }

    private function update(int $userId): void
    {
        $data = Request::input();
        $data['id'] = $data['id'] ?? Request::query('id');
        $errors = Validator::validate($data, [
            'id' => 'required',
            'name' => 'required|min:2',
        ]);

        if ($errors !== []) {
            Response::error('Doğrulama başarısız.', 422, $errors);
        }

        Response::success($this->spaces->update($userId, (string) $data['id'], $data), 'Alan başarıyla güncellendi.');
    }

    private function delete(int $userId): void
    {
        $data = Request::input();
        $id = (string) ($data['id'] ?? Request::query('id', ''));

        if ($id === '') {
            Response::error('Alan kimliği zorunludur.', 422);
        }

        $this->spaces->trash($userId, $id);
        Response::success(null, 'Alan çöp kutusuna taşındı.');
    }
}
