CREATE DATABASE IF NOT EXISTS fitcore_pro CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE fitcore_pro;

SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS equipment_maintenance, diet_items, diet_plans, member_accounts, system_settings, audit_logs, notifications, body_metrics, workout_items, workout_plans, class_bookings, classes, expenses, equipment, attendance, payments, members, trainers, membership_plans, users, branches;
SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE branches (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  code VARCHAR(20) NOT NULL UNIQUE,
  address VARCHAR(255), phone VARCHAR(40),
  status ENUM('active','inactive') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  branch_id INT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('super_admin','manager','receptionist','trainer','accountant') NOT NULL,
  phone VARCHAR(40), avatar VARCHAR(255),
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE membership_plans (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  branch_id INT UNSIGNED NULL,
  name VARCHAR(100) NOT NULL,
  duration_months INT NOT NULL,
  price DECIMAL(12,2) NOT NULL DEFAULT 0,
  signup_fee DECIMAL(12,2) NOT NULL DEFAULT 0,
  features TEXT,
  status ENUM('active','inactive') DEFAULT 'active',
  FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE trainers (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NULL,
  branch_id INT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(160), phone VARCHAR(40), photo VARCHAR(255),
  specialization VARCHAR(160), experience_years INT DEFAULT 0,
  rating DECIMAL(2,1) DEFAULT 5.0,
  commission_rate DECIMAL(5,2) DEFAULT 0,
  bio TEXT,
  status ENUM('active','inactive','leave') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE members (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  branch_id INT UNSIGNED NOT NULL,
  member_code VARCHAR(30) NOT NULL UNIQUE,
  first_name VARCHAR(80) NOT NULL, last_name VARCHAR(80) NOT NULL,
  email VARCHAR(160), phone VARCHAR(40), gender ENUM('Male','Female','Other') DEFAULT 'Male',
  dob DATE NULL, address VARCHAR(255), emergency_contact VARCHAR(120),
  join_date DATE NOT NULL,
  membership_plan_id INT UNSIGNED NULL,
  membership_start DATE NOT NULL, membership_end DATE NOT NULL,
  status ENUM('active','expired','frozen','inactive') DEFAULT 'active',
  height_cm DECIMAL(6,2) NULL, weight_kg DECIMAL(6,2) NULL,
  goal VARCHAR(120), trainer_id INT UNSIGNED NULL,
  notes TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,
  FOREIGN KEY (membership_plan_id) REFERENCES membership_plans(id) ON DELETE SET NULL,
  FOREIGN KEY (trainer_id) REFERENCES trainers(id) ON DELETE SET NULL,
  INDEX idx_member_branch_status(branch_id,status), INDEX idx_membership_end(membership_end)
) ENGINE=InnoDB;

CREATE TABLE payments (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  branch_id INT UNSIGNED NOT NULL, member_id INT UNSIGNED NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  method ENUM('Cash','Card','Bank','Mobile Banking') DEFAULT 'Cash',
  payment_type ENUM('Membership','Personal Training','Class','Product','Other') DEFAULT 'Membership',
  reference_no VARCHAR(80), payment_date DATE NOT NULL,
  status ENUM('paid','pending','refunded') DEFAULT 'paid', note VARCHAR(255),
  created_by INT UNSIGNED NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_payment_date(branch_id,payment_date)
) ENGINE=InnoDB;

CREATE TABLE attendance (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  branch_id INT UNSIGNED NOT NULL, member_id INT UNSIGNED NOT NULL,
  check_in DATETIME NOT NULL, check_out DATETIME NULL,
  method ENUM('QR','Manual','Card') DEFAULT 'QR',
  FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
  INDEX idx_attendance_checkin(branch_id,check_in), INDEX idx_attendance_member(member_id,check_in)
) ENGINE=InnoDB;

CREATE TABLE classes (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  branch_id INT UNSIGNED NOT NULL, trainer_id INT UNSIGNED NULL,
  title VARCHAR(120) NOT NULL, category VARCHAR(80),
  recurring_day VARCHAR(20), start_time TIME NOT NULL, end_time TIME NOT NULL,
  capacity INT DEFAULT 20, room VARCHAR(80),
  status ENUM('active','cancelled','inactive') DEFAULT 'active',
  FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,
  FOREIGN KEY (trainer_id) REFERENCES trainers(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE class_bookings (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  class_id INT UNSIGNED NOT NULL, member_id INT UNSIGNED NOT NULL,
  status ENUM('booked','attended','cancelled','waitlist') DEFAULT 'booked',
  booked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_booking(class_id,member_id),
  FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE equipment (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  branch_id INT UNSIGNED NOT NULL, asset_code VARCHAR(30) NOT NULL UNIQUE,
  name VARCHAR(120) NOT NULL, category VARCHAR(100), purchase_date DATE NULL,
  purchase_price DECIMAL(12,2) DEFAULT 0,
  condition_status ENUM('good','maintenance','damaged','retired') DEFAULT 'good',
  last_service DATE NULL, next_service DATE NULL, location VARCHAR(120), notes TEXT,
  FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE expenses (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  branch_id INT UNSIGNED NOT NULL, category VARCHAR(100) NOT NULL,
  title VARCHAR(160) NOT NULL, amount DECIMAL(12,2) NOT NULL,
  expense_date DATE NOT NULL, vendor VARCHAR(120),
  payment_method VARCHAR(60), note TEXT, created_by INT UNSIGNED NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_expense_date(branch_id,expense_date)
) ENGINE=InnoDB;

CREATE TABLE workout_plans (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  branch_id INT UNSIGNED NOT NULL, member_id INT UNSIGNED NOT NULL, trainer_id INT UNSIGNED NULL,
  title VARCHAR(140) NOT NULL, goal VARCHAR(140), start_date DATE, end_date DATE,
  status ENUM('active','completed','paused') DEFAULT 'active', notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
  FOREIGN KEY (trainer_id) REFERENCES trainers(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE workout_items (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  plan_id INT UNSIGNED NOT NULL, day_name VARCHAR(30) NOT NULL,
  exercise VARCHAR(120) NOT NULL, sets INT DEFAULT 3, reps VARCHAR(30) DEFAULT '10-12',
  rest_seconds INT DEFAULT 60, notes VARCHAR(255),
  FOREIGN KEY (plan_id) REFERENCES workout_plans(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE body_metrics (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  member_id INT UNSIGNED NOT NULL, recorded_on DATE NOT NULL,
  weight_kg DECIMAL(6,2), body_fat DECIMAL(5,2), bmi DECIMAL(5,2),
  chest_cm DECIMAL(6,2), waist_cm DECIMAL(6,2), arms_cm DECIMAL(6,2), notes VARCHAR(255),
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE notifications (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  branch_id INT UNSIGNED NOT NULL, user_id INT UNSIGNED NULL,
  title VARCHAR(140) NOT NULL, message VARCHAR(500) NOT NULL,
  type ENUM('info','success','warning','danger') DEFAULT 'info', is_read TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NULL, action VARCHAR(120) NOT NULL, entity_type VARCHAR(80), entity_id INT UNSIGNED NULL,
  description VARCHAR(500), ip_address VARCHAR(45), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE system_settings (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(100) NOT NULL UNIQUE,
  setting_value TEXT NULL,
  group_name VARCHAR(60) NOT NULL DEFAULT 'general',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE member_accounts (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  member_id INT UNSIGNED NOT NULL UNIQUE,
  email VARCHAR(160) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  is_active TINYINT(1) DEFAULT 1,
  last_login DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE diet_plans (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  branch_id INT UNSIGNED NOT NULL,
  member_id INT UNSIGNED NOT NULL,
  trainer_id INT UNSIGNED NULL,
  title VARCHAR(140) NOT NULL,
  goal VARCHAR(140),
  daily_calories INT NULL,
  protein_g INT NULL,
  carbs_g INT NULL,
  fat_g INT NULL,
  start_date DATE NULL,
  end_date DATE NULL,
  status ENUM('active','completed','paused') DEFAULT 'active',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
  FOREIGN KEY (trainer_id) REFERENCES trainers(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE diet_items (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  diet_plan_id INT UNSIGNED NOT NULL,
  meal_name VARCHAR(60) NOT NULL,
  item_name VARCHAR(255) NOT NULL,
  calories INT NULL,
  protein_g DECIMAL(7,2) NULL,
  carbs_g DECIMAL(7,2) NULL,
  fat_g DECIMAL(7,2) NULL,
  notes VARCHAR(255),
  FOREIGN KEY (diet_plan_id) REFERENCES diet_plans(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE equipment_maintenance (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  equipment_id INT UNSIGNED NOT NULL,
  service_date DATE NOT NULL,
  service_type VARCHAR(100) NOT NULL,
  vendor VARCHAR(120),
  cost DECIMAL(12,2) NOT NULL DEFAULT 0,
  notes VARCHAR(500),
  next_service DATE NULL,
  created_by INT UNSIGNED NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

USE fitcore_pro;

INSERT INTO branches (name,code,address,phone) VALUES
('FitCore Central','FC-CEN','Gulshan Avenue, Dhaka','+880 1700-110011'),
('FitCore North','FC-NTH','Uttara Sector 7, Dhaka','+880 1700-220022'),
('FitCore South','FC-STH','Dhanmondi 27, Dhaka','+880 1700-330033');

INSERT INTO users (branch_id,name,email,password,role,phone) VALUES
(1,'Araf Rahman','admin@fitcore.com','$2y$12$w4tN0fv6Tw86StvCBRZ1n.1q5grOHSbl0h8NY9hkRSGweE2zgnxmu','super_admin','01700110011'),
(1,'Nadia Islam','manager@fitcore.com','$2y$12$ps1zYEuJSChJ.tFrq//ys.vteknCECbuevt90ID7/ll5Q7uQt/78u','manager','01700110012'),
(1,'Samir Khan','trainer@fitcore.com','$2y$12$LssMKqg3yvZkxejvrCBaFuS3rm5GSYVW1l/eHqNNjZWi5Brs6KM9y','trainer','01700110013'),
(1,'Maliha Noor','frontdesk@fitcore.com','$2y$12$ps1zYEuJSChJ.tFrq//ys.vteknCECbuevt90ID7/ll5Q7uQt/78u','receptionist','01700110014'),
(1,'Tanim Ahmed','accounts@fitcore.com','$2y$12$ps1zYEuJSChJ.tFrq//ys.vteknCECbuevt90ID7/ll5Q7uQt/78u','accountant','01700110015');

INSERT INTO membership_plans(branch_id,name,duration_months,price,signup_fee,features) VALUES
(NULL,'Flex Monthly',1,2800,500,'Gym floor, locker access, 1 fitness assessment'),
(NULL,'Performance 3M',3,7200,0,'Gym floor, group classes, progress tracking'),
(NULL,'Elite 6M',6,12900,0,'All classes, nutrition consult, priority booking'),
(NULL,'Annual Pro',12,22800,0,'All access, 2 PT sessions, nutrition review, freeze option');

INSERT INTO trainers (user_id,branch_id,name,email,phone,specialization,experience_years,rating,commission_rate,bio,status) VALUES
(3,1,'Samir Khan','trainer@fitcore.com','01700110013','Strength & Conditioning',7,4.9,18,'Certified strength coach focused on progressive overload and performance.','active'),
(NULL,1,'Farzana Haque','farzana@fitcore.com','01700220021','Yoga & Mobility',5,4.8,15,'Mobility, yoga and recovery specialist.','active'),
(NULL,1,'Rafi Chowdhury','rafi@fitcore.com','01700220022','Fat Loss & HIIT',6,4.7,17,'High-energy conditioning and sustainable fat-loss coaching.','active'),
(NULL,2,'Tanvir Hasan','tanvir@fitcore.com','01700220023','Bodybuilding',8,4.9,20,'Hypertrophy and stage-prep specialist.','active'),
(NULL,3,'Sadia Karim','sadia@fitcore.com','01700220024','Functional Fitness',4,4.8,16,'Functional movement, endurance and beginner transformations.','active');

INSERT INTO members(branch_id,member_code,first_name,last_name,email,phone,gender,dob,address,emergency_contact,join_date,membership_plan_id,membership_start,membership_end,status,height_cm,weight_kg,goal,trainer_id,notes) VALUES
(1,'FC-1001','Fahim','Hossain','fahim@example.com','01711001001','Male','1998-03-12','Banani, Dhaka','Rina 01711111111',DATE_SUB(CURDATE(),INTERVAL 11 MONTH),4,DATE_SUB(CURDATE(),INTERVAL 11 MONTH),DATE_ADD(CURDATE(),INTERVAL 1 MONTH),'active',176,78,'Muscle Gain',1,'Prefers evening training'),
(1,'FC-1002','Nusrat','Jahan','nusrat@example.com','01711001002','Female','2000-07-22','Gulshan, Dhaka','Imran 01712222222',DATE_SUB(CURDATE(),INTERVAL 5 MONTH),3,DATE_SUB(CURDATE(),INTERVAL 5 MONTH),DATE_ADD(CURDATE(),INTERVAL 1 MONTH),'active',163,61,'Fat Loss',3,'Knee sensitivity; avoid high-impact jumps'),
(1,'FC-1003','Adnan','Kabir','adnan@example.com','01711001003','Male','1996-11-04','Badda, Dhaka','Mina 01713333333',DATE_SUB(CURDATE(),INTERVAL 2 MONTH),2,DATE_SUB(CURDATE(),INTERVAL 2 MONTH),DATE_ADD(CURDATE(),INTERVAL 1 MONTH),'active',181,86,'General Fitness',1,NULL),
(1,'FC-1004','Tasnia','Rahman','tasnia@example.com','01711001004','Female','2001-01-18','Mohakhali, Dhaka','Rahat 01714444444',DATE_SUB(CURDATE(),INTERVAL 30 DAY),1,DATE_SUB(CURDATE(),INTERVAL 30 DAY),DATE_ADD(CURDATE(),INTERVAL 2 DAY),'active',160,55,'Mobility',2,'Renewal due soon'),
(1,'FC-1005','Mehedi','Hasan','mehedi@example.com','01711001005','Male','1997-05-09','Khilgaon, Dhaka','Asha 01715555555',DATE_SUB(CURDATE(),INTERVAL 7 MONTH),3,DATE_SUB(CURDATE(),INTERVAL 7 MONTH),DATE_SUB(CURDATE(),INTERVAL 1 MONTH),'expired',174,82,'Fat Loss',3,'Follow up for renewal'),
(1,'FC-1006','Sadia','Nawar','sadia.n@example.com','01711001006','Female','1999-09-27','Tejgaon, Dhaka','Nabil 01716666666',DATE_SUB(CURDATE(),INTERVAL 4 MONTH),3,DATE_SUB(CURDATE(),INTERVAL 4 MONTH),DATE_ADD(CURDATE(),INTERVAL 2 MONTH),'active',165,58,'Strength',1,NULL),
(1,'FC-1007','Raihan','Ahmed','raihan@example.com','01711001007','Male','1995-12-14','Mirpur, Dhaka','Sumi 01717777777',DATE_SUB(CURDATE(),INTERVAL 10 MONTH),4,DATE_SUB(CURDATE(),INTERVAL 10 MONTH),DATE_ADD(CURDATE(),INTERVAL 2 MONTH),'active',178,90,'Weight Loss',3,'Attendance dropped recently'),
(1,'FC-1008','Mim','Akter','mim@example.com','01711001008','Female','2002-04-05','Rampura, Dhaka','Rupa 01718888888',DATE_SUB(CURDATE(),INTERVAL 20 DAY),1,DATE_SUB(CURDATE(),INTERVAL 20 DAY),DATE_ADD(CURDATE(),INTERVAL 10 DAY),'active',158,52,'General Fitness',2,NULL),
(1,'FC-1009','Arif','Mahmud','arif@example.com','01711001009','Male','1994-08-30','Niketon, Dhaka','Rumi 01719999999',DATE_SUB(CURDATE(),INTERVAL 6 MONTH),3,DATE_SUB(CURDATE(),INTERVAL 6 MONTH),DATE_ADD(CURDATE(),INTERVAL 7 DAY),'active',182,88,'Muscle Gain',1,'Interested in PT renewal'),
(1,'FC-1010','Tanjim','Sultana','tanjim@example.com','01711001010','Female','1998-06-02','Baridhara, Dhaka','Tarek 01710000001',DATE_SUB(CURDATE(),INTERVAL 3 MONTH),2,DATE_SUB(CURDATE(),INTERVAL 3 MONTH),DATE_ADD(CURDATE(),INTERVAL 5 DAY),'active',167,64,'Toning',2,NULL),
(2,'FC-2001','Omar','Faruk','omar@example.com','01722001001','Male','1998-03-03','Uttara, Dhaka','Sara 01722222221',DATE_SUB(CURDATE(),INTERVAL 1 MONTH),2,DATE_SUB(CURDATE(),INTERVAL 1 MONTH),DATE_ADD(CURDATE(),INTERVAL 2 MONTH),'active',177,76,'Strength',4,NULL),
(2,'FC-2002','Elma','Nisa','elma@example.com','01722001002','Female','2001-02-02','Uttara, Dhaka','Ali 01722222222',DATE_SUB(CURDATE(),INTERVAL 2 MONTH),2,DATE_SUB(CURDATE(),INTERVAL 2 MONTH),DATE_ADD(CURDATE(),INTERVAL 1 MONTH),'active',161,56,'Fat Loss',4,NULL),
(3,'FC-3001','Joy','Roy','joy@example.com','01733001001','Male','1999-10-10','Dhanmondi, Dhaka','Mita 01733333331',DATE_SUB(CURDATE(),INTERVAL 4 MONTH),3,DATE_SUB(CURDATE(),INTERVAL 4 MONTH),DATE_ADD(CURDATE(),INTERVAL 2 MONTH),'active',175,73,'General Fitness',5,NULL);

INSERT INTO payments(branch_id,member_id,amount,method,payment_type,reference_no,payment_date,status,created_by) VALUES
(1,1,22800,'Card','Membership','INV-2401',DATE_SUB(CURDATE(),INTERVAL 11 MONTH),'paid',2),(1,2,12900,'Mobile Banking','Membership','INV-2402',DATE_SUB(CURDATE(),INTERVAL 5 MONTH),'paid',4),(1,3,7200,'Cash','Membership','INV-2403',DATE_SUB(CURDATE(),INTERVAL 2 MONTH),'paid',4),(1,4,2800,'Card','Membership','INV-2404',DATE_SUB(CURDATE(),INTERVAL 30 DAY),'paid',4),(1,6,7200,'Bank','Membership','INV-2406',DATE_SUB(CURDATE(),INTERVAL 4 MONTH),'paid',2),(1,7,22800,'Card','Membership','INV-2407',DATE_SUB(CURDATE(),INTERVAL 10 MONTH),'paid',2),(1,8,2800,'Mobile Banking','Membership','INV-2408',DATE_SUB(CURDATE(),INTERVAL 20 DAY),'paid',4),(1,9,12900,'Card','Membership','INV-2409',DATE_SUB(CURDATE(),INTERVAL 6 MONTH),'paid',2),(1,10,7200,'Cash','Membership','INV-2410',DATE_SUB(CURDATE(),INTERVAL 3 MONTH),'paid',4),
(1,1,3500,'Mobile Banking','Personal Training','PT-1001',DATE_SUB(CURDATE(),INTERVAL 4 DAY),'paid',2),(1,6,3500,'Card','Personal Training','PT-1006',DATE_SUB(CURDATE(),INTERVAL 8 DAY),'paid',2),(1,9,3500,'Cash','Personal Training','PT-1009',DATE_SUB(CURDATE(),INTERVAL 13 DAY),'paid',2),
(1,4,2800,'Card','Membership','REN-1004',CURDATE(),'paid',4),(1,8,2800,'Mobile Banking','Membership','REN-1008',DATE_SUB(CURDATE(),INTERVAL 2 DAY),'paid',4),
(2,11,7200,'Card','Membership','INV-2001',DATE_SUB(CURDATE(),INTERVAL 1 MONTH),'paid',2),(2,12,7200,'Cash','Membership','INV-2002',DATE_SUB(CURDATE(),INTERVAL 2 MONTH),'paid',2),(3,13,12900,'Bank','Membership','INV-3001',DATE_SUB(CURDATE(),INTERVAL 4 MONTH),'paid',2),
(1,3,2800,'Card','Membership','OLD-01',DATE_SUB(CURDATE(),INTERVAL 1 MONTH),'paid',2),(1,2,2800,'Card','Membership','OLD-02',DATE_SUB(CURDATE(),INTERVAL 2 MONTH),'paid',2),(1,1,2800,'Card','Membership','OLD-03',DATE_SUB(CURDATE(),INTERVAL 3 MONTH),'paid',2),(1,6,2800,'Card','Membership','OLD-04',DATE_SUB(CURDATE(),INTERVAL 4 MONTH),'paid',2),(1,7,2800,'Card','Membership','OLD-05',DATE_SUB(CURDATE(),INTERVAL 5 MONTH),'paid',2);

INSERT INTO attendance(branch_id,member_id,check_in,check_out,method) VALUES
(1,1,DATE_ADD(CURDATE(),INTERVAL 6 HOUR),DATE_ADD(CURDATE(),INTERVAL 7 HOUR),'QR'),
(1,2,DATE_ADD(CURDATE(),INTERVAL 7 HOUR),DATE_ADD(CURDATE(),INTERVAL 8 HOUR),'QR'),
(1,3,DATE_ADD(CURDATE(),INTERVAL 8 HOUR),NULL,'Manual'),
(1,4,DATE_ADD(CURDATE(),INTERVAL 9 HOUR),NULL,'QR'),
(1,6,DATE_ADD(CURDATE(),INTERVAL 17 HOUR),NULL,'QR'),
(1,8,DATE_ADD(CURDATE(),INTERVAL 18 HOUR),NULL,'QR'),
(1,9,DATE_ADD(CURDATE(),INTERVAL 19 HOUR),NULL,'Card'),
(1,10,DATE_ADD(CURDATE(),INTERVAL 20 HOUR),NULL,'QR'),
(1,1,DATE_SUB(NOW(),INTERVAL 2 DAY),DATE_SUB(NOW(),INTERVAL 2 DAY),'QR'),(1,1,DATE_SUB(NOW(),INTERVAL 4 DAY),DATE_SUB(NOW(),INTERVAL 4 DAY),'QR'),(1,1,DATE_SUB(NOW(),INTERVAL 6 DAY),DATE_SUB(NOW(),INTERVAL 6 DAY),'QR'),
(1,2,DATE_SUB(NOW(),INTERVAL 1 DAY),DATE_SUB(NOW(),INTERVAL 1 DAY),'QR'),(1,2,DATE_SUB(NOW(),INTERVAL 3 DAY),DATE_SUB(NOW(),INTERVAL 3 DAY),'QR'),
(1,3,DATE_SUB(NOW(),INTERVAL 2 DAY),DATE_SUB(NOW(),INTERVAL 2 DAY),'QR'),(1,3,DATE_SUB(NOW(),INTERVAL 5 DAY),DATE_SUB(NOW(),INTERVAL 5 DAY),'QR'),
(1,4,DATE_SUB(NOW(),INTERVAL 3 DAY),DATE_SUB(NOW(),INTERVAL 3 DAY),'QR'),
(1,6,DATE_SUB(NOW(),INTERVAL 1 DAY),DATE_SUB(NOW(),INTERVAL 1 DAY),'QR'),(1,6,DATE_SUB(NOW(),INTERVAL 2 DAY),DATE_SUB(NOW(),INTERVAL 2 DAY),'QR'),(1,6,DATE_SUB(NOW(),INTERVAL 5 DAY),DATE_SUB(NOW(),INTERVAL 5 DAY),'QR'),
(1,8,DATE_SUB(NOW(),INTERVAL 2 DAY),DATE_SUB(NOW(),INTERVAL 2 DAY),'QR'),(1,8,DATE_SUB(NOW(),INTERVAL 4 DAY),DATE_SUB(NOW(),INTERVAL 4 DAY),'QR'),
(1,9,DATE_SUB(NOW(),INTERVAL 1 DAY),DATE_SUB(NOW(),INTERVAL 1 DAY),'QR'),(1,10,DATE_SUB(NOW(),INTERVAL 2 DAY),DATE_SUB(NOW(),INTERVAL 2 DAY),'QR');

INSERT INTO classes(branch_id,trainer_id,title,category,recurring_day,start_time,end_time,capacity,room,status) VALUES
(1,2,'Morning Flow','Yoga','Monday','07:00','08:00',18,'Studio A','active'),(1,3,'HIIT Burn','HIIT','Tuesday','18:30','19:15',20,'Studio B','active'),(1,1,'Strength Lab','Strength','Wednesday','19:00','20:00',16,'Performance Zone','active'),(1,2,'Mobility Reset','Mobility','Thursday','18:00','18:45',20,'Studio A','active'),(1,3,'Weekend Circuit','Functional','Saturday','09:00','10:00',22,'Main Floor','active');
INSERT INTO class_bookings(class_id,member_id,status) VALUES (1,2,'booked'),(1,4,'booked'),(1,8,'booked'),(2,2,'booked'),(2,7,'booked'),(2,10,'booked'),(3,1,'booked'),(3,3,'booked'),(3,6,'booked'),(3,9,'booked'),(4,4,'booked'),(4,8,'booked'),(5,1,'booked'),(5,6,'booked');

INSERT INTO equipment(branch_id,asset_code,name,category,purchase_date,purchase_price,condition_status,last_service,next_service,location,notes) VALUES
(1,'EQ-001','LifeFitness Treadmill 01','Cardio',DATE_SUB(CURDATE(),INTERVAL 2 YEAR),420000,'good',DATE_SUB(CURDATE(),INTERVAL 25 DAY),DATE_ADD(CURDATE(),INTERVAL 65 DAY),'Cardio Zone',NULL),(1,'EQ-002','LifeFitness Treadmill 02','Cardio',DATE_SUB(CURDATE(),INTERVAL 2 YEAR),420000,'maintenance',DATE_SUB(CURDATE(),INTERVAL 95 DAY),DATE_ADD(CURDATE(),INTERVAL 2 DAY),'Cardio Zone','Belt calibration scheduled'),(1,'EQ-003','Olympic Power Rack','Strength',DATE_SUB(CURDATE(),INTERVAL 18 MONTH),190000,'good',DATE_SUB(CURDATE(),INTERVAL 40 DAY),DATE_ADD(CURDATE(),INTERVAL 80 DAY),'Strength Zone',NULL),(1,'EQ-004','Cable Crossover','Strength',DATE_SUB(CURDATE(),INTERVAL 15 MONTH),260000,'good',DATE_SUB(CURDATE(),INTERVAL 18 DAY),DATE_ADD(CURDATE(),INTERVAL 72 DAY),'Strength Zone',NULL),(1,'EQ-005','Air Bike','Conditioning',DATE_SUB(CURDATE(),INTERVAL 10 MONTH),115000,'damaged',DATE_SUB(CURDATE(),INTERVAL 130 DAY),CURDATE(),'HIIT Zone','Pedal assembly requires replacement'),(1,'EQ-006','Rowing Machine','Cardio',DATE_SUB(CURDATE(),INTERVAL 8 MONTH),145000,'good',DATE_SUB(CURDATE(),INTERVAL 20 DAY),DATE_ADD(CURDATE(),INTERVAL 70 DAY),'Cardio Zone',NULL);

INSERT INTO expenses(branch_id,category,title,amount,expense_date,vendor,payment_method,note,created_by) VALUES
(1,'Rent','Monthly facility rent',180000,DATE_SUB(CURDATE(),INTERVAL 6 DAY),'Property Management','Bank','Monthly rent',5),(1,'Utilities','Electricity & water',48500,DATE_SUB(CURDATE(),INTERVAL 5 DAY),'Utility Provider','Bank',NULL,5),(1,'Maintenance','Treadmill service',12500,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'Fitness Tech BD','Bank','Preventive maintenance',5),(1,'Supplies','Cleaning and hygiene supplies',8700,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'CleanPro','Cash',NULL,5),(1,'Marketing','Social campaign',22000,DATE_SUB(CURDATE(),INTERVAL 11 DAY),'PixelGrowth','Mobile Banking','Lead generation campaign',5),(1,'Payroll','Trainer incentives',76500,DATE_SUB(CURDATE(),INTERVAL 13 DAY),'Staff','Bank','Monthly incentive pool',5),
(1,'Rent','Previous month facility rent',180000,DATE_SUB(CURDATE(),INTERVAL 1 MONTH),'Property Management','Bank',NULL,5),(1,'Utilities','Previous month utilities',46200,DATE_SUB(CURDATE(),INTERVAL 1 MONTH),'Utility Provider','Bank',NULL,5);

INSERT INTO workout_plans(branch_id,member_id,trainer_id,title,goal,start_date,end_date,status,notes) VALUES
(1,1,1,'Lean Strength Block','Muscle Gain',DATE_SUB(CURDATE(),INTERVAL 10 DAY),DATE_ADD(CURDATE(),INTERVAL 6 WEEK),'active','Four-day upper/lower split'),(1,2,3,'Metabolic Foundation','Fat Loss',DATE_SUB(CURDATE(),INTERVAL 14 DAY),DATE_ADD(CURDATE(),INTERVAL 4 WEEK),'active','Low-impact conditioning focus'),(1,6,1,'Strength Essentials','Strength',DATE_SUB(CURDATE(),INTERVAL 20 DAY),DATE_ADD(CURDATE(),INTERVAL 5 WEEK),'active','Progressive full-body strength'),(1,8,2,'Mobility Starter','Mobility',DATE_SUB(CURDATE(),INTERVAL 5 DAY),DATE_ADD(CURDATE(),INTERVAL 3 WEEK),'active','Mobility and postural work');
INSERT INTO workout_items(plan_id,day_name,exercise,sets,reps,rest_seconds,notes) VALUES
(1,'Day 1','Barbell Squat',4,'6-8',120,'Controlled depth'),(1,'Day 1','Romanian Deadlift',3,'8-10',90,NULL),(1,'Day 2','Bench Press',4,'6-8',120,NULL),(1,'Day 2','Lat Pulldown',4,'8-12',75,NULL),(2,'Day 1','Incline Walk',1,'20 min',0,'Zone 2 pace'),(2,'Day 1','Goblet Squat',3,'12',60,NULL),(2,'Day 2','Bike Intervals',8,'30 sec',60,'Moderate resistance'),(3,'Day 1','Trap Bar Deadlift',4,'5',120,NULL),(3,'Day 1','Dumbbell Press',3,'10',75,NULL),(4,'Day 1','Hip Mobility Flow',2,'10 min',30,NULL),(4,'Day 2','Yoga Flow',1,'30 min',0,NULL);

INSERT INTO body_metrics(member_id,recorded_on,weight_kg,body_fat,bmi,chest_cm,waist_cm,arms_cm) VALUES
(1,DATE_SUB(CURDATE(),INTERVAL 60 DAY),75.2,18.5,24.3,98,84,34),(1,DATE_SUB(CURDATE(),INTERVAL 30 DAY),76.8,18.0,24.8,99,83,35),(1,CURDATE(),78.0,17.6,25.2,101,82,36),(2,DATE_SUB(CURDATE(),INTERVAL 45 DAY),64.5,29.0,24.3,91,78,29),(2,CURDATE(),61.0,26.8,23.0,89,73,28),(6,DATE_SUB(CURDATE(),INTERVAL 30 DAY),56.8,25.1,20.9,86,68,28),(6,CURDATE(),58.0,23.7,21.3,88,67,29);

INSERT INTO notifications(branch_id,user_id,title,message,type,is_read,created_at) VALUES
(1,2,'3 memberships ending soon','Tasnia, Arif and Tanjim have memberships ending within 7 days.','warning',0,NOW()),(1,2,'Equipment service due','Treadmill 02 requires scheduled maintenance within 2 days.','warning',0,DATE_SUB(NOW(),INTERVAL 2 HOUR)),(1,2,'Revenue milestone','This month membership collections crossed the internal weekly target.','success',0,DATE_SUB(NOW(),INTERVAL 5 HOUR)),(1,3,'Workout review due','Review Fahim Hossain’s strength plan progression.','info',0,DATE_SUB(NOW(),INTERVAL 1 DAY));

INSERT INTO system_settings(setting_key,setting_value,group_name) VALUES
('company_name','FitCore Pro','branding'),
('company_tagline','Smart Gym & Fitness Business Platform','branding'),
('company_phone','+880 1700-110011','branding'),
('company_email','hello@fitcore.com','branding'),
('company_address','Gulshan Avenue, Dhaka','branding'),
('currency_symbol','৳','finance'),
('expiry_warning_days','7','rules'),
('retention_days','14','rules'),
('retention_visit_threshold','1','rules'),
('traffic_analysis_days','60','rules'),
('equipment_warning_days','7','rules'),
('tax_percent','0','finance');

INSERT INTO member_accounts(member_id,email,password,is_active) VALUES
(1,'member@fitcore.com','$2y$12$vI6ATKXjYZ8QPjqjGNQfcu1PayHM/1wgr.wJo.qO87xCJuFS4t3Ci',1);

INSERT INTO diet_plans(branch_id,member_id,trainer_id,title,goal,daily_calories,protein_g,carbs_g,fat_g,start_date,end_date,status,notes) VALUES
(1,1,1,'Lean Strength Nutrition','Muscle Gain',2450,155,280,75,DATE_SUB(CURDATE(),INTERVAL 7 DAY),DATE_ADD(CURDATE(),INTERVAL 5 WEEK),'active','Balanced surplus with high protein and simple meals.');
INSERT INTO diet_items(diet_plan_id,meal_name,item_name,calories,protein_g,carbs_g,fat_g,notes) VALUES
(1,'Breakfast','Oats, banana, eggs and milk',620,32,78,20,'Hydrate before training'),
(1,'Lunch','Rice, grilled chicken, vegetables and yogurt',720,48,82,18,NULL),
(1,'Snack','Greek yogurt, fruit and mixed nuts',390,24,38,16,NULL),
(1,'Dinner','Fish, potatoes, salad and lentil soup',650,47,70,18,NULL);

INSERT INTO equipment_maintenance(equipment_id,service_date,service_type,vendor,cost,notes,next_service,created_by) VALUES
(1,DATE_SUB(CURDATE(),INTERVAL 25 DAY),'Preventive service','Fitness Tech BD',4500,'Belt tension and lubrication',DATE_ADD(CURDATE(),INTERVAL 65 DAY),2),
(2,DATE_SUB(CURDATE(),INTERVAL 95 DAY),'Preventive service','Fitness Tech BD',5200,'Calibration and safety inspection',DATE_ADD(CURDATE(),INTERVAL 2 DAY),2);

INSERT INTO audit_logs(user_id,action,entity_type,entity_id,description,ip_address,created_at) VALUES
(2,'member.created','member',1,'Demo audit: member onboarding workflow created','127.0.0.1',DATE_SUB(NOW(),INTERVAL 2 DAY)),
(4,'attendance.checkin','attendance',1,'Demo audit: QR check-in recorded','127.0.0.1',DATE_SUB(NOW(),INTERVAL 1 DAY)),
(5,'payment.created','payment',1,'Demo audit: membership payment recorded','127.0.0.1',DATE_SUB(NOW(),INTERVAL 5 HOUR));

