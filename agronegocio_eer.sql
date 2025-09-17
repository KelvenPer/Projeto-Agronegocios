-- Agronegócio EER Diagram - Script MySQL
-- Criado para importação no MySQL Workbench ou execução direta
-- Autor: Kelven Silva (Projeto Exposição em Cristo)

-- ============================
-- 1) Fazendas
-- ============================
CREATE TABLE farms (
  farm_id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name           VARCHAR(120) NOT NULL,
  owner_name     VARCHAR(120),
  country        VARCHAR(80),
  state          VARCHAR(80),
  city           VARCHAR(80),
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_farm_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2) Talhões
CREATE TABLE fields (
  field_id       BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  farm_id        BIGINT UNSIGNED NOT NULL,
  code           VARCHAR(50) NOT NULL,
  area_ha        DECIMAL(10,2) NOT NULL,
  soil_type      VARCHAR(60),
  centroid_lat   DECIMAL(10,7),
  centroid_lng   DECIMAL(10,7),
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_fields_farm
    FOREIGN KEY (farm_id) REFERENCES farms(farm_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  UNIQUE KEY uk_field_farm_code (farm_id, code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3) Safras
CREATE TABLE seasons (
  season_id      BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name           VARCHAR(50) NOT NULL,
  start_date     DATE NOT NULL,
  end_date       DATE NOT NULL,
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_season_name (name),
  CHECK (start_date < end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4) Culturas
CREATE TABLE crops (
  crop_id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name           VARCHAR(80) NOT NULL,
  variety        VARCHAR(120),
  cycle_days     INT,
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_crop_name_variety (name, variety)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5) Plantios
CREATE TABLE plantings (
  planting_id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  field_id           BIGINT UNSIGNED NOT NULL,
  season_id          BIGINT UNSIGNED NOT NULL,
  crop_id            BIGINT UNSIGNED NOT NULL,
  sowing_date        DATE NOT NULL,
  seed_density_kg_ha DECIMAL(10,3),
  expected_yield_t_ha DECIMAL(10,3),
  irrigation_used    TINYINT(1) DEFAULT 0,
  notes              TEXT,
  created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_plantings_field
    FOREIGN KEY (field_id) REFERENCES fields(field_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_plantings_season
    FOREIGN KEY (season_id) REFERENCES seasons(season_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_plantings_crop
    FOREIGN KEY (crop_id) REFERENCES crops(crop_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6) Colheitas
CREATE TABLE harvests (
  harvest_id       BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  planting_id      BIGINT UNSIGNED NOT NULL,
  harvest_date     DATE NOT NULL,
  quantity_t       DECIMAL(12,3) NOT NULL,
  moisture_pct     DECIMAL(5,2),
  quality_grade    VARCHAR(40),
  destination_note VARCHAR(200),
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_harvests_planting
    FOREIGN KEY (planting_id) REFERENCES plantings(planting_id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7) Produtos
CREATE TABLE products (
  product_id     BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name           VARCHAR(120) NOT NULL,
  category       ENUM('INPUT','COMMODITY') NOT NULL,
  unit           ENUM('KG','L','TON','BAG','UNIT') NOT NULL,
  sku            VARCHAR(80),
  active         TINYINT(1) DEFAULT 1,
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_product_name_sku (name, sku)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8) Parceiros
CREATE TABLE counterparties (
  counterparty_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name            VARCHAR(160) NOT NULL,
  type            ENUM('SUPPLIER','BUYER','TRANSPORTER','OTHER') NOT NULL,
  tax_id          VARCHAR(30),
  email           VARCHAR(160),
  phone           VARCHAR(40),
  city            VARCHAR(80),
  state           VARCHAR(80),
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_counterparty_tax (tax_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9) Contratos
CREATE TABLE contracts (
  contract_id      BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  counterparty_id  BIGINT UNSIGNED NOT NULL,
  product_id       BIGINT UNSIGNED NOT NULL,
  type             ENUM('PURCHASE','SALE') NOT NULL,
  signed_date      DATE NOT NULL,
  delivery_start   DATE,
  delivery_end     DATE,
  price_per_unit   DECIMAL(14,4) NOT NULL,
  currency         VARCHAR(10) DEFAULT 'BRL',
  quantity_agreed  DECIMAL(14,3),
  status           ENUM('OPEN','PARTIAL','CLOSED','CANCELLED') DEFAULT 'OPEN',
  notes            TEXT,
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_contracts_counterparty
    FOREIGN KEY (counterparty_id) REFERENCES counterparties(counterparty_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_contracts_product
    FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10) Movimentações de estoque
CREATE TABLE stock_movements (
  movement_id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  product_id         BIGINT UNSIGNED NOT NULL,
  movement_type      ENUM('PURCHASE','SALE','CONSUMPTION','HARVEST_IN','ADJUSTMENT') NOT NULL,
  movement_date      DATETIME NOT NULL,
  quantity           DECIMAL(14,3) NOT NULL,
  unit_price         DECIMAL(14,4),
  contract_id        BIGINT UNSIGNED NULL,
  planting_id        BIGINT UNSIGNED NULL,
  location_label     VARCHAR(120),
  notes              VARCHAR(255),
  created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sm_product
    FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_sm_contract
    FOREIGN KEY (contract_id) REFERENCES contracts(contract_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_sm_planting
    FOREIGN KEY (planting_id) REFERENCES plantings(planting_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
