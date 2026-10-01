USE fitcore_pro;

CREATE TABLE IF NOT EXISTS system_settings (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(100) NOT NULL UNIQUE,
  setting_value TEXT NULL,
  group_name VARCHAR(60) NOT NULL DEFAULT 'general',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS member_accounts (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  member_id INT UNSIGNED NOT NULL UNIQUE,
  email VARCHAR(160) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  is_active TINYINT(1) DEFAULT 1,
  last_login DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS diet_plans (
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

CREATE TABLE IF NOT EXISTS diet_items (
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

CREATE TABLE IF NOT EXISTS equipment_maintenance (
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

INSERT IGNORE INTO system_settings(setting_key,setting_value,group_name) VALUES
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

INSERT IGNORE INTO member_accounts(member_id,email,password,is_active)
SELECT id,'member@fitcore.com','$2y$12$vI6ATKXjYZ8QPjqjGNQfcu1PayHM/1wgr.wJo.qO87xCJuFS4t3Ci',1 FROM members ORDER BY id LIMIT 1;
