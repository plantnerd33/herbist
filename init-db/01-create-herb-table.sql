CREATE TABLE IF NOT EXISTS herb (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    common_name VARCHAR(250) NOT NULL,
    latin_name VARCHAR(250),
    synonyms TEXT,
    other_names TEXT,
    description TEXT,
    collection TEXT,
    uses TEXT,
    safety TEXT,
    dosage TEXT,
    image_path VARCHAR(255)
);

-- Insert a sample record for testing
INSERT INTO herb (common_name, latin_name, description) 
VALUES ('Peppermint', 'Mentha x piperita', 'A hybrid mint, a cross between watermint and spearmint.');
