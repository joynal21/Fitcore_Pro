<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

const APP_NAME = 'FitCore Pro';
const APP_TAGLINE = 'Smart Gym & Fitness Business Platform';

function load_env_file(string $path): void {
    if (!is_file($path)) return;
    foreach (file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || str_starts_with($line, '#') || !str_contains($line, '=')) continue;
        [$key, $value] = array_map('trim', explode('=', $line, 2));
        $value = trim($value, "\"'");
        if (getenv($key) === false) putenv("{$key}={$value}");
    }
}
load_env_file(dirname(__DIR__) . '/.env');

function env(string $key, ?string $default = null): ?string {
    $value = getenv($key);
    return $value === false ? $default : $value;
}

function app_base_path(): string {
    static $base = null;
    if ($base !== null) return $base;
    $forced = env('APP_BASE_PATH');
    if ($forced !== null && $forced !== '') return $base = '/' . trim($forced, '/');
    $projectRoot = realpath(dirname(__DIR__)) ?: dirname(__DIR__);
    $docRoot = realpath($_SERVER['DOCUMENT_ROOT'] ?? '') ?: ($_SERVER['DOCUMENT_ROOT'] ?? '');
    if ($docRoot && str_starts_with(str_replace('\\','/',$projectRoot), str_replace('\\','/',$docRoot))) {
        $relative = trim(str_replace('\\','/', substr($projectRoot, strlen($docRoot))), '/');
        return $base = $relative ? '/' . $relative : '';
    }
    return $base = '';
}

function url(string $path = ''): string {
    return app_base_path() . ($path ? '/' . ltrim($path, '/') : '');
}
