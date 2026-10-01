<?php
require_once __DIR__.'/../includes/auth.php';require_role(['super_admin']);
if($_SERVER['REQUEST_METHOD']==='POST'){verify_csrf();
  $allowed=['company_name','company_tagline','company_phone','company_email','company_address','currency_symbol','expiry_warning_days','retention_days','retention_visit_threshold','traffic_analysis_days','equipment_warning_days','tax_percent'];
  $stmt=db()->prepare("INSERT INTO system_settings(setting_key,setting_value,group_name) VALUES(?,?,?) ON DUPLICATE KEY UPDATE setting_value=VALUES(setting_value),group_name=VALUES(group_name)");
  foreach($allowed as $k){$group=in_array($k,['company_name','company_tagline','company_phone','company_email','company_address'])?'branding':(in_array($k,['currency_symbol','tax_percent'])?'finance':'rules');$stmt->execute([$k,trim((string)($_POST[$k]??'')),$group]);}
  audit_log('settings.updated','system',null,'Business settings updated');
  flash('success','Business settings saved.');redirect('app/settings.php');
}
$rows=[];foreach(query_all('SELECT setting_key,setting_value FROM system_settings') as $r)$rows[$r['setting_key']]=$r['setting_value'];
$v=fn($k,$d='')=>e($rows[$k]??$d);
$pageTitle='Business Settings';include __DIR__.'/../includes/header.php';?>
<form method="post"><input type="hidden" name="csrf" value="<?= csrf_token() ?>">
<div class="grid-2">
<div class="panel"><div class="panel-head"><div><h3>Brand & contact</h3><p>Used across the public site, receipts and system UI</p></div></div>
<div class="row g-3">
<div class="col-12"><label class="form-label">Company / gym name</label><input name="company_name" class="form-control" value="<?= $v('company_name','FitCore Pro') ?>"></div>
<div class="col-12"><label class="form-label">Tagline</label><input name="company_tagline" class="form-control" value="<?= $v('company_tagline','Smart Gym & Fitness Business Platform') ?>"></div>
<div class="col-md-6"><label class="form-label">Phone</label><input name="company_phone" class="form-control" value="<?= $v('company_phone') ?>"></div>
<div class="col-md-6"><label class="form-label">Email</label><input name="company_email" class="form-control" value="<?= $v('company_email') ?>"></div>
<div class="col-12"><label class="form-label">Address</label><input name="company_address" class="form-control" value="<?= $v('company_address') ?>"></div>
<div class="col-md-6"><label class="form-label">Currency symbol</label><input name="currency_symbol" class="form-control" value="<?= $v('currency_symbol','৳') ?>"></div>
<div class="col-md-6"><label class="form-label">Default tax %</label><input type="number" min="0" step=".01" name="tax_percent" class="form-control" value="<?= $v('tax_percent','0') ?>"></div>
</div></div>
<div class="panel"><div class="panel-head"><div><h3>Business rules</h3><p>Change operating thresholds without editing PHP code</p></div></div><div class="row g-3">
<div class="col-md-6"><label class="form-label">Expiry warning days</label><input type="number" min="1" name="expiry_warning_days" class="form-control" value="<?= $v('expiry_warning_days','7') ?>"></div>
<div class="col-md-6"><label class="form-label">Equipment warning days</label><input type="number" min="1" name="equipment_warning_days" class="form-control" value="<?= $v('equipment_warning_days','7') ?>"></div>
<div class="col-md-6"><label class="form-label">Retention lookback days</label><input type="number" min="1" name="retention_days" class="form-control" value="<?= $v('retention_days','14') ?>"></div>
<div class="col-md-6"><label class="form-label">At-risk visit threshold</label><input type="number" min="0" name="retention_visit_threshold" class="form-control" value="<?= $v('retention_visit_threshold','1') ?>"></div>
<div class="col-md-6"><label class="form-label">Traffic analysis days</label><input type="number" min="7" name="traffic_analysis_days" class="form-control" value="<?= $v('traffic_analysis_days','60') ?>"></div>
<div class="col-12"><div class="alert alert-dark border-secondary small mb-0">These values drive dashboard renewal alerts, retention watch, equipment service warnings and traffic analytics dynamically.</div></div>
<div class="col-12"><button class="btn btn-primary"><i class="fa-solid fa-floppy-disk me-2"></i>Save settings</button></div>
</div></div></div></form>
<?php include __DIR__.'/../includes/footer.php';?>
