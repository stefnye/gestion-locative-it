# Architecture — Gestion Locative

## Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                        Traefik v3                               │
│              Reverse Proxy — *.homelab.local (HTTPS)            │
└──────┬──────────┬──────────┬──────────┬──────────┬──────────────┘
       │          │          │          │          │
       ▼          ▼          ▼          ▼          ▼
  ┌─────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
  │Firefly  │ │Firefly │ │Paper-  │ │NocoDB  │ │Vikunja │
  │  III    │ │Import  │ │less-ngx│ │        │ │        │
  │ :8080   │ │ :8081  │ │ :8000  │ │ :8080  │ │ :3456  │
  └────┬────┘ └───┬────┘ └───┬────┘ └───┬────┘ └───┬────┘
       │          │          │          │          │
       ▼          ▼          ▼          ▼          ▼
  ┌─────────────────────────────────────────────────────┐
  │              PostgreSQL 16 (:5432)                   │
  │    firefly | paperless | nocodb | vikunja            │
  └─────────────────────────────────────────────────────┘
                              │
                    ┌─────────┘
                    ▼
              ┌──────────┐
              │ Redis 7  │
              │  :6379   │
              │ (cache   │
              │ Paperless│
              └──────────┘

  ┌──────────────────────┐
  │        n8n           │ (déployé séparément)
  │   Automatisation     │
  │   6 workflows        │──── API calls ──▶ Firefly / NocoDB / Paperless / Vikunja
  └──────────────────────┘
           │
           ▼
  ┌──────────────────────┐
  │   Telegram Bot       │
  │   Notifications      │
  └──────────────────────┘
```

## Sous-domaines

| Service | URL |
|---|---|
| Firefly III | `https://firefly.homelab.local` |
| Firefly Data Importer | `https://firefly-import.homelab.local` |
| Paperless-ngx | `https://paperless.homelab.local` |
| NocoDB | `https://nocodb.homelab.local` |
| Vikunja | `https://vikunja.homelab.local` |

## Réseau Docker

Tous les services partagent le réseau `gestion-locative`. Traefik route le trafic via les labels Docker sur chaque service.

## Volumes

| Volume | Service | Contenu |
|---|---|---|
| `postgres_data` | PostgreSQL | Données de toutes les BDD |
| `redis_data` | Redis | Cache Paperless |
| `firefly_upload` | Firefly III | Pièces jointes transactions |
| `paperless_data` | Paperless-ngx | Index et configuration |
| `paperless_media` | Paperless-ngx | Documents archivés (OCR) |
| `nocodb_data` | NocoDB | Métadonnées NocoDB |
| `vikunja_data` | Vikunja | Fichiers tâches |

## Flux de données principaux

1. **Encaissement loyer** : Banque → Firefly III → n8n (WF-01) → détection → n8n (WF-02) → quittance PDF → Paperless-ngx + Telegram
2. **Révision IRL** : n8n (WF-03) → INSEE (IRL) → calcul → NocoDB (MAJ bail) + lettre révision PDF
3. **Rappels** : n8n (WF-04) → NocoDB (échéances) → Telegram
4. **Export fiscal** : n8n (WF-05) → Firefly III (transactions) → agrégation → PDF récap 2072/2042
5. **Maintenance** : Locataire → formulaire → n8n (WF-06) → NocoDB + Vikunja + Telegram
