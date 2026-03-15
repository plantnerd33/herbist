-- Seed data for supporting tables

-- Constituents
INSERT IGNORE INTO constituents (name) VALUES 
('Alkaloids'), ('Anthraquinones'), ('Bitters'), ('Carbohydrates'), ('Cardiac Glycosides'), 
('Coumarins'), ('Flavonoids'), ('Glycosides'), ('Minerals'), ('Mucilage'), 
('Phenols'), ('Polysaccharides'), ('Resins'), ('Saponins'), ('Tannins'), 
('Terpenes'), ('Vitamins'), ('Volatile Oils'), ('Salicylates'), ('Phytosterols');

-- Actions
INSERT IGNORE INTO actions (name) VALUES 
('Adaptogen'), ('Alterative'), ('Analgesic'), ('Anti-inflammatory'), ('Antibacterial'), 
('Antifungal'), ('Antispasmodic'), ('Antiviral'), ('Astringent'), ('Bitter'), 
('Carminative'), ('Cholagogue'), ('Demulcent'), ('Diaphoretic'), ('Diuretic'), 
('Emmenagogue'), ('Expectorant'), ('Galactagogue'), ('Hepatic'), ('Hypotensive'), 
('Immunomodulator'), ('Laxative'), ('Lymphatic'), ('Nervine'), ('Sedative'), 
('Stimulant'), ('Tonic'), ('Vulnerary');

-- Energetics
INSERT IGNORE INTO energetics (name) VALUES 
('Hot'), ('Warm'), ('Neutral'), ('Cool'), ('Cold'), 
('Dry'), ('Moist'), ('Damp'), 
('Toning'), ('Relaxing'), ('Constricting'), ('Diffusive');

-- Indications
INSERT IGNORE INTO indications (name) VALUES 
('Acne'), ('Allergies'), ('Anxiety'), ('Arthritis'), ('Asthma'), 
('Bloating'), ('Bronchitis'), ('Burns'), ('Colds'), ('Colic'), 
('Constipation'), ('Cough'), ('Depression'), ('Diarrhea'), ('Eczema'), 
('Fatigue'), ('Fever'), ('Flu'), ('Gas'), ('Headache'), 
('Heartburn'), ('High Blood Pressure'), ('Indigestion'), ('Inflammation'), ('Insomnia'), 
('Menopause'), ('Migraine'), ('Nausea'), ('Pain'), ('PMS'), 
('Psoriasis'), ('Sore Throat'), ('Stress'), ('UTIs'), ('Wounds');

-- Plant Families
INSERT IGNORE INTO plantfamily (name) VALUES 
('Acanthaceae'), ('Amaranthaceae'), ('Amaryllidaceae'), ('Apiaceae'), ('Apocynaceae'), 
('Araliaceae'), ('Asteraceae'), ('Berberidaceae'), ('Boraginaceae'), ('Brassicaceae'), 
('Campanulaceae'), ('Caprifoliaceae'), ('Caryophyllaceae'), ('Ericaceae'), ('Fabaceae'), 
('Gentianaceae'), ('Geraniaceae'), ('Lamiaceae'), ('Liliaceae'), ('Malvaceae'), 
('Papaveraceae'), ('Plantaginaceae'), ('Polygonaceae'), ('Ranunculaceae'), ('Rosaceae'), 
('Rubiaceae'), ('Rutaceae'), ('Scrophulariaceae'), ('Solanaceae'), ('Urticaceae'), 
('Verbenaceae'), ('Zingiberaceae');

-- Body Systems
INSERT IGNORE INTO bodysystems (name) VALUES 
('Cardiovascular System'), ('Digestive System'), ('Endocrine System'), ('Immune System'), 
('Integumentary System'), ('Lymphatic System'), ('Musculoskeletal System'), ('Nervous System'), 
('Reproductive System'), ('Respiratory System'), ('Urinary System');
