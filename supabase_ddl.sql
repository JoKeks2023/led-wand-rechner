-- Supabase SQL DDL für LED Wand Rechner
-- Führe diese Queries in Supabase SQL Editor aus

-- 1. LED Brands Tabelle
CREATE TABLE led_brands (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  country VARCHAR(50),
  website VARCHAR(255),
  logo_url VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. LED Models Tabelle
CREATE TABLE led_models (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id UUID NOT NULL REFERENCES led_brands(id) ON DELETE CASCADE,
  model_name VARCHAR(100) NOT NULL,
  pixel_pitch_mm DECIMAL(5,2) NOT NULL,
  color_type VARCHAR(50) NOT NULL, -- RGB, RGBW, Full Color
  wattage_per_led_ma DECIMAL(8,2) NOT NULL, -- Milliamps
  price_per_unit_eur DECIMAL(10,2),
  specs_json JSONB, -- Additional specs
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(brand_id, model_name)
);

-- 3. Model Variants Tabelle
CREATE TABLE model_variants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES led_models(id) ON DELETE CASCADE,
  variant_name VARCHAR(100) NOT NULL, -- RGB, RGBW, etc.
  specific_specs_json JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(model_id, variant_name)
);

-- 4. Custom Models Tabelle (Benutzer-definierte Modelle)
CREATE TABLE custom_models (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  model_name VARCHAR(100) NOT NULL,
  brand_id_or_custom VARCHAR(100),
  specs_json JSONB NOT NULL,
  is_published BOOLEAN DEFAULT FALSE,
  is_private BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Community Models Tabelle (Veröffentlichte Community-Modelle)
CREATE TABLE community_models (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  original_custom_model_id UUID REFERENCES custom_models(id) ON DELETE SET NULL,
  model_name VARCHAR(100) NOT NULL,
  brand_name VARCHAR(100),
  specs_json JSONB NOT NULL,
  description TEXT,
  votes INTEGER DEFAULT 0,
  published_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  abuse_reports INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Projects Tabelle (Benutzer-Projekte)
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  selected_brand_id UUID REFERENCES led_brands(id) ON DELETE SET NULL,
  selected_model_id UUID REFERENCES led_models(id) ON DELETE SET NULL,
  selected_variant_id UUID REFERENCES model_variants(id) ON DELETE SET NULL,
  is_custom_model BOOLEAN DEFAULT FALSE,
  custom_model_id UUID REFERENCES custom_models(id) ON DELETE SET NULL,
  parameters_json JSONB NOT NULL, -- { width_mm, height_mm, led_distance_mm, ... }
  results_json JSONB, -- { ppi, resolution, total_power, cost, ... }
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Sync Metadata Tabelle (für Konflikt-Auflösung)
CREATE TABLE sync_metadata (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  entity_type VARCHAR(50), -- projects, custom_models
  entity_id UUID NOT NULL,
  last_sync_at TIMESTAMP WITH TIME ZONE,
  local_version INTEGER DEFAULT 0,
  cloud_version INTEGER DEFAULT 0,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Row Level Security (RLS) Policies

-- LED Brands: Public read-only
ALTER TABLE led_brands ENABLE ROW LEVEL SECURITY;
CREATE POLICY "led_brands_public_read" ON led_brands
  FOR SELECT USING (true);

-- LED Models: Public read-only
ALTER TABLE led_models ENABLE ROW LEVEL SECURITY;
CREATE POLICY "led_models_public_read" ON led_models
  FOR SELECT USING (true);

-- Model Variants: Public read-only
ALTER TABLE model_variants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "model_variants_public_read" ON model_variants
  FOR SELECT USING (true);

-- Custom Models: Owner only
ALTER TABLE custom_models ENABLE ROW LEVEL SECURITY;
CREATE POLICY "custom_models_owner_select" ON custom_models
  FOR SELECT USING (auth.uid() = user_id OR is_published = TRUE);
CREATE POLICY "custom_models_owner_insert" ON custom_models
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "custom_models_owner_update" ON custom_models
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "custom_models_owner_delete" ON custom_models
  FOR DELETE USING (auth.uid() = user_id);

-- Community Models: Public read
ALTER TABLE community_models ENABLE ROW LEVEL SECURITY;
CREATE POLICY "community_models_public_read" ON community_models
  FOR SELECT USING (true);
CREATE POLICY "community_models_insert" ON community_models
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Projects: Owner only
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "projects_owner_select" ON projects
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "projects_owner_insert" ON projects
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "projects_owner_update" ON projects
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "projects_owner_delete" ON projects
  FOR DELETE USING (auth.uid() = user_id);

-- Sync Metadata: Owner only
ALTER TABLE sync_metadata ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sync_metadata_owner_all" ON sync_metadata
  FOR ALL USING (auth.uid() = user_id);

-- Indexes für Performance
CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_projects_updated_at ON projects(updated_at);
CREATE INDEX idx_custom_models_user_id ON custom_models(user_id);
CREATE INDEX idx_led_models_brand_id ON led_models(brand_id);
CREATE INDEX idx_model_variants_model_id ON model_variants(model_id);
CREATE INDEX idx_community_models_published_at ON community_models(published_at);
CREATE INDEX idx_sync_metadata_user_id ON sync_metadata(user_id);
