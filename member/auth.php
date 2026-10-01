<?php
require_once __DIR__.'/../includes/functions.php';
function member_user(): array { return $_SESSION['member_user'] ?? []; }
function member_logged_in(): bool { return !empty($_SESSION['member_user']['member_id']); }
function require_member_login(): void { if(!member_logged_in()) redirect('member/login.php'); }
function login_member(array $row): void {
    session_regenerate_id(true);
    $_SESSION['member_user']=['account_id'=>$row['account_id'],'member_id'=>$row['member_id'],'name'=>$row['name'],'email'=>$row['account_email'],'branch_id'=>$row['branch_id']];
}
function logout_member(): void { unset($_SESSION['member_user']); }
