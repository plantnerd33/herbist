-- Supporting tables for Herbist
-- Each table linked to a herb via herb_id

CREATE TABLE IF NOT EXISTS constituents (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    herb_id INT NOT NULL,
    name VARCHAR(250) NOT NULL,
    FOREIGN KEY (herb_id) REFERENCES herb(ID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS actions (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    herb_id INT NOT NULL,
    name VARCHAR(250) NOT NULL,
    FOREIGN KEY (herb_id) REFERENCES herb(ID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS energetics (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    herb_id INT NOT NULL,
    name VARCHAR(250) NOT NULL,
    FOREIGN KEY (herb_id) REFERENCES herb(ID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS indications (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    herb_id INT NOT NULL,
    name VARCHAR(250) NOT NULL,
    FOREIGN KEY (herb_id) REFERENCES herb(ID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS plantfamily (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    herb_id INT NOT NULL,
    name VARCHAR(250) NOT NULL,
    FOREIGN KEY (herb_id) REFERENCES herb(ID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS bodysystems (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    herb_id INT NOT NULL,
    name VARCHAR(250) NOT NULL,
    FOREIGN KEY (herb_id) REFERENCES herb(ID) ON DELETE CASCADE
);

-- Sample data for Peppermint (ID 1)
INSERT INTO constituents (herb_id, name) VALUES (1, 'Menthol'), (1, 'Menthone');
INSERT INTO actions (herb_id, name) VALUES (1, 'Carminative'), (1, 'Antispasmodic');
INSERT INTO energetics (herb_id, name) VALUES (1, 'Cooling'), (1, 'Drying');
INSERT INTO plantfamily (herb_id, name) VALUES (1, 'Lamiaceae');
