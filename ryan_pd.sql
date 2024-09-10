-- SQL to create the police_weapons table
CREATE TABLE IF NOT EXISTS `police_weapons` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `officer_id` VARCHAR(50) NOT NULL,
    `officer_name` VARCHAR(50) NOT NULL,
    `weapon_name` VARCHAR(50) NOT NULL,
    `date_issued` DATETIME DEFAULT CURRENT_TIMESTAMP
);
