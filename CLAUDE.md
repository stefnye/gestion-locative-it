# CLAUDE.md — Gestion Locative Self-Hosted

## Contexte projet

Plateforme de gestion locative self-hosted pour un T2 + garage VEFA à Lieusaint (77), détenu via une SCI à l'IR sous dispositif LLI (Logement Locatif Intermédiaire). L'objectif est d'automatiser la comptabilité, la génération de documents, le suivi locataire et les obligations fiscales.

## Infrastructure

- **Hôte** : HP EliteDesk 800 G1 DM — Debian 13
- **Orchestration** : Docker Compose
- **Reverse proxy** : Traefik v3, wildcard `*.homelab.local`, HTTPS
- **DNS local** : Pi-hole / Adguard Home
- **Automatisation** : n8n (déjà en place)
- **Notifications** : Telegram Bot (déjà en place)

## Stack applicative

| Service | Image Docker | Rôle | Port interne |
|---|---|---|---|
| Firefly III | `fireflyiii/core` | Comptabilité (revenus, dépenses, catégories fiscales) | 8080 |
| Firefly Data Importer | `fireflyiii/data-importer` | Import bancaire (CSV / Nordigen) | 8081 |
| Paperless-ngx | `ghcr.io/paperless-ngx/paperless-ngx` | GED, OCR, archivage docs (baux, factures, diagnostics) | 8000 |
| NocoDB | `nocodb/nocodb` | Base de données locative (locataires, baux, échéances) | 8090 |
| Vikunja | `vikunja/vikunja` | Kanban maintenance / tâches | 3456 |
| PostgreSQL | `postgres:16` | BDD partagée (Firefly, Paperless) | 5432 |
| Redis | `redis:7` | Cache Paperless-ngx | 6379 |

Tous les services sont sur le réseau Docker `gestion-locative` et routés par Traefik via labels.

## Structure du repo

```
gestion-locative/
├── CLAUDE.md                    # Ce fichier
├── docker-compose.yml           # Stack complète
├── .env                         # Variables d'environnement (secrets, tokens)
├── .env.example                 # Template .env sans secrets
├── traefik/
│   └── dynamic/
│       └── gestion-locative.yml # Config Traefik si fichier séparé
├── firefly/
│   └── .env                     # Config spécifique Firefly
├── paperless/
│   ├── consume/                 # Dossier d'import auto Paperless
│   └── export/                  # Dossier d'export
├── nocodb/
│   └── seed.sql                 # Seed du modèle de données (optionnel)
├── templates/
│   ├── quittance.typ            # Template Typst quittance de loyer
│   ├── appel-loyer.typ          # Template Typst appel de loyer
│   ├── revision-irl.typ         # Template Typst lettre révision IRL
│   └── recap-fiscal.typ         # Template Typst récap fiscal annuel
├── n8n/
│   └── workflows/
│       ├── wf01-detection-loyer.json
│       ├── wf02-quittance.json
│       ├── wf03-revision-irl.json
│       ├── wf04-rappels-echeances.json
│       ├── wf05-export-fiscal.json
│       └── wf06-maintenance.json
├── scripts/
│   ├── backup.sh                # Backup volumes Docker
│   └── restore.sh               # Restore depuis backup
└── docs/
    ├── architecture.md          # Schéma d'architecture
    ├── modele-donnees.md        # Détail des tables NocoDB
    └── fiscalite-sci-ir.md      # Notes fiscales SCI IR / LLI
```

## Modèle de données NocoDB

### Table `biens`
- `id` (PK), `adresse`, `type` (T2, garage), `surface_m2`, `etage`
- `date_livraison`, `numero_lot`, `syndic`, `ref_cadastrale`
- `loyer_initial_hc`, `charges_provisions`, `depot_garantie`

### Table `locataires`
- `id` (PK), `nom`, `prenom`, `email`, `telephone`
- `date_entree`, `date_sortie`, `garant_type` (Visale | personne_physique)
- `numero_visale`, `bien_id` (FK → biens)

### Table `baux`
- `id` (PK), `bien_id` (FK), `locataire_id` (FK)
- `date_debut`, `date_fin`, `loyer_hc`, `charges`
- `indice_irl_ref`, `type_bail` (LLI | classique)
- `date_prochaine_revision`, `statut` (actif | terminé)

### Table `paiements`
- `id` (PK), `bail_id` (FK), `mois` (YYYY-MM), `montant_attendu`, `montant_recu`
- `date_reception`, `quittance_generee` (bool), `ref_firefly` (ID transaction Firefly)

### Table `echeances`
- `id` (PK), `type` (assurance_pno | taxe_fonciere | ag_copro | visale | declaration_2072 | declaration_2042)
- `date_echeance`, `recurrence` (annuelle | mensuelle | ponctuelle)
- `statut` (a_venir | fait), `notes`

### Table `maintenance`
- `id` (PK), `bien_id` (FK), `description`, `date_signalement`
- `priorite` (basse | moyenne | haute | urgente)
- `statut` (nouveau | en_cours | resolu), `cout`, `facture_ref`

## Workflows n8n

### WF-01 : Détection encaissement loyer
- **Trigger** : cron quotidien ou webhook bancaire
- **Logique** : appel API Firefly III → vérifie si transaction loyer du mois existe
- **Si reçu** : déclenche WF-02 (génération quittance)
- **Si absent à J+5** : notification Telegram "Loyer non reçu"

### WF-02 : Génération quittance
- **Input** : données locataire + bail depuis NocoDB API
- **Traitement** : compile template `quittance.typ` via Typst CLI
- **Output** : PDF → envoi mail/Telegram au locataire + upload Paperless-ngx API + maj NocoDB `quittance_generee = true`

### WF-03 : Révision annuelle IRL
- **Trigger** : cron annuel (date anniversaire bail)
- **Logique** : scrape indice IRL depuis INSEE, calcule nouveau loyer `ancien × (nouvel_IRL / ancien_IRL)`
- **Actions** : met à jour NocoDB (bail.loyer_hc, bail.indice_irl_ref), génère lettre révision (Typst), alerte Telegram

### WF-04 : Rappels échéances
- **Trigger** : cron hebdomadaire (lundi 9h)
- **Logique** : requête NocoDB table `echeances` WHERE date_echeance BETWEEN today AND today+30
- **Actions** : notification Telegram groupée avec liste des échéances à venir

### WF-05 : Export fiscal annuel
- **Trigger** : cron annuel (1er mars)
- **Logique** : agrège transactions Firefly III par catégorie (revenus fonciers, charges déductibles, intérêts emprunt, assurances)
- **Output** : PDF récapitulatif pour déclaration 2072 (SCI) et 2042 (IRPP)

### WF-06 : Demande maintenance locataire
- **Trigger** : formulaire n8n ou NocoDB form
- **Actions** : crée entrée NocoDB table `maintenance`, crée tâche Vikunja, notification Telegram

## Conventions de code

- **Langue du code** : anglais (variables, fonctions, commentaires techniques)
- **Langue du contenu** : français (templates, labels NocoDB, messages Telegram, docs)
- **Docker** : un service = un conteneur, volumes nommés, réseau dédié `gestion-locative`
- **Secrets** : jamais en dur, toujours via `.env` (listé dans `.gitignore`)
- **Templates Typst** : variables passées en CLI (`--input key=value`)
- **Workflows n8n** : exportés en JSON dans `n8n/workflows/`, nommés `wfXX-nom.json`
- **Scripts bash** : `set -euo pipefail`, logs horodatés

## Catégories Firefly III

Les catégories suivantes doivent être créées pour le suivi fiscal SCI IR :

**Revenus** : `Loyer HC`, `Charges locatives récupérées`

**Charges déductibles** : `Intérêts emprunt`, `Assurance PNO`, `Assurance emprunteur`, `Taxe foncière`, `Charges copro non récupérables`, `Frais de gestion`, `Travaux déductibles`, `Frais de comptabilité`

**Non déductible** : `Remboursement capital`, `Dépôt de garantie`

## Contexte fiscal

- **Structure** : SCI à l'IR → revenus fonciers au réel (déclaration 2072 + report 2042)
- **Dispositif** : LLI (Logement Locatif Intermédiaire) — plafonds de loyer et de ressources locataire — avantage fiscal spécifique via Loi de Finances 2025/2026 (Statut du Bailleur Privé / amendement Jeanbrun)
- **Charges déductibles** : intérêts d'emprunt, assurance PNO, assurance emprunteur, taxe foncière, charges copro non récupérables, frais de gestion, travaux
- **Garantie locataire** : Visale (compatible LLI)

## Commandes utiles

```bash
# Démarrer la stack
docker compose up -d

# Voir les logs
docker compose logs -f [service]

# Backup tous les volumes
./scripts/backup.sh

# Restore
./scripts/restore.sh /chemin/vers/backup.tar.gz

# Compiler une quittance Typst manuellement
typst compile templates/quittance.typ --input nom="Dupont" --input mois="2026-04" --input loyer="750" --input charges="50" output.pdf

# Exporter un workflow n8n
curl -X GET http://n8n.homelab.local/api/v1/workflows/{id} -H "X-N8N-API-KEY: $N8N_API_KEY" | jq > n8n/workflows/wfXX-nom.json
```

## Points d'attention

- Les plafonds de loyer LLI sont révisés annuellement → WF-03 doit aussi vérifier le plafond LLI en plus de l'IRL
- L'import bancaire Nordigen nécessite un renouvellement de consentement tous les 90 jours → ajouter un rappel dans WF-04
- Paperless-ngx consomme du CPU à l'import (OCR) → planifier les imports en heures creuses si besoin
- Les quittances ne doivent être envoyées que si le loyer est effectivement encaissé (obligation légale)
- Conserver les documents fiscaux 6 ans (délai de prescription) → configurer la rétention Paperless-ngx en conséquence
