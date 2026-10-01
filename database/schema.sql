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

