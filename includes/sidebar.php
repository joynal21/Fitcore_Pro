<?php
$active = basename($_SERVER['PHP_SELF']);
$role = user()['role'] ?? '';
$nav = [
 ['dashboard.php','fa-grid-2','Dashboard',['super_admin','manager','receptionist','trainer','accountant']],
 ['members.php','fa-users','Members',['super_admin','manager','receptionist','trainer']],
 ['trainers.php','fa-dumbbell','Trainers',['super_admin','manager','receptionist']],
 ['attendance.php','fa-qrcode','Attendance',['super_admin','manager','receptionist','trainer']],
 ['payments.php','fa-wallet','Payments',['super_admin','manager','receptionist','accountant']],
 ['classes.php','fa-calendar-days','Classes',['super_admin','manager','receptionist','trainer']],
 ['workouts.php','fa-person-running','Workout Plans',['super_admin','manager','trainer']],
 ['diet_plans.php','fa-bowl-food','Diet Plans',['super_admin','manager','trainer']],
 ['equipment.php','fa-screwdriver-wrench','Equipment',['super_admin','manager']],
 ['expenses.php','fa-receipt','Expenses',['super_admin','manager','accountant']],
 ['analytics.php','fa-chart-line','Analytics',['super_admin','manager','accountant']],
 ['reports.php','fa-file-export','Reports',['super_admin','manager','accountant']],
 ['plans.php','fa-tags','Membership Plans',['super_admin','manager']],
 ['branches.php','fa-code-branch','Branches',['super_admin']],
 ['audit_logs.php','fa-clock-rotate-left','Audit Logs',['super_admin']],
 ['settings.php','fa-sliders','Settings',['super_admin']],
];
?>
<aside class="sidebar" id="sidebar">
  <a class="brand" href="<?= url('app/dashboard.php') ?>">
    <span class="brand-mark"><i class="fa-solid fa-bolt"></i></span>
    <span><strong><?= e(setting('company_name','FitCore Pro')) ?></strong><em>PRO</em></span>
  </a>
  <div class="branch-pill"><span class="dot"></span><div><small>Current branch</small><strong><?= e(branch_name()) ?></strong></div></div>
  <nav>
    <?php foreach($nav as [$file,$icon,$label,$roles]): if(!in_array($role,$roles,true)) continue; ?>
      <a class="nav-link <?= $active===$file?'active':'' ?>" href="<?= url('app/'.$file) ?>"><i class="fa-solid <?= $icon ?>"></i><span><?= e($label) ?></span></a>
    <?php endforeach; ?>
  </nav>
  <div class="sidebar-bottom">
    <a class="nav-link <?= $active==='notifications.php'?'active':'' ?>" href="<?= url('app/notifications.php') ?>"><i class="fa-regular fa-bell"></i><span>Notifications</span></a>
    <a class="nav-link <?= $active==='profile.php'?'active':'' ?>" href="<?= url('app/profile.php') ?>"><i class="fa-regular fa-user"></i><span>My Profile</span></a>
    <a class="nav-link logout" href="<?= url('auth/logout.php') ?>"><i class="fa-solid fa-arrow-right-from-bracket"></i><span>Sign out</span></a>
  </div>
</aside>
