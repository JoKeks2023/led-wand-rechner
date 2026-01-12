-- Seed-Daten für LED Brands und Models
-- Führe diese Queries nach der DDL aus

-- INFIILED (Priorität 1)
INSERT INTO led_brands (name, description, country, website)
VALUES (
  'Infiiled',
  'Leading manufacturer of high-quality LED displays for both indoor and outdoor applications',
  'China',
  'https://www.infiiled.com'
);

-- Infiiled Models
INSERT INTO led_models (brand_id, model_name, pixel_pitch_mm, color_type, wattage_per_led_ma, price_per_unit_eur, specs_json)
SELECT id, 'CF2.5', 2.5, 'RGB', 60, 450, 
  '{"brightness_cd_m2": 800, "refresh_rate_hz": 3840, "module_size_mm": "320x160", "module_leds": 2048}'::jsonb
FROM led_brands WHERE name = 'Infiiled'
UNION ALL
SELECT id, 'CF2.5', 2.5, 'RGBW', 80, 550,
  '{"brightness_cd_m2": 950, "refresh_rate_hz": 3840, "module_size_mm": "320x160", "module_leds": 2048}'::jsonb
FROM led_brands WHERE name = 'Infiiled'
UNION ALL
SELECT id, 'CF4', 4.0, 'RGB', 40, 280,
  '{"brightness_cd_m2": 600, "refresh_rate_hz": 1920, "module_size_mm": "320x160", "module_leds": 800}'::jsonb
FROM led_brands WHERE name = 'Infiiled'
UNION ALL
SELECT id, 'CF4', 4.0, 'RGBW', 55, 350,
  '{"brightness_cd_m2": 750, "refresh_rate_hz": 1920, "module_size_mm": "320x160", "module_leds": 800}'::jsonb
FROM led_brands WHERE name = 'Infiiled'
UNION ALL
SELECT id, 'CF5', 5.0, 'RGB', 30, 200,
  '{"brightness_cd_m2": 500, "refresh_rate_hz": 1280, "module_size_mm": "320x160", "module_leds": 512}'::jsonb
FROM led_brands WHERE name = 'Infiiled'
UNION ALL
SELECT id, 'CF5', 5.0, 'RGBW', 42, 280,
  '{"brightness_cd_m2": 650, "refresh_rate_hz": 1280, "module_size_mm": "320x160", "module_leds": 512}'::jsonb
FROM led_brands WHERE name = 'Infiiled'
UNION ALL
SELECT id, 'CF6', 6.0, 'RGB', 25, 180,
  '{"brightness_cd_m2": 450, "refresh_rate_hz": 960, "module_size_mm": "320x160", "module_leds": 355}'::jsonb
FROM led_brands WHERE name = 'Infiiled'
UNION ALL
SELECT id, 'CF6', 6.0, 'RGBW', 35, 250,
  '{"brightness_cd_m2": 580, "refresh_rate_hz": 960, "module_size_mm": "320x160", "module_leds": 355}'::jsonb
FROM led_brands WHERE name = 'Infiiled'
UNION ALL
SELECT id, 'CF8', 8.0, 'RGB', 18, 140,
  '{"brightness_cd_m2": 400, "refresh_rate_hz": 720, "module_size_mm": "320x160", "module_leds": 200}'::jsonb
FROM led_brands WHERE name = 'Infiiled'
UNION ALL
SELECT id, 'CF8', 8.0, 'RGBW', 26, 200,
  '{"brightness_cd_m2": 520, "refresh_rate_hz": 720, "module_size_mm": "320x160", "module_leds": 200}'::jsonb
FROM led_brands WHERE name = 'Infiiled';

-- Model Variants für CF Models (RGB/RGBW)
INSERT INTO model_variants (model_id, variant_name, specific_specs_json)
SELECT id, 'RGB', '{"color_channels": 3, "power_multiplier": 1.0}'::jsonb
FROM led_models WHERE model_name LIKE 'CF%' AND color_type = 'RGB' LIMIT 5
UNION ALL
SELECT id, 'RGBW', '{"color_channels": 4, "power_multiplier": 1.3}'::jsonb
FROM led_models WHERE model_name LIKE 'CF%' AND color_type = 'RGBW' LIMIT 5;

-- WEITERE LED HERSTELLER (10+ Marken)

-- NOVA (China)
INSERT INTO led_brands (name, description, country, website)
VALUES (
  'Nova',
  'Professional LED display manufacturer focusing on small pitch indoor displays',
  'China',
  'https://www.novaled.cn'
);

INSERT INTO led_models (brand_id, model_name, pixel_pitch_mm, color_type, wattage_per_led_ma, price_per_unit_eur, specs_json)
SELECT id, 'NovaStar-P1.25', 1.25, 'RGB', 90, 600,
  '{"brightness_cd_m2": 1000, "refresh_rate_hz": 7680, "module_size_mm": "250x150"}'::jsonb
FROM led_brands WHERE name = 'Nova'
UNION ALL
SELECT id, 'NovaStar-P2', 2.0, 'RGB', 65, 420,
  '{"brightness_cd_m2": 850, "refresh_rate_hz": 5120, "module_size_mm": "320x160"}'::jsonb
FROM led_brands WHERE name = 'Nova'
UNION ALL
SELECT id, 'NovaStar-P3', 3.0, 'RGB', 45, 300,
  '{"brightness_cd_m2": 700, "refresh_rate_hz": 3200, "module_size_mm": "320x160"}'::jsonb
FROM led_brands WHERE name = 'Nova';

-- LINSN (China)
INSERT INTO led_brands (name, description, country, website)
VALUES (
  'Linsn',
  'Leader in LED display control and processing technology',
  'China',
  'https://www.linsn.com'
);

INSERT INTO led_models (brand_id, model_name, pixel_pitch_mm, color_type, wattage_per_led_ma, price_per_unit_eur, specs_json)
SELECT id, 'LS-IM', 2.5, 'RGB', 55, 380,
  '{"brightness_cd_m2": 800, "refresh_rate_hz": 3840, "module_size_mm": "256x128"}'::jsonb
FROM led_brands WHERE name = 'Linsn'
UNION ALL
SELECT id, 'LS-OM', 3.0, 'RGB', 40, 280,
  '{"brightness_cd_m2": 700, "refresh_rate_hz": 2560, "module_size_mm": "320x160"}'::jsonb
FROM led_brands WHERE name = 'Linsn';

-- UNILUMIN (China)
INSERT INTO led_brands (name, description, country, website)
VALUES (
  'Unilumin',
  'Advanced LED display solutions for professional applications',
  'China',
  'https://www.unilumin.com'
);

INSERT INTO led_models (brand_id, model_name, pixel_pitch_mm, color_type, wattage_per_led_ma, price_per_unit_eur, specs_json)
SELECT id, 'UliStar-UMS', 2.5, 'RGB', 60, 390,
  '{"brightness_cd_m2": 850, "refresh_rate_hz": 3840, "module_size_mm": "320x160"}'::jsonb
FROM led_brands WHERE name = 'Unilumin'
UNION ALL
SELECT id, 'UliStar-UMS', 3.91, 'RGB', 35, 250,
  '{"brightness_cd_m2": 700, "refresh_rate_hz": 1920, "module_size_mm": "256x128"}'::jsonb
FROM led_brands WHERE name = 'Unilumin';

-- ROE (Italy/USA)
INSERT INTO led_brands (name, description, country, website)
VALUES (
  'ROE Visual',
  'Premium LED solutions for rental and installed applications',
  'Italy',
  'https://www.roevisual.com'
);

INSERT INTO led_models (brand_id, model_name, pixel_pitch_mm, color_type, wattage_per_led_ma, price_per_unit_eur, specs_json)
SELECT id, 'GEMINI', 2.6, 'RGB', 85, 520,
  '{"brightness_cd_m2": 950, "refresh_rate_hz": 5760, "module_size_mm": "500x500"}'::jsonb
FROM led_brands WHERE name = 'ROE Visual'
UNION ALL
SELECT id, 'VANISH', 1.27, 'RGB', 120, 750,
  '{"brightness_cd_m2": 1200, "refresh_rate_hz": 9600, "module_size_mm": "400x300"}'::jsonb
FROM led_brands WHERE name = 'ROE Visual';

-- BARCO (Belgium)
INSERT INTO led_brands (name, description, country, website)
VALUES (
  'Barco',
  'High-performance LED visualization solutions',
  'Belgium',
  'https://www.barco.com'
);

INSERT INTO led_models (brand_id, model_name, pixel_pitch_mm, color_type, wattage_per_led_ma, price_per_unit_eur, specs_json)
SELECT id, 'NovaLED-1000', 4.0, 'RGB', 48, 350,
  '{"brightness_cd_m2": 750, "refresh_rate_hz": 1920, "module_size_mm": "320x180"}'::jsonb
FROM led_brands WHERE name = 'Barco';

-- PIXELFLY (Canada)
INSERT INTO led_brands (name, description, country, website)
VALUES (
  'Pixelfly',
  'Custom LED display solutions for unique applications',
  'Canada',
  'https://www.pixelfly.ca'
);

INSERT INTO led_models (brand_id, model_name, pixel_pitch_mm, color_type, wattage_per_led_ma, price_per_unit_eur, specs_json)
SELECT id, 'PF-XL', 3.5, 'RGB', 45, 310,
  '{"brightness_cd_m2": 700, "refresh_rate_hz": 2560, "module_size_mm": "300x150"}'::jsonb
FROM led_brands WHERE name = 'Pixelfly';

-- DAKTRONICS (USA)
INSERT INTO led_brands (name, description, country, website)
VALUES (
  'Daktronics',
  'Full-service LED display solutions and systems integration',
  'USA',
  'https://www.daktronics.com'
);

INSERT INTO led_models (brand_id, model_name, pixel_pitch_mm, color_type, wattage_per_led_ma, price_per_unit_eur, specs_json)
SELECT id, 'SIGMA-LX', 4.75, 'RGB', 32, 220,
  '{"brightness_cd_m2": 600, "refresh_rate_hz": 1280, "module_size_mm": "400x200"}'::jsonb
FROM led_brands WHERE name = 'Daktronics';

-- WATCHFIRE (USA)
INSERT INTO led_brands (name, description, country, website)
VALUES (
  'Watchfire',
  'LED display systems for outdoor and signage applications',
  'USA',
  'https://www.watchfiresigns.com'
);

INSERT INTO led_models (brand_id, model_name, pixel_pitch_mm, color_type, wattage_per_led_ma, price_per_unit_eur, specs_json)
SELECT id, 'HD-Pro', 5.95, 'RGB', 25, 180,
  '{"brightness_cd_m2": 500, "refresh_rate_hz": 960, "module_size_mm": "320x160"}'::jsonb
FROM led_brands WHERE name = 'Watchfire';

-- LEYARD (USA/China)
INSERT INTO led_brands (name, description, country, website)
VALUES (
  'Leyard',
  'Global leader in advanced display technology',
  'USA',
  'https://www.leyard.com'
);

INSERT INTO led_models (brand_id, model_name, pixel_pitch_mm, color_type, wattage_per_led_ma, price_per_unit_eur, specs_json)
SELECT id, 'NPU2.5', 2.5, 'RGB', 65, 400,
  '{"brightness_cd_m2": 850, "refresh_rate_hz": 3840, "module_size_mm": "320x160"}'::jsonb
FROM led_brands WHERE name = 'Leyard'
UNION ALL
SELECT id, 'NPU3.9', 3.9, 'RGB', 40, 280,
  '{"brightness_cd_m2": 700, "refresh_rate_hz": 1920, "module_size_mm": "320x160"}'::jsonb
FROM led_brands WHERE name = 'Leyard';
