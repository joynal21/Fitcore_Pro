<?php
require_once __DIR__ . '/../config/database.php';

function e(?string $value): string { return htmlspecialchars($value ?? '', ENT_QUOTES, 'UTF-8'); }
function format_date(?string $date, string $format='d M Y'): string { return $date ? date($format, strtotime($date)) : '—'; }
function initials(string $name): string { $p=preg_split('/\s+/', trim($name)); return strtoupper(substr($p[0]??'U',0,1).substr($p[1]??'',0,1)); }

function query_value(string $sql, array $params=[]): mixed {
    $s=db()->prepare($sql); $s->execute($params); return $s->fetchColumn();
}
function query_all(string $sql, array $params=[]): array {
    $s=db()->prepare($sql); $s->execute($params); return $s->fetchAll();
}
function query_one(string $sql, array $params=[]): array|false {
    $s=db()->prepare($sql); $s->execute($params); return $s->fetch();
}

function setting(string $key, mixed $default=null): mixed {
    static $settings = null;
    if ($settings === null) {
        $settings = [];
        try {
            foreach (query_all('SELECT setting_key,setting_value FROM system_settings') as $row) {
                $settings[$row['setting_key']] = $row['setting_value'];
            }
        } catch (Throwable $e) {
            $settings = [];
        }
    }
    return array_key_exists($key,$settings) ? $settings[$key] : $default;
}
function money(float|int|string|null $value): string {
    return (string)setting('currency_symbol','৳') . number_format((float)$value, 0);
}

function flash(string $type, string $message): void { $_SESSION['flash'][] = ['type'=>$type,'message'=>$message]; }
function get_flashes(): array { $f=$_SESSION['flash']??[]; unset($_SESSION['flash']); return $f; }

function csrf_token(): string {
    if (empty($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(24));
    return $_SESSION['csrf'];
}
function verify_csrf(): void {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $token = $_POST['csrf'] ?? $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
        if (!hash_equals($_SESSION['csrf'] ?? '', $token)) { http_response_code(419); exit('Invalid CSRF token'); }
    }
}
function redirect(string $path): never { header('Location: ' . url($path)); exit; }

function status_badge(string $status): string {
    return match(strtolower($status)) {
        'active','paid','good','completed','available','healthy','attended' => 'success',
        'pending','due','maintenance','warning','at risk','frozen','waitlist','paused' => 'warning',
        'expired','inactive','failed','damaged','cancelled','high risk','refunded' => 'danger',
        default => 'secondary',
    };
}

function current_branch_id(): int {
    $user = $_SESSION['user'] ?? [];
    if (!empty($_GET['branch']) && in_array($user['role'] ?? '', ['super_admin'], true)) {
        $candidate=(int)$_GET['branch'];
        if ($candidate>0 && query_value('SELECT COUNT(*) FROM branches WHERE id=?',[$candidate])) {
            $_SESSION['branch_id']=$candidate;
        }
    }
    return (int)($_SESSION['branch_id'] ?? $user['branch_id'] ?? 1);
}

function branch_name(?int $id=null): string {
    $id = $id ?: current_branch_id();
    return (string)(query_value('SELECT name FROM branches WHERE id=?', [$id]) ?: 'Main Branch');
}

function audit_log(string $action, ?string $entityType=null, ?int $entityId=null, ?string $description=null): void {
    $uid=(int)($_SESSION['user']['id']??0) ?: null;
    $ip=$_SERVER['REMOTE_ADDR']??null;
    try {
        db()->prepare('INSERT INTO audit_logs(user_id,action,entity_type,entity_id,description,ip_address) VALUES(?,?,?,?,?,?)')
            ->execute([$uid,$action,$entityType,$entityId,$description,$ip]);
    } catch (Throwable $e) {}
}

function rule_int(string $key, int $default): int {
    $raw=setting($key,null);
    if ($raw === null || $raw === '' || !is_numeric($raw)) return $default;
    return max(0,(int)$raw);
}
