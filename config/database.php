<?php
require_once __DIR__ . '/app.php';

function db(): PDO {
    static $pdo = null;
    if ($pdo instanceof PDO) return $pdo;

    $host = env('DB_HOST', '127.0.0.1');
    $port = env('DB_PORT', '3306');
    $name = env('DB_NAME', 'fitcore_pro');
    $user = env('DB_USER', 'root');
    $pass = env('DB_PASS', '');
    $charset = 'utf8mb4';

    $dsn = "mysql:host={$host};port={$port};dbname={$name};charset={$charset}";
    try {
        $pdo = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        $safeMessage = htmlspecialchars($e->getMessage(), ENT_QUOTES, 'UTF-8');
        echo '<!doctype html><html><head><meta charset="utf-8"><title>Database setup</title><style>body{font-family:system-ui;background:#0b0d10;color:#fff;padding:40px}.box{max-width:760px;margin:auto;background:#15181d;padding:28px;border-radius:20px;border:1px solid #2a2f37}code{color:#b8ff58}</style></head><body><div class="box"><h2>FitCore Pro database is not connected</h2><p>Import <code>database/fitcore.sql</code>, then copy <code>.env.example</code> to <code>.env</code> and update the database values.</p><p><small>' . $safeMessage . '</small></p></div></body></html>';
        exit;
    }
    return $pdo;
}
