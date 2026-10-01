<?php
require_once __DIR__ . '/auth.php';
require_login();
$pageTitle = $pageTitle ?? 'Dashboard';
$flashes = get_flashes();
$unread=(int)query_value('SELECT COUNT(*) FROM notifications WHERE branch_id=? AND is_read=0 AND (user_id IS NULL OR user_id=?)',[current_branch_id(),user()['id']]);
?>
<!doctype html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title><?= e($pageTitle) ?> · <?= e(setting('company_name',APP_NAME)) ?></title>
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Manrope:wght@600;700;800&display=swap" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" rel="stylesheet">
<link href="<?= url('assets/css/style.css') ?>" rel="stylesheet">
</head><body class="app-body">
<?php include __DIR__.'/sidebar.php'; ?>
<main class="main-shell">
<header class="topbar">
  <button class="icon-btn mobile-menu" id="menuToggle"><i class="fa-solid fa-bars"></i></button>
  <div class="topbar-title"><span class="eyebrow"><?= e(branch_name()) ?></span><h1><?= e($pageTitle) ?></h1></div>
  <div class="topbar-actions">
    <form class="top-search" action="<?= url('app/search.php') ?>" method="get"><i class="fa-solid fa-magnifying-glass"></i><input name="q" placeholder="Search member, payment..." aria-label="Global search"></form>
    <a class="icon-btn" href="<?= url('app/notifications.php') ?>"><i class="fa-regular fa-bell"></i><?php if($unread): ?><span class="notify-dot"></span><?php endif; ?></a>
    <div class="user-chip">
      <div class="avatar"><?= e(initials(user()['name']??'User')) ?></div>
      <div><strong><?= e(user()['name']??'User') ?></strong><small><?= e(ucwords(str_replace('_',' ',user()['role']??''))) ?></small></div>
      <i class="fa-solid fa-chevron-down"></i>
    </div>
  </div>
</header>
<section class="content-wrap">
<?php foreach($flashes as $f): ?><div class="alert alert-<?= e($f['type']) ?> alert-dismissible fade show" role="alert"><?= e($f['message']) ?><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div><?php endforeach; ?>
