<?php
require_once __DIR__ . '/functions.php';

function is_logged_in(): bool { return !empty($_SESSION['user']); }
function user(): array { return $_SESSION['user'] ?? []; }
function require_login(): void { if (!is_logged_in()) redirect('auth/login.php'); }
function require_role(array $roles): void {
    require_login();
    if (!in_array(user()['role'] ?? '', $roles, true)) { http_response_code(403); exit('403 — You do not have permission to access this page.'); }
}
function login_user(array $u): void {
    session_regenerate_id(true);
    $_SESSION['user'] = ['id'=>$u['id'],'name'=>$u['name'],'email'=>$u['email'],'role'=>$u['role'],'branch_id'=>$u['branch_id'],'avatar'=>$u['avatar'] ?? null];
    $_SESSION['branch_id'] = (int)$u['branch_id'];
}
function logout_user(): void { $_SESSION=[]; if (ini_get('session.use_cookies')) { $p=session_get_cookie_params(); setcookie(session_name(),'',time()-42000,$p['path'],$p['domain'],$p['secure'],$p['httponly']); } session_destroy(); }
