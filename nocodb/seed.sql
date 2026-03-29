-- NocoDB Seed — Modèle de données gestion locative
-- Note: NocoDB creates its own schema. This seed provides the initial
-- PostgreSQL tables that can be imported into NocoDB as external data sources,
-- or used as reference for manual table creation via the NocoDB UI.

-- ============================================================================
-- Table: biens
-- ============================================================================
CREATE TABLE IF NOT EXISTS biens (
    id SERIAL PRIMARY KEY,
    adresse TEXT NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('T2', 'garage', 'studio', 'T1', 'T3', 'T4', 'parking', 'autre')),
    surface_m2 NUMERIC(6,2),
    etage INTEGER,
    date_livraison DATE,
    numero_lot VARCHAR(50),
    syndic VARCHAR(255),
    ref_cadastrale VARCHAR(100),
    loyer_initial_hc NUMERIC(8,2),
    charges_provisions NUMERIC(8,2),
    depot_garantie NUMERIC(8,2),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- Table: locataires
-- ============================================================================
CREATE TABLE IF NOT EXISTS locataires (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    prenom VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    telephone VARCHAR(20),
    date_entree DATE,
    date_sortie DATE,
    garant_type VARCHAR(50) CHECK (garant_type IN ('Visale', 'personne_physique')),
    numero_visale VARCHAR(100),
    bien_id INTEGER REFERENCES biens(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- Table: baux
-- ============================================================================
CREATE TABLE IF NOT EXISTS baux (
    id SERIAL PRIMARY KEY,
    bien_id INTEGER NOT NULL REFERENCES biens(id),
    locataire_id INTEGER NOT NULL REFERENCES locataires(id),
    date_debut DATE NOT NULL,
    date_fin DATE,
    loyer_hc NUMERIC(8,2) NOT NULL,
    charges NUMERIC(8,2) NOT NULL DEFAULT 0,
    indice_irl_ref VARCHAR(50),
    type_bail VARCHAR(50) NOT NULL CHECK (type_bail IN ('LLI', 'classique')) DEFAULT 'LLI',
    date_prochaine_revision DATE,
    statut VARCHAR(50) NOT NULL CHECK (statut IN ('actif', 'terminé')) DEFAULT 'actif',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- Table: paiements
-- ============================================================================
CREATE TABLE IF NOT EXISTS paiements (
    id SERIAL PRIMARY KEY,
    bail_id INTEGER NOT NULL REFERENCES baux(id),
    mois VARCHAR(7) NOT NULL, -- YYYY-MM
    montant_attendu NUMERIC(8,2) NOT NULL,
    montant_recu NUMERIC(8,2),
    date_reception DATE,
    quittance_generee BOOLEAN DEFAULT FALSE,
    ref_firefly VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- Table: echeances
-- ============================================================================
CREATE TABLE IF NOT EXISTS echeances (
    id SERIAL PRIMARY KEY,
    type VARCHAR(100) NOT NULL CHECK (type IN (
        'assurance_pno', 'taxe_fonciere', 'ag_copro',
        'visale', 'declaration_2072', 'declaration_2042',
        'renouvellement_nordigen', 'autre'
    )),
    date_echeance DATE NOT NULL,
    recurrence VARCHAR(50) CHECK (recurrence IN ('annuelle', 'mensuelle', 'ponctuelle', 'trimestrielle')),
    statut VARCHAR(50) NOT NULL CHECK (statut IN ('a_venir', 'fait')) DEFAULT 'a_venir',
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- Table: maintenance
-- ============================================================================
CREATE TABLE IF NOT EXISTS maintenance (
    id SERIAL PRIMARY KEY,
    bien_id INTEGER NOT NULL REFERENCES biens(id),
    description TEXT NOT NULL,
    date_signalement DATE NOT NULL DEFAULT CURRENT_DATE,
    priorite VARCHAR(50) NOT NULL CHECK (priorite IN ('basse', 'moyenne', 'haute', 'urgente')) DEFAULT 'moyenne',
    statut VARCHAR(50) NOT NULL CHECK (statut IN ('nouveau', 'en_cours', 'resolu')) DEFAULT 'nouveau',
    cout NUMERIC(10,2),
    facture_ref VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- Index for common queries
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_baux_statut ON baux(statut);
CREATE INDEX IF NOT EXISTS idx_paiements_mois ON paiements(mois);
CREATE INDEX IF NOT EXISTS idx_paiements_bail ON paiements(bail_id);
CREATE INDEX IF NOT EXISTS idx_echeances_date ON echeances(date_echeance);
CREATE INDEX IF NOT EXISTS idx_echeances_statut ON echeances(statut);
CREATE INDEX IF NOT EXISTS idx_maintenance_statut ON maintenance(statut);
CREATE INDEX IF NOT EXISTS idx_maintenance_bien ON maintenance(bien_id);
