INSERT INTO companies (name, default_currency)
VALUES ('DemoCorp', 'INR');

INSERT INTO users (company_id, name, email, role)
VALUES 
(1, 'Admin User', 'admin@test.com', 'ADMIN'),
(1, 'Manager User', 'manager@test.com', 'MANAGER'),
(1, 'Employee User', 'employee@test.com', 'EMPLOYEE');
