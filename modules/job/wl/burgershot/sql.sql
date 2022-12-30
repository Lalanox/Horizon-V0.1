--- Jobs

INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES ('burgershot', 'Burger Shot', '1');

--- Jobs / Grades 

INSERT INTO `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES (NULL, 'burgershot', '0', 'equipier', 'Equipier', '200', '', '');
INSERT INTO `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES (NULL, 'burgershot', '1', 'manager', 'Manager', '400', '', '');
INSERT INTO `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES (NULL, 'burgershot', '2', 'patron', 'Patron', '700', '', '');



--- Addon Account 
INSERT INTO `addon_account` (`name`, `label`, `shared`) VALUES ('society_burgershot', 'BurgerShot', '1');

--- Addon Acount Data
INSERT INTO `addon_account_data` (`id`, `account_name`, `money`, `owner`) VALUES (NULL, 'society_burgershot', '0', NULL);

--- Addon Inventory 
INSERT INTO `addon_inventory` (`name`, `label`, `shared`) VALUES ('society_burgershot', 'BurgerShot', '1');

--- Items
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('steak', 'Steak', '1', '0', '1'), ('mayonnaise', 'Mayonnaise', '1', '0', '1'), ('ketchup', 'Ketchup', '1', '0', '1'), ('pain', 'Pain', '1', '0', '1'), ('salade', 'Salade', '1', '0', '1'), 
('sel', 'Sel', '1', '0', '1'), ('bacon', 'Bacon', '1', '0', '1'), ('patate', 'Patate', '1', '0', '1'), ('frite', 'Frite', '1', '0', '1'), ('frite-Bacon', 'Frite-Bacon', '1', '0', '1')
, ('giant', 'Giant', '1', '0', '1'), ('wooper', 'Wooper', '1', '0', '1');

