# FitCore Pro — Final Company Demo Edition

**Smart Gym & Fitness Business Platform** built with PHP 8+, MySQL/MariaDB, Bootstrap 5, JavaScript and Chart.js.

This final edition keeps the original premium dark UI and adds configurable business rules, member self-service, membership-plan management, printable receipts, nutrition plans, equipment service history, live alerts, global search and audit logs.

## Final features

- Premium public website with large gym photography and automatic slideshow
- Fully database-driven homepage KPIs
- Staff role-based authentication
- Super Admin, Manager, Receptionist, Trainer and Accountant workspaces
- Separate member self-service portal
- Multi-branch control and branch comparison
- Member CRM, membership lifecycle and digital QR card
- QR/manual attendance with expiry and duplicate-entry protection
- Dynamic membership plans: add, edit, activate/deactivate, price and duration
- Membership renewal with optional discount and printable payment receipt
- Membership freeze / reactivate
- Payment ledger and CSV export
- Trainer roster, client assignment and workload visibility
- Workout plans and body/BMI progress charts
- Diet & nutrition plans with calorie/macronutrient targets and meals
- Classes, capacity, member booking and member-side booking/waitlist
- Equipment register plus maintenance/service history and service costs
- Expense management, revenue and net-position analytics
- Smart retention watch using configurable attendance rules
- Configurable expiry, retention, traffic and service-warning rules
- Live operational alerts generated from current database data
- Global search across members, trainers and payments
- Audit log showing important staff actions
- CSV reports and browser Print / Save PDF
- Responsive premium dark design for desktop, tablet and mobile

## XAMPP setup — choose ONE database method

### A. Fresh final installation
Use this when you do not need to keep an older FitCore database.

1. Copy the `fitcore_pro_final` folder into `C:\xampp\htdocs\`.
2. Start **Apache** and **MySQL**.
3. Open `http://localhost/phpmyadmin`.
4. Click **Import** and choose only:
   `database/fitcore.sql`
5. The installer creates/recreates the `fitcore_pro` database and loads all final demo data.
6. Copy `.env.example` to `.env`.
7. Open:
   `http://localhost/fitcore_pro_final/`

### B. Upgrade the earlier FitCore version without deleting its data
Use this if you already imported the earlier `fitcore.sql` and want to keep that database.

1. Replace/copy the project folder with this final code.
2. Open phpMyAdmin and select the existing `fitcore_pro` database.
3. Import only:
   `database/upgrade_to_final.sql`
4. Do **not** import `fitcore.sql` afterward because the fresh installer drops and recreates the demo tables.
5. Copy `.env.example` to `.env` if you do not already have `.env`.
6. Open the final project URL.

## Staff demo accounts

| Role | Email | Password |
|---|---|---|
| Super Admin | admin@fitcore.com | admin123 |
| Branch Manager | manager@fitcore.com | manager123 |
| Trainer | trainer@fitcore.com | trainer123 |
| Receptionist | frontdesk@fitcore.com | manager123 |
| Accountant | accounts@fitcore.com | manager123 |

## Member portal demo

- URL: `http://localhost/fitcore_pro_final/member/login.php`
- Email: `member@fitcore.com`
- Password: `member123`

The member can see only their own membership, QR card, attendance, payments, workout plans, nutrition plan, progress chart and class bookings.

## Best final demo workflow

1. Public homepage → show live branch/member/trainer/class statistics and slideshow.
2. Staff login → Super Admin.
3. Dashboard → explain that KPIs come from operational tables.
4. Settings → show that expiry, retention and maintenance rules can be changed without code.
5. Membership Plans → create/edit a commercial plan.
6. Members → create/open a member.
7. Member profile → QR card, renew with discount, freeze/reactivate, body progress.
8. Attendance → QR/manual check-in and membership validation.
9. Payments → create a payment and open the printable receipt.
10. Trainers → show client load.
11. Workout Plans → create a plan.
12. Diet Plans → create nutrition/macros/meal plan.
13. Classes → schedule/book.
14. Equipment → record service and see maintenance history/cost.
15. Expenses → record a business cost.
16. Analytics → revenue vs expense, retention, traffic, plan mix and growth.
17. Branches → compare members, trainers, visits, revenue, expense and net.
18. Audit Logs → show who changed important business records.
19. Member Portal → sign in as `member@fitcore.com` to show the customer side.
20. Reports → CSV export / Print to PDF.

## Internet note

The project uses CDN-hosted Bootstrap, Chart.js, Font Awesome, Google Fonts, QR libraries and Unsplash gym photography. Keep internet access during a presentation for the full visual experience. PHP/MySQL records remain in your local XAMPP database.

## Production note

This is a polished university/company demonstration platform, not a certified production billing or health platform. Before a real commercial launch, add a real payment gateway, email/SMS/WhatsApp provider, scheduled backups, HTTPS-only deployment, formal data-retention/privacy controls, rate limiting, automated tests and production monitoring.
