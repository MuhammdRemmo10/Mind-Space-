<?php

declare(strict_types=1);

namespace MindSpace\Core\Validation;

final class Validator
{
    /**
     * @param array<string, mixed> $data
     * @param array<string, string> $rules
     * @return array<string, list<string>>
     */
    public static function validate(array $data, array $rules): array
    {
        $errors = [];

        foreach ($rules as $field => $ruleLine) {
            $value = $data[$field] ?? null;
            $fieldRules = explode('|', $ruleLine);

            foreach ($fieldRules as $rule) {
                if ($rule === 'required' && ($value === null || $value === '')) {
                    $errors[$field][] = "{$field} is required.";
                }

                if ($rule === 'email' && $value !== null && !filter_var($value, FILTER_VALIDATE_EMAIL)) {
                    $errors[$field][] = "{$field} must be a valid email address.";
                }

                if (str_starts_with($rule, 'min:') && is_string($value)) {
                    $min = (int) substr($rule, 4);
                    if (mb_strlen($value) < $min) {
                        $errors[$field][] = "{$field} must be at least {$min} characters.";
                    }
                }
            }
        }

        return $errors;
    }
}
