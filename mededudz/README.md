# mededudz - Plateforme éducative pour le concours de résidanat

mededudz est une plateforme éducative complète conçue pour aider les étudiants en médecine à préparer le concours de résidanat à Constantine, en Algérie.

## Fonctionnalités

- 📚 Cours structurés par matière
- 📝 Examens pratiques et simulacres
- 👥 Groupes d'étude collaboratifs
- 💬 Forum communautaire
- 📊 Tableau de bord de progression
- 🎯 Parcours d'apprentissage personnalisé

## Technologies utilisées

- **Frontend**: Next.js 13+ (App Router), React, TypeScript
- **Styling**: Tailwind CSS
- **Base de données**: Supabase (PostgreSQL)
- **Authentification**: Supabase Auth avec @supabase/ssr
- **Déploiement**: Vercel

## Installation

### Prérequis

- Node.js 18+ 
- npm ou yarn
- Un compte Supabase

### Configuration

1. Clonez ce dépôt
   \`\`\`bash
   git clone https://github.com/votre-username/mededudz.git
   cd mededudz
   \`\`\`

2. Installez les dépendances
   \`\`\`bash
   npm install
   \`\`\`

3. Configurez Supabase
   - Créez un nouveau projet sur [Supabase](https://supabase.com)
   - Exécutez le script SQL dans \`supabase/migrations/20230501000000_initial_schema.sql\` dans l'éditeur SQL de Supabase
   - Copiez les informations de votre projet Supabase (URL et clés)

4. Configurez les variables d'environnement
   - Copiez le fichier \`.env.local.example\` vers \`.env.local\`
   - Remplacez les valeurs par celles de votre projet Supabase

5. Lancez le serveur de développement
   \`\`\`bash
   npm run dev
   \`\`\`

6. Ouvrez [http://localhost:3000](http://localhost:3000) dans votre navigateur

## Déploiement sur Vercel

1. Poussez votre code vers un dépôt Git (GitHub, GitLab, etc.)

2. Connectez votre compte Vercel à votre dépôt Git

3. Configurez les variables d'environnement dans Vercel:
   - \`NEXT_PUBLIC_SUPABASE_URL\`
   - \`NEXT_PUBLIC_SUPABASE_ANON_KEY\`
   - \`SUPABASE_SERVICE_ROLE_KEY\`
   - \`NEXTAUTH_URL\`
   - \`NEXTAUTH_SECRET\`

4. Déployez votre application

## Structure du projet

\`\`\`
mededudz/
├── src/
│   ├── app/                 # Next.js App Router
│   │   ├── auth/           # Pages d'authentification
│   │   ├── courses/        # Pages des cours
│   │   ├── exams/          # Pages des examens
│   │   ├── forum/          # Pages du forum
│   │   ├── groups/         # Pages des groupes d'étude
│   │   ├── dashboard/      # Tableau de bord
│   │   ├── profile/        # Profil utilisateur
│   │   ├── api/            # Routes API
│   │   ├── layout.tsx      # Layout principal
│   │   └── page.tsx        # Page d'accueil
│   ├── components/         # Composants React
│   │   ├── ui/             # Composants UI de base
│   │   ├── layout/         # Composants de layout
│   │   └── features/       # Composants fonctionnels
│   ├── lib/                # Utilitaires et configurations
│   │   ├── supabase.ts     # Client Supabase
│   │   └── utils.ts        # Fonctions utilitaires
│   ├── hooks/              # Hooks personnalisés
│   ├── types/              # Définitions de types TypeScript
│   └── store/              # État global (si nécessaire)
├── supabase/
│   └── migrations/         # Scripts de migration de la BD
├── public/                 # Fichiers statiques
├── tailwind.config.js      # Configuration Tailwind CSS
├── vercel.json            # Configuration Vercel
└── README.md              # Ce fichier
\`\`\`

## Contribution

Les contributions sont les bienvenues ! Veuillez vous référer à notre [guide de contribution](CONTRIBUTING.md) pour plus d'informations.

## Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## Contact

Pour toute question ou suggestion, veuillez nous contacter à l'adresse suivante : contact@mededudz.com
