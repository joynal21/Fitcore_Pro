</section>
<footer class="app-footer"><span>© <?= date('Y') ?> <?= e(setting('company_name','FitCore Pro')) ?></span><span>Business-ready fitness operations platform</span></footer>
</main>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js"></script>
<script src="<?= url('assets/js/app.js') ?>"></script>
<?php if (!empty($pageScript)) echo $pageScript; ?>
</body></html>
