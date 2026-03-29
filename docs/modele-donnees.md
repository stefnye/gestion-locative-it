# Modèle de données — NocoDB

## Schéma relationnel

```
biens 1──N locataires
biens 1──N baux
locataires 1──N baux
baux 1──N paiements
biens 1──N maintenance
```

## Tables

### `biens`

| Champ | Type | Description |
|---|---|---|
| `id` | PK, SERIAL | Identifiant unique |
| `adresse` | TEXT | Adresse complète du bien |
| `type` | VARCHAR(50) | T2, garage, studio, etc. |
| `surface_m2` | NUMERIC(6,2) | Surface en m² |
| `etage` | INTEGER | Étage |
| `date_livraison` | DATE | Date de livraison VEFA |
| `numero_lot` | VARCHAR(50) | Numéro de lot copropriété |
| `syndic` | VARCHAR(255) | Nom du syndic |
| `ref_cadastrale` | VARCHAR(100) | Référence cadastrale |
| `loyer_initial_hc` | NUMERIC(8,2) | Loyer initial hors charges |
| `charges_provisions` | NUMERIC(8,2) | Provisions pour charges |
| `depot_garantie` | NUMERIC(8,2) | Montant du dépôt de garantie |

### `locataires`

| Champ | Type | Description |
|---|---|---|
| `id` | PK, SERIAL | Identifiant unique |
| `nom` | VARCHAR(255) | Nom de famille |
| `prenom` | VARCHAR(255) | Prénom |
| `email` | VARCHAR(255) | Adresse e-mail |
| `telephone` | VARCHAR(20) | Numéro de téléphone |
| `date_entree` | DATE | Date d'entrée dans les lieux |
| `date_sortie` | DATE | Date de sortie (null si actif) |
| `garant_type` | VARCHAR(50) | Visale ou personne_physique |
| `numero_visale` | VARCHAR(100) | Numéro de dossier Visale |
| `bien_id` | FK → biens | Bien occupé |

### `baux`

| Champ | Type | Description |
|---|---|---|
| `id` | PK, SERIAL | Identifiant unique |
| `bien_id` | FK → biens | Bien concerné |
| `locataire_id` | FK → locataires | Locataire titulaire |
| `date_debut` | DATE | Début du bail |
| `date_fin` | DATE | Fin du bail |
| `loyer_hc` | NUMERIC(8,2) | Loyer hors charges actuel |
| `charges` | NUMERIC(8,2) | Provisions pour charges |
| `indice_irl_ref` | VARCHAR(50) | Indice IRL de référence |
| `type_bail` | VARCHAR(50) | LLI ou classique |
| `date_prochaine_revision` | DATE | Prochaine date de révision |
| `statut` | VARCHAR(50) | actif ou terminé |

### `paiements`

| Champ | Type | Description |
|---|---|---|
| `id` | PK, SERIAL | Identifiant unique |
| `bail_id` | FK → baux | Bail concerné |
| `mois` | VARCHAR(7) | Période au format YYYY-MM |
| `montant_attendu` | NUMERIC(8,2) | Loyer + charges attendus |
| `montant_recu` | NUMERIC(8,2) | Montant effectivement reçu |
| `date_reception` | DATE | Date de réception du paiement |
| `quittance_generee` | BOOLEAN | Quittance générée et envoyée |
| `ref_firefly` | VARCHAR(100) | ID de la transaction Firefly III |

### `echeances`

| Champ | Type | Description |
|---|---|---|
| `id` | PK, SERIAL | Identifiant unique |
| `type` | VARCHAR(100) | assurance_pno, taxe_fonciere, ag_copro, visale, declaration_2072, declaration_2042, renouvellement_nordigen |
| `date_echeance` | DATE | Date de l'échéance |
| `recurrence` | VARCHAR(50) | annuelle, mensuelle, ponctuelle, trimestrielle |
| `statut` | VARCHAR(50) | a_venir ou fait |
| `notes` | TEXT | Notes libres |

### `maintenance`

| Champ | Type | Description |
|---|---|---|
| `id` | PK, SERIAL | Identifiant unique |
| `bien_id` | FK → biens | Bien concerné |
| `description` | TEXT | Description du problème |
| `date_signalement` | DATE | Date du signalement |
| `priorite` | VARCHAR(50) | basse, moyenne, haute, urgente |
| `statut` | VARCHAR(50) | nouveau, en_cours, resolu |
| `cout` | NUMERIC(10,2) | Coût de l'intervention |
| `facture_ref` | VARCHAR(255) | Référence facture (Paperless) |
