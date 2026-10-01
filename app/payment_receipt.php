<?php
require_once __DIR__.'/../includes/auth.php';require_role(['super_admin','manager','receptionist','accountant']);$bid=current_branch_id();$id=(int)($_GET['id']??0);
$p=query_one("SELECT p.*,m.member_code,CONCAT(m.first_name,' ',m.last_name) member_name,m.phone,b.name branch_name,b.address branch_address FROM payments p JOIN members m ON m.id=p.member_id JOIN branches b ON b.id=p.branch_id WHERE p.id=? AND p.branch_id=?",[$id,$bid]);if(!$p){http_response_code(404);exit('Receipt not found');}
$pageTitle='Payment Receipt';include __DIR__.'/../includes/header.php';?>
<div class="receipt-sheet">
<div class="receipt-head"><div><span class="brand-mark"><i class="fa-solid fa-bolt"></i></span><h2><?= e(setting('company_name','FitCore Pro')) ?></h2><p><?= e(setting('company_tagline','Smart Gym & Fitness Business Platform')) ?></p></div><div class="text-end"><span class="section-kicker">PAYMENT RECEIPT</span><h3><?= e($p['reference_no']) ?></h3><p><?= format_date($p['payment_date']) ?></p></div></div>
<div class="receipt-grid"><div><small>Received from</small><strong><?= e($p['member_name']) ?></strong><span><?= e($p['member_code']) ?> · <?= e($p['phone']) ?></span></div><div><small>Branch</small><strong><?= e($p['branch_name']) ?></strong><span><?= e($p['branch_address']) ?></span></div></div>
<div class="receipt-total"><div><span><?= e($p['payment_type']) ?></span><small><?= e($p['method']) ?><?= $p['note']?' · '.e($p['note']):'' ?></small></div><strong><?= money($p['amount']) ?></strong></div>
<div class="receipt-footer"><div><small><?= e(setting('company_phone','')) ?> · <?= e(setting('company_email','')) ?></small></div><span class="badge-soft badge-success"><?= e(ucfirst($p['status'])) ?></span></div>
<div class="d-flex gap-2 mt-4 no-print"><button class="btn btn-primary" onclick="window.print()"><i class="fa-solid fa-print me-2"></i>Print / Save PDF</button><a class="btn btn-dark" href="<?= url('app/payments.php') ?>">Back to payments</a></div>
</div>
<?php include __DIR__.'/../includes/footer.php';?>
