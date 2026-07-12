# Al Toupi - Restaurant Management Platform

**Al Toupi** est une application web moderne pour la gestion et la présentation d'un restaurant traditionnel en Aveyron.

## 🍽️ Aperçu

- **Vitrine publique** : site web responsive avec menu, galerie photo, horaires, contact avec carte
- **Pages légales** : mentions légales, politique de confidentialité, politique cookies (entièrement configurables)
- **Admin privé** : gestion du menu, photos, paramètres du site via interface web intuitive
- **Authentification** : accès admin sécurisé par email/mot de passe
- **Sécurité** : protections CSRF, SSL/TLS, paramètres forts, audit de sécurité complet

## 🛠️ Stack technique

- **Framework** : Rails 8.1.3
- **Serveur applicatif** : Puma
- **Base de données** : PostgreSQL
- **CSS/Design** : Tailwind CSS + Design System personnalisé
- **Stockage** : Active Storage (S3 ou local)
- **Tests** : RSpec + FactoryBot + Capybara
- **Qualité** : RuboCop + Brakeman + Bundler Audit
- **JS** : Importmap + Stimulus
- **Frontend** : ERB + Turbo

## 📋 Prérequis

- **Ruby** 3.3+
- **PostgreSQL** 14+
- **Node.js** 20+
- **Yarn** ou npm

## 🚀 Installation

### 1. Cloner le repository
```bash
git clone <repository-url>
cd altoupi
```

### 2. Installer les dépendances
```bash
bundle install
yarn install
```

### 3. Configurer les variables d'environnement
```bash
cp .env.example .env
# Éditer .env avec vos paramètres
```

### 4. Créer et initialiser la base de données
```bash
rails db:create
rails db:migrate
rails db:seed
```

## 💻 Développement local

### Démarrer le serveur
```bash
bin/dev
```
Accédez à l'application sur `http://localhost:3000`

### URLs de développement
- **Site public** : http://localhost:3000
- **Admin** : http://localhost:3000/admin (login: admin@altoupi.fr / admin1234)

## 🧪 Tests

### Exécuter la suite complète
```bash
bundle exec rspec
```

### Tests spécifiques
```bash
# Tests unitaires (modèles)
bundle exec rspec spec/models

# Tests request (contrôleurs)
bundle exec rspec spec/requests

# Tests système (E2E)
bundle exec rspec spec/system
```

### Couverture de test
L'application dispose d'une couverture complète (71 exemples RSpec, 0 défaillance) couvrant:
- ✅ Validations et associations de modèles
- ✅ Authentication et autorisations admin
- ✅ CRUD menu/photos/paramètres
- ✅ Rendu des pages publiques
- ✅ Sécurité (CSRF, paramètres forts)

## 🔒 Qualité et sécurité

### Vérifications automatisées
```bash
# RuboCop (style/lint)
bin/rubocop

# Brakeman (sécurité)
bin/brakeman

# Bundler Audit (dépendances vulnérables)
bin/bundler-audit
```

**Status** : ✅ Zéro violation, 0 vulnérabilité

## ⚙️ Configuration

### Pages légales
Les pages légales sont entièrement gérées via l'admin:
- **Mentions légales** → `/mentions-legales`
- **Politique de confidentialité** → `/politique-confidentialite`
- **Politique cookies** → `/politique-cookies`

Champs éditables:
- `legal_company_name` : Raison sociale
- `legal_director` : Directeur de publication
- `legal_host_name` : Nom hébergeur
- `legal_host_address` : Adresse hébergeur
- `legal_host_phone` : Téléphone hébergeur

### Paramètres du site
Tous les paramètres sont éditables via Admin → Paramètres:
- Adresse, téléphone, email
- Horaires d'ouverture
- Texte d'accueil
- Lien carte Google Maps
- Coordonnées réseaux sociaux
- Informations légales

## 📱 Routes publiques

| Route | Description |
|-------|-------------|
| `/` | Accueil avec galerie |
| `/carte` | Menu avec catégories |
| `/galerie` | Galerie complète |
| `/contact` | Coordonnées + carte |
| `/mentions-legales` | Mentions légales |
| `/politique-confidentialite` | Politique confidentialité |
| `/politique-cookies` | Politique cookies |

## 🔐 Admin

**Accès** : `/admin/login`

### Fonctionnalités
- 📝 **Paramètres** : Gestion de tous les contenus du site
- 🍽️ **Carte** : Catégories et plats avec prix/descriptions
- 📸 **Galerie** : Upload et gestion des photos
- 👤 **Profil** : Modification du mot de passe admin

Authentification par session sécurisée, CSRF protection activée.

## 🌐 Production

### Variables d'environnement essentielles
```env
RAILS_ENV=production
RAILS_MASTER_KEY=<votre-clé-secrète>

# SSL & Sécurité
FORCE_SSL=true
ASSUME_SSL=true

# Base de données
DATABASE_URL=postgresql://user:pass@host:5432/altoupi_prod

# Email
SMTP_HOST=your-smtp-host
SMTP_PORT=587
SMTP_USER=your-email
SMTP_PASSWORD=your-password

# Stockage S3 (optionnel)
AWS_BUCKET=altoupi-prod
AWS_REGION=eu-west-1
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...

# Hosts
APP_HOST=altoupi.fr
MAIL_HOST=altoupi.fr
```

### Déploiement
```bash
# Assets
rails assets:precompile

# Base de données
rails db:migrate

# Démarrer Puma
bundle exec puma -e production
```

### Health check
Un endpoint santé est disponible à `/up` pour les load balancers. L'affichage d'un écran vert sur cette URL est normal et indique que l'application répond correctement.

## 📊 Architecture

```
altoupi/
├── app/
│   ├── controllers/     # Admin + Pages (publiques)
│   ├── models/          # Dish, DishCategory, Photo, Setting, AdminUser
│   ├── views/           # Admin + Pages publiques
│   ├── helpers/         # setting_value helper
│   └── assets/          # CSS, images, JS
├── config/
│   ├── routes.rb        # Routing
│   ├── environments/    # Dev, test, prod
│   └── initializers/    # Sécurité, storage, CSP
├── db/
│   ├── migrate/         # Migrations
│   └── seeds.rb         # Données initiales
├── spec/
│   ├── models/          # Model specs
│   ├── requests/        # Request specs
│   ├── system/          # E2E specs
│   └── factories/       # FactoryBot factories
└── public/              # Static errors, robots.txt
```

## 🐛 Troubleshooting

### Erreur de base de données
```bash
rails db:drop db:create db:migrate db:seed
```

### Erreur d'authentification admin
```bash
# Réinitialiser le mot de passe
rails runner 'AdminUser.first.update(password: "newpassword", password_confirmation: "newpassword")'
```

### Cache bloqué
```bash
rails tmp:cache:clear
```

## 📞 Support

Pour toute question ou problème, contactez : contact@altoupi.fr

## 📄 Licence

Propriété d'Al Toupi. Tous droits réservés.

---

**Dernière mise à jour** : Juin 2026  
**Version** : 1.0.0  
**Status** : Production-ready ✅
