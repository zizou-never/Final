#!/bin/bash

# Script de création d'une plateforme éducative pour le concours de résidanat Constantine
# Nom du projet: MedEduDz

echo "🚀 Création de la plateforme éducative MedEduDz pour le concours de résidanat Constantine..."

# Création du dossier principal
mkdir -p MedEduDz
cd MedEduDz

# Initialisation du projet Next.js
npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"

# Installation des dépendances supplémentaires
npm install @supabase/supabase-js @supabase/auth-helpers-nextjs @heroicons/react lucide-react react-hook-form @hookform/resolvers zod framer-motion react-hot-toast recharts date-fns

# Création de la structure des dossiers
mkdir -p src/components/ui src/components/layout src/components/features src/lib src/types src/app/api src/app/auth src/app/courses src/app/exams src/app/profile src/app/dashboard src/hooks src/store src/data

# Création des fichiers de configuration
cat > .env.local << EOF
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=YOUR_SUPABASE_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
SUPABASE_SERVICE_ROLE_KEY=YOUR_SUPABASE_SERVICE_ROLE_KEY

# NextAuth Configuration
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=YOUR_NEXTAUTH_SECRET
EOF

# Création du fichier de configuration Supabase
cat > src/lib/supabase.ts << EOF
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
EOF

# Création des types TypeScript
cat > src/types/index.ts << EOF
export interface User {
  id: string
  email: string
  full_name: string
  avatar_url?: string
  role: 'student' | 'teacher' | 'admin'
  created_at: string
}

export interface Course {
  id: string
  title: string
  description: string
  thumbnail_url?: string
  category: string
  teacher_id: string
  created_at: string
  updated_at: string
}

export interface Lesson {
  id: string
  title: string
  content: string
  video_url?: string
  course_id: string
  order: number
  duration?: number
  created_at: string
}

export interface Exam {
  id: string
  title: string
  description: string
  duration: number
  course_id?: string
  created_by: string
  created_at: string
  is_published: boolean
}

export interface Question {
  id: string
  content: string
  options: string[]
  correct_answer: number
  explanation?: string
  exam_id: string
  order: number
  points: number
}

export interface ExamResult {
  id: string
  user_id: string
  exam_id: string
  score: number
  max_score: number
  started_at: string
  completed_at: string
  answers: Record<string, number>
}

export interface Progress {
  id: string
  user_id: string
  course_id: string
  lesson_id?: string
  completed_lessons: string[]
  percentage: number
  last_accessed: string
}

export interface ForumPost {
  id: string
  title: string
  content: string
  author_id: string
  category: string
  created_at: string
  updated_at: string
  is_pinned: boolean
}

export interface ForumComment {
  id: string
  content: string
  author_id: string
  post_id: string
  created_at: string
}

export interface StudyGroup {
  id: string
  name: string
  description: string
  admin_id: string
  created_at: string
  is_public: boolean
}

export interface GroupMember {
  id: string
  group_id: string
  user_id: string
  role: 'admin' | 'member'
  joined_at: string
}
EOF

# Création du schéma de la base de données
cat > supabase/migrations/20230501000000_initial_schema.sql << EOF
-- Création des tables pour la plateforme éducative MedEduDz

-- Table des utilisateurs
CREATE TABLE public.users (
  id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'student' CHECK (role IN ('student', 'teacher', 'admin')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des cours
CREATE TABLE public.courses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  thumbnail_url TEXT,
  category TEXT NOT NULL,
  teacher_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des leçons
CREATE TABLE public.lessons (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  video_url TEXT,
  course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  "order" INTEGER NOT NULL,
  duration INTEGER, -- en minutes
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des examens
CREATE TABLE public.exams (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  duration INTEGER NOT NULL, -- en minutes
  course_id UUID REFERENCES public.courses(id) ON DELETE SET NULL,
  created_by UUID REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_published BOOLEAN DEFAULT FALSE
);

-- Table des questions
CREATE TABLE public.questions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  content TEXT NOT NULL,
  options TEXT[] NOT NULL,
  correct_answer INTEGER NOT NULL CHECK (correct_answer >= 0 AND correct_answer < array_length(options, 1)),
  explanation TEXT,
  exam_id UUID REFERENCES public.exams(id) ON DELETE CASCADE,
  "order" INTEGER NOT NULL,
  points INTEGER DEFAULT 1,
  CONSTRAINT valid_options CHECK (array_length(options, 1) >= 2)
);

-- Table des résultats d'examens
CREATE TABLE public.exam_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  exam_id UUID REFERENCES public.exams(id) ON DELETE CASCADE,
  score INTEGER NOT NULL,
  max_score INTEGER NOT NULL,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  answers JSONB DEFAULT '{}' -- JSON avec question_id comme clé et réponse sélectionnée comme valeur
);

-- Table des progrès
CREATE TABLE public.progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  lesson_id UUID REFERENCES public.lessons(id) ON DELETE SET NULL,
  completed_lessons UUID[] DEFAULT '{}',
  percentage INTEGER DEFAULT 0 CHECK (percentage >= 0 AND percentage <= 100),
  last_accessed TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, course_id)
);

-- Table des publications du forum
CREATE TABLE public.forum_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  author_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_pinned BOOLEAN DEFAULT FALSE
);

-- Table des commentaires du forum
CREATE TABLE public.forum_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  content TEXT NOT NULL,
  author_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  post_id UUID REFERENCES public.forum_posts(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des groupes d'étude
CREATE TABLE public.study_groups (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  admin_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_public BOOLEAN DEFAULT TRUE
);

-- Table des membres des groupes
CREATE TABLE public.group_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  group_id UUID REFERENCES public.study_groups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member' CHECK (role IN ('admin', 'member')),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(group_id, user_id)
);

-- Activer RLS (Row Level Security)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.forum_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_members ENABLE ROW LEVEL SECURITY;

-- Politiques RLS pour les utilisateurs
CREATE POLICY "Users can view their own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Politiques RLS pour les cours
CREATE POLICY "Courses are viewable by everyone" ON public.courses
  FOR SELECT USING (true);

CREATE POLICY "Teachers can create courses" ON public.courses
  FOR INSERT WITH CHECK (auth.uid() = teacher_id);

CREATE POLICY "Teachers can update their own courses" ON public.courses
  FOR UPDATE USING (auth.uid() = teacher_id);

CREATE POLICY "Admins can manage all courses" ON public.courses
  FOR ALL USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

-- Politiques RLS pour les leçons
CREATE POLICY "Lessons are viewable by everyone" ON public.lessons
  FOR SELECT USING (true);

CREATE POLICY "Teachers can create lessons for their courses" ON public.lessons
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.courses WHERE id = course_id AND teacher_id = auth.uid())
  );

CREATE POLICY "Teachers can update their own lessons" ON public.lessons
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.courses WHERE id = course_id AND teacher_id = auth.uid())
  );

-- Politiques RLS pour les examens
CREATE POLICY "Published exams are viewable by everyone" ON public.exams
  FOR SELECT USING (is_published = true);

CREATE POLICY "Teachers can view their own exams" ON public.exams
  FOR SELECT USING (created_by = auth.uid());

CREATE POLICY "Teachers can create exams" ON public.exams
  FOR INSERT WITH CHECK (created_by = auth.uid());

CREATE POLICY "Teachers can update their own exams" ON public.exams
  FOR UPDATE USING (created_by = auth.uid());

CREATE POLICY "Admins can manage all exams" ON public.exams
  FOR ALL USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

-- Politiques RLS pour les questions
CREATE POLICY "Questions are viewable with published exams" ON public.questions
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.exams WHERE id = exam_id AND is_published = true)
  );

CREATE POLICY "Teachers can view questions for their exams" ON public.questions
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.exams WHERE id = exam_id AND created_by = auth.uid())
  );

CREATE POLICY "Teachers can create questions for their exams" ON public.questions
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.exams WHERE id = exam_id AND created_by = auth.uid())
  );

-- Politiques RLS pour les résultats d'examens
CREATE POLICY "Users can view their own exam results" ON public.exam_results
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own exam results" ON public.exam_results
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own exam results" ON public.exam_results
  FOR UPDATE USING (auth.uid() = user_id);

-- Politiques RLS pour le progrès
CREATE POLICY "Users can view their own progress" ON public.progress
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own progress" ON public.progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own progress" ON public.progress
  FOR UPDATE USING (auth.uid() = user_id);

-- Politiques RLS pour le forum
CREATE POLICY "Forum posts are viewable by everyone" ON public.forum_posts
  FOR SELECT USING (true);

CREATE POLICY "Users can create forum posts" ON public.forum_posts
  FOR INSERT WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Users can update their own forum posts" ON public.forum_posts
  FOR UPDATE USING (auth.uid() = author_id);

CREATE POLICY "Admins can manage all forum posts" ON public.forum_posts
  FOR ALL USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

-- Politiques RLS pour les commentaires du forum
CREATE POLICY "Forum comments are viewable by everyone" ON public.forum_comments
  FOR SELECT USING (true);

CREATE POLICY "Users can create forum comments" ON public.forum_comments
  FOR INSERT WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Users can update their own forum comments" ON public.forum_comments
  FOR UPDATE USING (auth.uid() = author_id);

-- Politiques RLS pour les groupes d'étude
CREATE POLICY "Public study groups are viewable by everyone" ON public.study_groups
  FOR SELECT USING (is_public = true OR EXISTS (
    SELECT 1 FROM public.group_members 
    WHERE group_id = study_groups.id AND user_id = auth.uid()
  ));

CREATE POLICY "Users can create study groups" ON public.study_groups
  FOR INSERT WITH CHECK (auth.uid() = admin_id);

CREATE POLICY "Group admins can update their groups" ON public.study_groups
  FOR UPDATE USING (auth.uid() = admin_id OR EXISTS (
    SELECT 1 FROM public.group_members 
    WHERE group_id = study_groups.id AND user_id = auth.uid() AND role = 'admin'
  ));

-- Politiques RLS pour les membres des groupes
CREATE POLICY "Group members are viewable by group members" ON public.group_members
  FOR SELECT USING (EXISTS (
    SELECT 1 FROM public.group_members 
    WHERE group_id = group_members.group_id AND user_id = auth.uid()
  ));

CREATE POLICY "Users can join public groups" ON public.group_members
  FOR INSERT WITH CHECK (
    auth.uid() = user_id AND EXISTS (
      SELECT 1 FROM public.study_groups 
      WHERE id = group_id AND is_public = true
    )
  );

CREATE POLICY "Group admins can add members" ON public.group_members
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.study_groups 
      WHERE id = group_id AND (admin_id = auth.uid() OR EXISTS (
        SELECT 1 FROM public.group_members 
        WHERE group_id = group_members.group_id AND user_id = auth.uid() AND role = 'admin'
      ))
    )
  );

-- Création d'une fonction pour mettre à jour le champ updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS \$\$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

-- Création de triggers pour mettre à jour updated_at automatiquement
CREATE TRIGGER handle_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER handle_courses_updated_at BEFORE UPDATE ON public.courses FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER handle_forum_posts_updated_at BEFORE UPDATE ON public.forum_posts FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Création de vues utiles
CREATE VIEW public.course_details AS
SELECT 
  c.*,
  u.full_name AS teacher_name,
  u.avatar_url AS teacher_avatar,
  COUNT(l.id) AS lesson_count,
  COUNT(DISTINCT p.user_id) AS student_count
FROM public.courses c
LEFT JOIN public.users u ON c.teacher_id = u.id
LEFT JOIN public.lessons l ON c.id = l.course_id
LEFT JOIN public.progress p ON c.id = p.course_id
GROUP BY c.id, u.full_name, u.avatar_url;

CREATE VIEW public.user_progress AS
SELECT 
  p.*,
  c.title AS course_title,
  c.thumbnail_url AS course_thumbnail,
  COUNT(l.id) AS total_lessons,
  CARDINALITY(p.completed_lessons) AS completed_count
FROM public.progress p
JOIN public.courses c ON p.course_id = c.id
LEFT JOIN public.lessons l ON c.id = l.course_id
GROUP BY p.id, c.title, c.thumbnail_url;

-- Création de la fonction pour gérer les nouveaux utilisateurs
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS \$\$
BEGIN
  INSERT INTO public.users (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'student')::text
  );
  RETURN NEW;
END;
\$\$ LANGUAGE plpgsql SECURITY DEFINER;

-- Création du trigger pour gérer les nouveaux utilisateurs
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Insertion de données de démonstration
INSERT INTO public.users (id, email, full_name, role) VALUES
  ('00000000-0000-0000-0000-000000000001', 'admin@mededudz.com', 'Administrateur MedEduDz', 'admin'),
  ('00000000-0000-0000-0000-000000000002', 'teacher1@mededudz.com', 'Dr. Ahmed Benali', 'teacher'),
  ('00000000-0000-0000-0000-000000000003', 'teacher2@mededudz.com', 'Dr. Fatima Zohra', 'teacher');

INSERT INTO public.courses (id, title, description, category, teacher_id, thumbnail_url) VALUES
  ('00000000-0000-0000-0000-000000000010', 'Anatomie Humaine', 'Cours complet sur l''anatomie humaine avec emphasis sur les systèmes importants pour le concours de résidanat.', 'Médecine', '00000000-0000-0000-0000-000000000002', 'https://images.unsplash.com/photo-1579684385127-1c15f33850f0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'),
  ('00000000-0000-0000-0000-000000000011', 'Physiologie Médicale', 'Comprendre les fonctions des différents systèmes du corps humain et leurs interactions.', 'Médecine', '00000000-0000-0000-0000-000000000002', 'https://images.unsplash.com/photo-1530026186672-2cd00ffc50fe?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'),
  ('00000000-0000-0000-0000-000000000012', 'Pharmacologie', 'Étude des médicaments, leurs mécanismes d''action, leurs effets et leur utilisation thérapeutique.', 'Médecine', '00000000-0000-0000-0000-000000000003', 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'),
  ('00000000-0000-0000-0000-000000000013', 'Pathologie Générale', 'Introduction aux mécanismes fondamentaux des maladies et aux réponses de l''organisme.', 'Médecine', '00000000-0000-0000-0000-000000000003', 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80');

INSERT INTO public.lessons (id, title, content, course_id, "order", duration) VALUES
  ('00000000-0000-0000-0000-000000000020', 'Introduction à l''Anatomie', 'Ce cours introduit les concepts fondamentaux de l''anatomie humaine, y compris la terminologie anatomique, les plans du corps et les différents systèmes d''organes.', '00000000-0000-0000-0000-000000000010', 1, 45),
  ('00000000-0000-0000-0000-000000000021', 'Système Nerveux', 'Étude détaillée du système nerveux central et périphérique, y compris le cerveau, la moelle épinière et les nerfs.', '00000000-0000-0000-0000-000000000010', 2, 60),
  ('00000000-0000-0000-0000-000000000022', 'Système Cardiovasculaire', 'Anatomie du cœur, des vaisseaux sanguins et du système lymphatique.', '00000000-0000-0000-0000-000000000010', 3, 55),
  ('00000000-0000-0000-0000-000000000023', 'Introduction à la Physiologie', 'Concepts fondamentaux de la physiologie cellulaire et des mécanismes homéostatiques.', '00000000-0000-0000-0000-000000000011', 1, 40),
  ('00000000-0000-0000-0000-000000000024', 'Physiologie du Muscle', 'Mécanismes de contraction musculaire et types de tissus musculaires.', '00000000-0000-0000-0000-000000000011', 2, 50),
  ('00000000-0000-0000-0000-000000000025', 'Physiologie Nerveuse', 'Transmission de l''influx nerveux et fonctions du système nerveux.', '00000000-0000-0000-0000-000000000011', 3, 65);

INSERT INTO public.exams (id, title, description, duration, course_id, created_by, is_published) VALUES
  ('00000000-0000-0000-0000-000000000030', 'Quiz d''Anatomie - Système Nerveux', 'Testez vos connaissances sur l''anatomie du système nerveux.', 30, '00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000002', true),
  ('00000000-0000-0000-0000-000000000031', 'Examen de Physiologie Musculaire', 'Évaluation complète de la physiologie musculaire.', 45, '00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000002', true),
  ('00000000-0000-0000-0000-000000000032', 'Concours Blanc - Médecine', 'Simulation complète du concours de résidanat avec des questions de différentes matières.', 120, NULL, '00000000-0000-0000-0000-000000000001', true);

INSERT INTO public.questions (id, content, options, correct_answer, explanation, exam_id, "order", points) VALUES
  ('00000000-0000-0000-0000-000000000040', 'Lequel des suivants n''est pas un plexus nerveux ?', ARRAY['Plexus brachial', 'Plexus lombaire', 'Plexus sacré', 'Plexus carotidien'], 3, 'Le plexus carotidien n''existe pas. Les plexus brachial, lombaire et sacré sont des plexus nerveux réels.', '00000000-0000-0000-0000-000000000030', 1, 1),
  ('00000000-0000-0000-0000-000000000041', 'Quelle partie du cerveau est responsable de la régulation de la température corporelle ?', ARRAY['Cervelet', 'Hypothalamus', 'Hippocampe', 'Cortex moteur'], 1, 'L''hypothalamus est responsable de la régulation de la température corporelle, ainsi que de nombreuses autres fonctions homéostatiques.', '00000000-0000-0000-0000-000000000030', 2, 1),
  ('00000000-0000-0000-0000-000000000042', 'Quel type de fibre musculaire est caractérisé par une contraction rapide et une fatigue rapide ?', ARRAY['Type I (fibres lentes)', 'Type IIa (fibres intermédiaires)', 'Type IIx (fibres rapides)', 'Fibres cardiaques'], 2, 'Les fibres de type IIx (ou IIb) sont caractérisées par une contraction rapide mais une fatigue rapide en raison de leur métabolisme principalement anaérobie.', '00000000-0000-0000-0000-000000000031', 1, 1),
  ('00000000-0000-0000-0000-000000000043', 'Quelle protéine est responsable de la liaison au calcium dans le muscle ?', ARRAY['Actine', 'Myosine', 'Troponine', 'Tropomyosine'], 2, 'La troponine est le complexe protéique qui lie le calcium, provoquant un changement conformationnel qui permet l''interaction entre l''actine et la myosine.', '00000000-0000-0000-0000-000000000031', 2, 1),
  ('00000000-0000-0000-0000-000000000044', 'Lequel des médicaments suivants est un inhibiteur de l''enzyme de conversion de l''angiotensine (IEC) ?', ARRAY['Aténolol', 'Lisinopril', 'Furosémide', 'Amlodipine'], 1, 'Le lisinopril est un inhibiteur de l''enzyme de conversion de l''angiotensine (IEC) utilisé pour traiter l''hypertension et l''insuffisance cardiaque.', '00000000-0000-0000-0000-000000000032', 1, 1),
  ('00000000-0000-0000-0000-000000000045', 'Quelle est la cause la plus fréquente de la nécrose tubulaire aiguë ?', ARRAY['Hypotension prolongée', 'Infection urinaire', 'Calculs rénaux', 'Glomérulonéphrite'], 0, 'L''hypotension prolongée est la cause la plus fréquente de nécrose tubulaire aiguë, entraînant une ischémie rénale et des dommages tubulaires.', '00000000-0000-0000-0000-000000000032', 2, 1);

INSERT INTO public.forum_posts (id, title, content, author_id, category, is_pinned) VALUES
  ('00000000-0000-0000-0000-000000000050', 'Conseils pour réussir le concours de résidanat', 'Bonjour à tous, je voudrais partager quelques conseils qui m''ont aidé à réussir le concours de résidanat l''année dernière. Tout d''abord, il est important de commencer tôt et d''être régulier dans ses révisions. Ensuite, n''hésitez pas à former des groupes d''étude avec vos collègues. Enfin, entraînez-vous régulièrement avec des annales et des exercices pratiques. Bonne chance à tous !', '00000000-0000-0000-0000-000000000002', 'Conseils', true),
  ('00000000-0000-0000-0000-000000000051', 'Difficultés en anatomie du système nerveux', 'Bonjour, j''ai beaucoup de mal à mémoriser les différents noyaux et voies du système nerveux. Avez-vous des techniques ou des ressources qui pourraient m''aider ?', '00000000-0000-0000-0000-000000000003', 'Anatomie', false),
  ('00000000-0000-0000-0000-000000000052', 'Recherche groupe d''étude pour pharmacologie', 'Je recherche des personnes intéressées pour former un groupe d''étude en pharmacologie. Nous pourrions nous retrouver une fois par semaine pour réviser ensemble et faire des exercices.', '00000000-0000-0000-0000-000000000003', 'Groupes d''étude', false);

INSERT INTO public.study_groups (id, name, description, admin_id, is_public) VALUES
  ('00000000-0000-0000-0000-000000000060', 'Groupe d''étude Anatomie', 'Groupe dédié à l''étude approfondie de l''anatomie humaine pour la préparation du concours de résidanat.', '00000000-0000-0000-0000-000000000002', true),
  ('00000000-0000-0000-0000-000000000061', 'Club de Physiologie', 'Espace d''échange et de révision des concepts de physiologie médicale.', '00000000-0000-0000-0000-000000000003', true),
  ('00000000-0000-0000-0000-000000000062', 'Équipe Pharmaco', 'Groupe fermé pour les étudiants motivés en pharmacologie.', '00000000-0000-0000-0000-000000000002', false);

INSERT INTO public.group_members (id, group_id, user_id, role) VALUES
  ('00000000-0000-0000-0000-000000000070', '00000000-0000-0000-0000-000000000060', '00000000-0000-0000-0000-000000000002', 'admin'),
  ('00000000-0000-0000-0000-000000000071', '00000000-0000-0000-0000-000000000060', '00000000-0000-0000-0000-000000000003', 'member'),
  ('00000000-0000-0000-0000-000000000072', '00000000-0000-0000-0000-000000000061', '00000000-0000-0000-0000-000000000003', 'admin'),
  ('00000000-0000-0000-0000-000000000073', '00000000-0000-0000-0000-000000000062', '00000000-0000-0000-0000-000000000002', 'admin');
EOF

# Création du fichier de configuration Tailwind CSS
cat > tailwind.config.js << EOF
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
        secondary: {
          50: '#f5f3ff',
          100: '#ede9fe',
          200: '#ddd6fe',
          300: '#c4b5fd',
          400: '#a78bfa',
          500: '#8b5cf6',
          600: '#7c3aed',
          700: '#6d28d9',
          800: '#5b21b6',
          900: '#4c1d95',
        },
        accent: {
          50: '#fdf2f8',
          100: '#fce7f3',
          200: '#fbcfe8',
          300: '#f9a8d4',
          400: '#f472b6',
          500: '#ec4899',
          600: '#db2777',
          700: '#be185d',
          800: '#9d174d',
          900: '#831843',
        },
        dark: {
          50: '#f8fafc',
          100: '#f1f5f9',
          200: '#e2e8f0',
          300: '#cbd5e1',
          400: '#94a3b8',
          500: '#64748b',
          600: '#475569',
          700: '#334155',
          800: '#1e293b',
          900: '#0f172a',
        },
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
      boxShadow: {
        'soft': '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
        'medium': '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
        'hard': '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)',
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'bounce-subtle': 'bounceSubtle 0.6s ease-in-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        bounceSubtle: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-5px)' },
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
EOF

# Création du fichier globals.css
cat > src/app/globals.css << EOF
@tailwind base;
@tailwind components;
@tailwind utilities;

@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
    font-feature-settings: "rlig" 1, "calt" 1;
  }
}

@layer components {
  .btn {
    @apply inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none ring-offset-background;
  }
  
  .btn-primary {
    @apply btn bg-primary-600 hover:bg-primary-700 text-white;
  }
  
  .btn-secondary {
    @apply btn bg-secondary-600 hover:bg-secondary-700 text-white;
  }
  
  .btn-outline {
    @apply btn border border-gray-300 bg-transparent hover:bg-gray-50 text-gray-700;
  }
  
  .btn-ghost {
    @apply btn hover:bg-gray-100 text-gray-700;
  }
  
  .btn-sm {
    @apply btn h-8 px-3 text-xs;
  }
  
  .btn-md {
    @apply btn h-9 px-4 py-2;
  }
  
  .btn-lg {
    @apply btn h-10 px-6;
  }
  
  .input {
    @apply flex h-9 w-full rounded-md border border-gray-300 bg-transparent px-3 py-1 text-sm shadow-sm transition-colors file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50;
  }
  
  .card {
    @apply rounded-lg border border-gray-200 bg-white shadow-sm;
  }
  
  .card-header {
    @apply flex flex-col space-y-1.5 p-6;
  }
  
  .card-title {
    @apply text-lg font-semibold leading-none tracking-tight;
  }
  
  .card-description {
    @apply text-sm text-gray-500;
  }
  
  .card-content {
    @apply p-6 pt-0;
  }
  
  .card-footer {
    @apply flex items-center p-6 pt-0;
  }
  
  .badge {
    @apply inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium;
  }
  
  .badge-primary {
    @apply badge bg-primary-100 text-primary-800;
  }
  
  .badge-secondary {
    @apply badge bg-secondary-100 text-secondary-800;
  }
  
  .badge-accent {
    @apply badge bg-accent-100 text-accent-800;
  }
  
  .badge-outline {
    @apply badge border border-gray-200 bg-white text-gray-700;
  }
  
  .avatar {
    @apply relative flex h-8 w-8 shrink-0 overflow-hidden rounded-full;
  }
  
  .avatar-sm {
    @apply avatar h-6 w-6;
  }
  
  .avatar-md {
    @apply avatar h-8 w-8;
  }
  
  .avatar-lg {
    @apply avatar h-10 w-10;
  }
  
  .avatar-xl {
    @apply avatar h-12 w-12;
  }
  
  .navigation-menu {
    @apply relative z-10 flex max-w-max flex-1 items-center justify-center;
  }
  
  .navigation-menu-list {
    @apply group flex flex-1 list-none items-center justify-center space-x-1;
  }
  
  .navigation-menu-item {
    @apply list-none;
  }
  
  .navigation-menu-link {
    @apply group inline-flex h-9 w-max items-center justify-center rounded-md bg-background px-4 py-2 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground focus:outline-none disabled:pointer-events-none disabled:opacity-50 data-[active]:bg-accent/50 data-[state=open]:bg-accent/50;
  }
  
  .navigation-menu-trigger {
    @apply group inline-flex h-9 w-max items-center justify-center rounded-md bg-background px-4 py-2 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground focus:outline-none disabled:pointer-events-none disabled:opacity-50 data-[state=open]:bg-accent/50;
  }
  
  .navigation-menu-content {
    @apply left-0 top-0 w-full data-[motion^=from-]:animate-in data-[motion^=to-]:animate-out data-[motion^=from-]:fade-in data-[motion^=to-]:fade-out data-[motion=from-end]:slide-in-from-right-52 data-[motion=from-start]:slide-in-from-left-52 data-[motion=to-end]:slide-out-to-right-52 data-[motion=to-start]:slide-out-to-left-52 md:absolute md:w-auto;
  }
  
  .navigation-menu-viewport {
    @apply absolute left-0 top-full flex-col data-[state=open]:flex data-[state=closed]:hidden;
  }
}

@layer utilities {
  .text-balance {
    text-wrap: balance;
  }
}
EOF

# Création du layout principal
cat > src/app/layout.tsx << EOF
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Toaster } from 'react-hot-toast'
import { AuthProvider } from '@/components/auth-provider'
import { Navbar } from '@/components/layout/navbar'
import { Footer } from '@/components/layout/footer'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'MedEduDz - Plateforme éducative pour le concours de résidanat',
  description: 'Préparez-vous efficacement au concours de résidanat à Constantine avec nos cours, examens et ressources pédagogiques.',
  keywords: ['résidanat', 'médecine', 'Constantine', 'concours', 'éducation', 'cours', 'examens'],
  authors: [{ name: 'MedEduDz Team' }],
  openGraph: {
    title: 'MedEduDz - Plateforme éducative pour le concours de résidanat',
    description: 'Préparez-vous efficacement au concours de résidanat à Constantine avec nos cours, examens et ressources pédagogiques.',
    type: 'website',
    locale: 'fr_DZ',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr">
      <body className={inter.className}>
        <AuthProvider>
          <div className="min-h-screen flex flex-col bg-gray-50">
            <Navbar />
            <main className="flex-1">
              {children}
            </main>
            <Footer />
          </div>
          <Toaster position="top-right" />
        </AuthProvider>
      </body>
    </html>
  )
}
EOF

# Création du composant Navbar
cat > src/components/layout/navbar.tsx << EOF
'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useState } from 'react'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/hooks/use-auth'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  NavigationMenu,
  NavigationMenuContent,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  NavigationMenuTrigger,
} from '@/components/ui/navigation-menu'
import {
  BookOpen,
  ClipboardList,
  Users,
  MessageSquare,
  BarChart3,
  LogIn,
  LogOut,
  User,
  Settings,
  ChevronDown,
  Menu,
  X,
} from 'lucide-react'

export function Navbar() {
  const pathname = usePathname()
  const { user, profile, loading } = useAuth()
  const [isMenuOpen, setIsMenuOpen] = useState(false)

  const handleSignOut = async () => {
    await supabase.auth.signOut()
  }

  const isActive = (path: string) => {
    return pathname === path || pathname.startsWith(path + '/')
  }

  const navigation = [
    { name: 'Accueil', href: '/' },
    { name: 'Cours', href: '/courses' },
    { name: 'Examens', href: '/exams' },
    { name: 'Forum', href: '/forum' },
    { name: 'Groupes', href: '/groups' },
  ]

  return (
    <header className="sticky top-0 z-50 w-full border-b bg-white/95 backdrop-blur supports-[backdrop-filter]:bg-white/60">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex h-16 items-center justify-between">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <Link href="/" className="flex items-center">
                <div className="h-8 w-8 rounded-full bg-gradient-to-r from-primary-600 to-secondary-600 flex items-center justify-center">
                  <span className="text-white font-bold text-sm">ME</span>
                </div>
                <span className="ml-2 text-xl font-bold text-gray-900">MedEduDz</span>
              </Link>
            </div>
            <div className="hidden md:block md:ml-10">
              <div className="flex items-baseline space-x-4">
                {navigation.map((item) => (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={\`
                      px-3 py-2 rounded-md text-sm font-medium transition-colors
                      \${isActive(item.href)
                        ? 'bg-primary-50 text-primary-700'
                        : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                      }
                    \`}
                  >
                    {item.name}
                  </Link>
                ))}
              </div>
            </div>
          </div>

          <div className="hidden md:block">
            <div className="ml-4 flex items-center md:ml-6">
              {loading ? (
                <div className="h-8 w-8 rounded-full bg-gray-200 animate-pulse"></div>
              ) : user ? (
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button variant="ghost" className="relative h-8 w-8 rounded-full">
                      <Avatar className="h-8 w-8">
                        <AvatarImage src={profile?.avatar_url} alt={profile?.full_name || ''} />
                        <AvatarFallback>
                          {profile?.full_name?.charAt(0) || user.email?.charAt(0) || 'U'}
                        </AvatarFallback>
                      </Avatar>
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent className="w-56" align="end" forceMount>
                    <DropdownMenuLabel className="font-normal">
                      <div className="flex flex-col space-y-1">
                        <p className="text-sm font-medium leading-none">
                          {profile?.full_name || 'Utilisateur'}
                        </p>
                        <p className="text-xs leading-none text-muted-foreground">
                          {user.email}
                        </p>
                      </div>
                    </DropdownMenuLabel>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem asChild>
                      <Link href="/dashboard">
                        <BarChart3 className="mr-2 h-4 w-4" />
                        <span>Tableau de bord</span>
                      </Link>
                    </DropdownMenuItem>
                    <DropdownMenuItem asChild>
                      <Link href="/profile">
                        <User className="mr-2 h-4 w-4" />
                        <span>Profil</span>
                      </Link>
                    </DropdownMenuItem>
                    <DropdownMenuItem asChild>
                      <Link href="/settings">
                        <Settings className="mr-2 h-4 w-4" />
                        <span>Paramètres</span>
                      </Link>
                    </DropdownMenuItem>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem onClick={handleSignOut}>
                      <LogOut className="mr-2 h-4 w-4" />
                      <span>Déconnexion</span>
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              ) : (
                <div className="flex items-center space-x-2">
                  <Button asChild variant="ghost">
                    <Link href="/auth/signin">
                      <LogIn className="mr-2 h-4 w-4" />
                      Connexion
                    </Link>
                  </Button>
                  <Button asChild>
                    <Link href="/auth/signup">
                      Inscription
                    </Link>
                  </Button>
                </div>
              )}
            </div>
          </div>

          <div className="-mr-2 flex md:hidden">
            <Button
              variant="ghost"
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className="inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500"
            >
              {isMenuOpen ? (
                <X className="block h-6 w-6" aria-hidden="true" />
              ) : (
                <Menu className="block h-6 w-6" aria-hidden="true" />
              )}
            </Button>
          </div>
        </div>
      </div>

      {isMenuOpen && (
        <div className="md:hidden">
          <div className="px-2 pt-2 pb-3 space-y-1 sm:px-3 bg-white border-t">
            {navigation.map((item) => (
              <Link
                key={item.name}
                href={item.href}
                className={\`
                  block px-3 py-2 rounded-md text-base font-medium transition-colors
                  \${isActive(item.href)
                    ? 'bg-primary-50 text-primary-700'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                  }
                \`}
                onClick={() => setIsMenuOpen(false)}
              >
                {item.name}
              </Link>
            ))}
            {user ? (
              <>
                <Link
                  href="/dashboard"
                  className="block px-3 py-2 rounded-md text-base font-medium text-gray-600 hover:bg-gray-50 hover:text-gray-900"
                  onClick={() => setIsMenuOpen(false)}
                >
                  Tableau de bord
                </Link>
                <Link
                  href="/profile"
                  className="block px-3 py-2 rounded-md text-base font-medium text-gray-600 hover:bg-gray-50 hover:text-gray-900"
                  onClick={() => setIsMenuOpen(false)}
                >
                  Profil
                </Link>
                <button
                  onClick={() => {
                    handleSignOut()
                    setIsMenuOpen(false)
                  }}
                  className="block w-full text-left px-3 py-2 rounded-md text-base font-medium text-gray-600 hover:bg-gray-50 hover:text-gray-900"
                >
                  Déconnexion
                </button>
              </>
            ) : (
              <>
                <Link
                  href="/auth/signin"
                  className="block px-3 py-2 rounded-md text-base font-medium text-gray-600 hover:bg-gray-50 hover:text-gray-900"
                  onClick={() => setIsMenuOpen(false)}
                >
                  Connexion
                </Link>
                <Link
                  href="/auth/signup"
                  className="block px-3 py-2 rounded-md text-base font-medium bg-primary-600 text-white hover:bg-primary-700"
                  onClick={() => setIsMenuOpen(false)}
                >
                  Inscription
                </Link>
              </>
            )}
          </div>
        </div>
      )}
    </header>
  )
}
EOF

# Création du composant Footer
cat > src/components/layout/footer.tsx << EOF
import Link from 'next/link'
import { Facebook, Twitter, Instagram, Youtube, Mail, Phone, MapPin } from 'lucide-react'

export function Footer() {
  return (
    <footer className="bg-dark-900 text-white">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div className="col-span-1 md:col-span-2">
            <div className="flex items-center mb-4">
              <div className="h-10 w-10 rounded-full bg-gradient-to-r from-primary-600 to-secondary-600 flex items-center justify-center">
                <span className="text-white font-bold">ME</span>
              </div>
              <span className="ml-2 text-2xl font-bold">MedEduDz</span>
            </div>
            <p className="text-gray-300 mb-4 max-w-md">
              Plateforme éducative dédiée à la préparation du concours de résidanat à Constantine. 
              Nous offrons des cours de qualité, des examens pratiques et une communauté d'apprentissage.
            </p>
            <div className="flex space-x-4">
              <a href="#" className="text-gray-400 hover:text-white transition-colors">
                <Facebook className="h-6 w-6" />
                <span className="sr-only">Facebook</span>
              </a>
              <a href="#" className="text-gray-400 hover:text-white transition-colors">
                <Twitter className="h-6 w-6" />
                <span className="sr-only">Twitter</span>
              </a>
              <a href="#" className="text-gray-400 hover:text-white transition-colors">
                <Instagram className="h-6 w-6" />
                <span className="sr-only">Instagram</span>
              </a>
              <a href="#" className="text-gray-400 hover:text-white transition-colors">
                <Youtube className="h-6 w-6" />
                <span className="sr-only">YouTube</span>
              </a>
            </div>
          </div>

          <div>
            <h3 className="text-lg font-semibold mb-4">Liens rapides</h3>
            <ul className="space-y-2">
              <li>
                <Link href="/" className="text-gray-300 hover:text-white transition-colors">
                  Accueil
                </Link>
              </li>
              <li>
                <Link href="/courses" className="text-gray-300 hover:text-white transition-colors">
                  Cours
                </Link>
              </li>
              <li>
                <Link href="/exams" className="text-gray-300 hover:text-white transition-colors">
                  Examens
                </Link>
              </li>
              <li>
                <Link href="/forum" className="text-gray-300 hover:text-white transition-colors">
                  Forum
                </Link>
              </li>
              <li>
                <Link href="/groups" className="text-gray-300 hover:text-white transition-colors">
                  Groupes d'étude
                </Link>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="text-lg font-semibold mb-4">Contact</h3>
            <ul className="space-y-3">
              <li className="flex items-start">
                <MapPin className="h-5 w-5 text-primary-400 mr-2 mt-0.5" />
                <span className="text-gray-300">Université Constantine 1, Algérie</span>
              </li>
              <li className="flex items-center">
                <Mail className="h-5 w-5 text-primary-400 mr-2" />
                <span className="text-gray-300">contact@mededudz.com</span>
              </li>
              <li className="flex items-center">
                <Phone className="h-5 w-5 text-primary-400 mr-2" />
                <span className="text-gray-300">+213 123 456 789</span>
              </li>
            </ul>
          </div>
        </div>

        <div className="border-t border-gray-800 mt-8 pt-8 flex flex-col md:flex-row justify-between items-center">
          <p className="text-gray-400 text-sm">
            © {new Date().getFullYear()} MedEduDz. Tous droits réservés.
          </p>
          <div className="flex space-x-6 mt-4 md:mt-0">
            <Link href="/privacy" className="text-gray-400 hover:text-white text-sm transition-colors">
              Politique de confidentialité
            </Link>
            <Link href="/terms" className="text-gray-400 hover:text-white text-sm transition-colors">
              Conditions d'utilisation
            </Link>
            <Link href="/cookies" className="text-gray-400 hover:text-white text-sm transition-colors">
              Cookies
            </Link>
          </div>
        </div>
      </div>
    </footer>
  )
}
EOF

# Création du hook useAuth
cat > src/hooks/use-auth.tsx << EOF
'use client'

import { createContext, useContext, useEffect, useState } from 'react'
import { User } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'
import { Profile } from '@/types'

interface AuthContextType {
  user: User | null
  profile: Profile | null
  loading: boolean
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  profile: null,
  loading: true,
})

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [profile, setProfile] = useState<Profile | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Get initial session
    const getInitialSession = async () => {
      const {
        data: { session },
      } = await supabase.auth.getSession()

      setUser(session?.user ?? null)
      if (session?.user) {
        await fetchProfile(session.user.id)
      }
      setLoading(false)
    }

    getInitialSession()

    // Listen for auth changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(async (_event, session) => {
      setUser(session?.user ?? null)
      if (session?.user) {
        await fetchProfile(session.user.id)
      } else {
        setProfile(null)
      }
      setLoading(false)
    })

    return () => subscription.unsubscribe()
  }, [])

  const fetchProfile = async (userId: string) => {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', userId)
      .single()

    if (data && !error) {
      setProfile(data as Profile)
    }
  }

  return (
    <AuthContext.Provider value={{ user, profile, loading }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
EOF

# Création du composant AuthProvider
cat > src/components/auth-provider.tsx << EOF
'use client'

import { AuthProvider } from '@/hooks/use-auth'

export function AuthProvider({ children }: { children: React.ReactNode }) {
  return <AuthProvider>{children}</AuthProvider>
}
EOF

# Création des composants UI
mkdir -p src/components/ui

# Création du composant Button
cat > src/components/ui/button.tsx << EOF
import * as React from 'react'
import { Slot } from '@radix-ui/react-slot'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary-600 text-white hover:bg-primary-700',
        destructive: 'bg-red-500 text-white hover:bg-red-600',
        outline: 'border border-gray-300 bg-transparent hover:bg-gray-50 text-gray-700',
        secondary: 'bg-secondary-600 text-white hover:bg-secondary-700',
        ghost: 'hover:bg-gray-100 text-gray-700',
        link: 'text-primary-600 underline-offset-4 hover:underline',
      },
      size: {
        default: 'h-9 px-4 py-2',
        sm: 'h-8 rounded-md px-3 text-xs',
        lg: 'h-10 rounded-md px-8',
        icon: 'h-9 w-9',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : 'button'
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = 'Button'

export { Button, buttonVariants }
EOF

# Création du composant Avatar
cat > src/components/ui/avatar.tsx << EOF
import * as React from 'react'
import * as AvatarPrimitive from '@radix-ui/react-avatar'
import { cn } from '@/lib/utils'

const Avatar = React.forwardRef<
  React.ElementRef<typeof AvatarPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Root>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Root
    ref={ref}
    className={cn(
      'relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full',
      className
    )}
    {...props}
  />
))
Avatar.displayName = AvatarPrimitive.Root.displayName

const AvatarImage = React.forwardRef<
  React.ElementRef<typeof AvatarPrimitive.Image>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Image>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Image
    ref={ref}
    className={cn('aspect-square h-full w-full', className)}
    {...props}
  />
))
AvatarImage.displayName = AvatarPrimitive.Image.displayName

const AvatarFallback = React.forwardRef<
  React.ElementRef<typeof AvatarPrimitive.Fallback>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Fallback>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Fallback
    ref={ref}
    className={cn(
      'flex h-full w-full items-center justify-center rounded-full bg-gray-100',
      className
    )}
    {...props}
  />
))
AvatarFallback.displayName = AvatarPrimitive.Fallback.displayName

export { Avatar, AvatarImage, AvatarFallback }
EOF

# Création du composant DropdownMenu
cat > src/components/ui/dropdown-menu.tsx << EOF
import * as React from 'react'
import * as DropdownMenuPrimitive from '@radix-ui/react-dropdown-menu'
import { Check, ChevronRight, Circle } from 'lucide-react'
import { cn } from '@/lib/utils'

const DropdownMenu = DropdownMenuPrimitive.Root

const DropdownMenuTrigger = DropdownMenuPrimitive.Trigger

const DropdownMenuGroup = DropdownMenuPrimitive.Group

const DropdownMenuPortal = DropdownMenuPrimitive.Portal

const DropdownMenuSub = DropdownMenuPrimitive.Sub

const DropdownMenuRadioGroup = DropdownMenuPrimitive.RadioGroup

const DropdownMenuSubTrigger = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.SubTrigger>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.SubTrigger> & {
    inset?: boolean
  }
>(({ className, inset, children, ...props }, ref) => (
  <DropdownMenuPrimitive.SubTrigger
    ref={ref}
    className={cn(
      'flex cursor-default select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none focus:bg-gray-100 data-[state=open]:bg-gray-100',
      inset && 'pl-8',
      className
    )}
    {...props}
  >
    {children}
    <ChevronRight className="ml-auto h-4 w-4" />
  </DropdownMenuPrimitive.SubTrigger>
))
DropdownMenuSubTrigger.displayName =
  DropdownMenuPrimitive.SubTrigger.displayName

const DropdownMenuSubContent = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.SubContent>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.SubContent>
>(({ className, ...props }, ref) => (
  <DropdownMenuPrimitive.SubContent
    ref={ref}
    className={cn(
      'z-50 min-w-[8rem] overflow-hidden rounded-md border border-gray-200 bg-white p-1 text-gray-900 shadow-lg data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2',
      className
    )}
    {...props}
  />
))
DropdownMenuSubContent.displayName =
  DropdownMenuPrimitive.SubContent.displayName

const DropdownMenuContent = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.Content>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Content>
>(({ className, sideOffset = 4, ...props }, ref) => (
  <DropdownMenuPrimitive.Portal>
    <DropdownMenuPrimitive.Content
      ref={ref}
      sideOffset={sideOffset}
      className={cn(
        'z-50 min-w-[8rem] overflow-hidden rounded-md border border-gray-200 bg-white p-1 text-gray-900 shadow-md data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2',
        className
      )}
      {...props}
    />
  </DropdownMenuPrimitive.Portal>
))
DropdownMenuContent.displayName = DropdownMenuPrimitive.Content.displayName

const DropdownMenuItem = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.Item>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Item> & {
    inset?: boolean
  }
>(({ className, inset, ...props }, ref) => (
  <DropdownMenuPrimitive.Item
    ref={ref}
    className={cn(
      'relative flex cursor-default select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors focus:bg-gray-100 focus:text-gray-900 data-[disabled]:pointer-events-none data-[disabled]:opacity-50',
      inset && 'pl-8',
      className
    )}
    {...props}
  />
))
DropdownMenuItem.displayName = DropdownMenuPrimitive.Item.displayName

const DropdownMenuCheckboxItem = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.CheckboxItem>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.CheckboxItem>
>(({ className, children, checked, ...props }, ref) => (
  <DropdownMenuPrimitive.CheckboxItem
    ref={ref}
    className={cn(
      'relative flex cursor-default select-none items-center rounded-sm py-1.5 pl-8 pr-2 text-sm outline-none transition-colors focus:bg-gray-100 focus:text-gray-900 data-[disabled]:pointer-events-none data-[disabled]:opacity-50',
      className
    )}
    checked={checked}
    {...props}
  >
    <span className="absolute left-2 flex h-3.5 w-3.5 items-center justify-center">
      <DropdownMenuPrimitive.ItemIndicator>
        <Check className="h-4 w-4" />
      </DropdownMenuPrimitive.ItemIndicator>
    </span>
    {children}
  </DropdownMenuPrimitive.CheckboxItem>
))
DropdownMenuCheckboxItem.displayName =
  DropdownMenuPrimitive.CheckboxItem.displayName

const DropdownMenuRadioItem = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.RadioItem>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.RadioItem>
>(({ className, children, ...props }, ref) => (
  <DropdownMenuPrimitive.RadioItem
    ref={ref}
    className={cn(
      'relative flex cursor-default select-none items-center rounded-sm py-1.5 pl-8 pr-2 text-sm outline-none transition-colors focus:bg-gray-100 focus:text-gray-900 data-[disabled]:pointer-events-none data-[disabled]:opacity-50',
      className
    )}
    {...props}
  >
    <span className="absolute left-2 flex h-3.5 w-3.5 items-center justify-center">
      <DropdownMenuPrimitive.ItemIndicator>
        <Circle className="h-2 w-2 fill-current" />
      </DropdownMenuPrimitive.ItemIndicator>
    </span>
    {children}
  </DropdownMenuPrimitive.RadioItem>
))
DropdownMenuRadioItem.displayName = DropdownMenuPrimitive.RadioItem.displayName

const DropdownMenuLabel = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.Label>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Label> & {
    inset?: boolean
  }
>(({ className, inset, ...props }, ref) => (
  <DropdownMenuPrimitive.Label
    ref={ref}
    className={cn(
      'px-2 py-1.5 text-sm font-semibold',
      inset && 'pl-8',
      className
    )}
    {...props}
  />
))
DropdownMenuLabel.displayName = DropdownMenuPrimitive.Label.displayName

const DropdownMenuSeparator = React.forwardRef<
  React.ElementRef<typeof DropdownMenuPrimitive.Separator>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Separator>
>(({ className, ...props }, ref) => (
  <DropdownMenuPrimitive.Separator
    ref={ref}
    className={cn('-mx-1 my-1 h-px bg-gray-100', className)}
    {...props}
  />
))
DropdownMenuSeparator.displayName = DropdownMenuPrimitive.Separator.displayName

const DropdownMenuShortcut = ({
  className,
  ...props
}: React.HTMLAttributes<HTMLSpanElement>) => {
  return (
    <span
      className={cn('ml-auto text-xs tracking-widest opacity-60', className)}
      {...props}
    />
  )
}
DropdownMenuShortcut.displayName = 'DropdownMenuShortcut'

export {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuCheckboxItem,
  DropdownMenuRadioItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuShortcut,
  DropdownMenuGroup,
  DropdownMenuPortal,
  DropdownMenuSub,
  DropdownMenuSubContent,
  DropdownMenuSubTrigger,
  DropdownMenuRadioGroup,
}
EOF

# Création du composant NavigationMenu
cat > src/components/ui/navigation-menu.tsx << EOF
import * as React from 'react'
import * as NavigationMenuPrimitive from '@radix-ui/react-navigation-menu'
import { cva } from 'class-variance-authority'
import { ChevronDown } from 'lucide-react'
import { cn } from '@/lib/utils'

const NavigationMenuContext = React.createContext<{
  viewport: React.RefObject<HTMLDivElement>
}>({
  viewport: React.createRef<HTMLDivElement>(),
})

const useNavigationMenuContext = () => {
  const context = React.useContext(NavigationMenuContext)
  if (!context) {
    throw new Error(
      'NavigationMenuItem must be used within a NavigationMenu'
    )
  }
  return context
}

const NavigationMenu = React.forwardRef<
  React.ElementRef<typeof NavigationMenuPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof NavigationMenuPrimitive.Root>
>(({ className, children, ...props }, ref) => (
  <NavigationMenuPrimitive.Root
    ref={ref}
    className={cn(
      'relative z-10 flex max-w-max flex-1 items-center justify-center',
      className
    )}
    {...props}
  >
    {children}
    <NavigationMenuViewport />
  </NavigationMenuPrimitive.Root>
))
NavigationMenu.displayName = NavigationMenuPrimitive.Root.displayName

const NavigationMenuList = React.forwardRef<
  React.ElementRef<typeof NavigationMenuPrimitive.List>,
  React.ComponentPropsWithoutRef<typeof NavigationMenuPrimitive.List>
>(({ className, ...props }, ref) => (
  <NavigationMenuPrimitive.List
    ref={ref}
    className={cn(
      'group flex flex-1 list-none items-center justify-center space-x-1',
      className
    )}
    {...props}
  />
))
NavigationMenuList.displayName = NavigationMenuPrimitive.List.displayName

const NavigationMenuItem = NavigationMenuPrimitive.Item

const navigationMenuTriggerStyle = cva(
  'group inline-flex h-9 w-max items-center justify-center rounded-md bg-background px-4 py-2 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground focus:outline-none disabled:pointer-events-none disabled:opacity-50 data-[active]:bg-accent/50 data-[state=open]:bg-accent/50'
)

const NavigationMenuTrigger = React.forwardRef<
  React.ElementRef<typeof NavigationMenuPrimitive.Trigger>,
  React.ComponentPropsWithoutRef<typeof NavigationMenuPrimitive.Trigger>
>(({ className, children, ...props }, ref) => (
  <NavigationMenuPrimitive.Trigger
    ref={ref}
    className={cn(navigationMenuTriggerStyle(), 'group', className)}
    {...props}
  >
    {children}{' '}
    <ChevronDown
      className="relative top-[1px] ml-1 h-3 w-3 transition duration-200 group-data-[state=open]:rotate-180"
      aria-hidden="true"
    />
  </NavigationMenuPrimitive.Trigger>
))
NavigationMenuTrigger.displayName = NavigationMenuPrimitive.Trigger.displayName

const NavigationMenuContent = React.forwardRef<
  React.ElementRef<typeof NavigationMenuPrimitive.Content>,
  React.ComponentPropsWithoutRef<typeof NavigationMenuPrimitive.Content>
>(({ className, ...props }, ref) => (
  <NavigationMenuPrimitive.Content
    ref={ref}
    className={cn(
      'left-0 top-0 w-full data-[motion^=from-]:animate-in data-[motion^=to-]:animate-out data-[motion^=from-]:fade-in data-[motion^=to-]:fade-out data-[motion=from-end]:slide-in-from-right-52 data-[motion=from-start]:slide-in-from-left-52 data-[motion=to-end]:slide-out-to-right-52 data-[motion=to-start]:slide-out-to-left-52 md:absolute md:w-auto',
      className
    )}
    {...props}
  />
))
NavigationMenuContent.displayName = NavigationMenuPrimitive.Content.displayName

const NavigationMenuLink = NavigationMenuPrimitive.Link

const NavigationMenuViewport = React.forwardRef<
  React.ElementRef<typeof NavigationMenuPrimitive.Viewport>,
  React.ComponentPropsWithoutRef<typeof NavigationMenuPrimitive.Viewport>
>(({ className, ...props }, ref) => {
  const context = useNavigationMenuContext()
  return (
    <div className={cn('absolute left-0 top-full flex justify-center')}>
      <NavigationMenuPrimitive.Viewport
        className={cn(
          'origin-top-center relative mt-1.5 h-[var(--radix-navigation-menu-viewport-height)] w-full overflow-hidden rounded-md border border-gray-200 bg-white text-gray-900 shadow-lg data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-90 md:w-[var(--radix-navigation-menu-viewport-width)]',
          className
        )}
        ref={context.viewport}
        {...props}
      />
    </div>
  )
})
NavigationMenuViewport.displayName =
  NavigationMenuPrimitive.Viewport.displayName

const NavigationMenuIndicator = React.forwardRef<
  React.ElementRef<typeof NavigationMenuPrimitive.Indicator>,
  React.ComponentPropsWithoutRef<typeof NavigationMenuPrimitive.Indicator>
>(({ className, ...props }, ref) => (
  <NavigationMenuPrimitive.Indicator
    ref={ref}
    className={cn(
      'top-full z-[1] flex h-1.5 items-end justify-center overflow-hidden data-[state=visible]:animate-in data-[state=hidden]:animate-out data-[state=hidden]:fade-out data-[state=visible]:fade-in',
      className
    )}
    {...props}
  >
    <div className="relative top-[60%] h-2 w-2 rotate-45 rounded-tl-sm bg-gray-200 shadow-md" />
  </NavigationMenuPrimitive.Indicator>
))
NavigationMenuIndicator.displayName =
  NavigationMenuPrimitive.Indicator.displayName

export {
  navigationMenuTriggerStyle,
  NavigationMenu,
  NavigationMenuList,
  NavigationMenuItem,
  NavigationMenuContent,
  NavigationMenuTrigger,
  NavigationMenuLink,
  NavigationMenuIndicator,
  NavigationMenuViewport,
}
EOF

# Création du fichier utils
cat > src/lib/utils.ts << EOF
import { type ClassValue, clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatDate(date: string | Date) {
  return new Date(date).toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  })
}

export function formatDateTime(date: string | Date) {
  return new Date(date).toLocaleString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

export function formatRelativeTime(date: string | Date) {
  const now = new Date()
  const pastDate = new Date(date)
  const diffInSeconds = Math.floor((now.getTime() - pastDate.getTime()) / 1000)

  if (diffInSeconds < 60) {
    return "à l'instant"
  } else if (diffInSeconds < 3600) {
    const minutes = Math.floor(diffInSeconds / 60)
    return \`il y a \${minutes} minute\${minutes > 1 ? 's' : ''}\`
  } else if (diffInSeconds < 86400) {
    const hours = Math.floor(diffInSeconds / 3600)
    return \`il y a \${hours} heure\${hours > 1 ? 's' : ''}\`
  } else if (diffInSeconds < 2592000) {
    const days = Math.floor(diffInSeconds / 86400)
    return \`il y a \${days} jour\${days > 1 ? 's' : ''}\`
  } else if (diffInSeconds < 31536000) {
    const months = Math.floor(diffInSeconds / 2592000)
    return \`il y a \${months} mois\`
  } else {
    const years = Math.floor(diffInSeconds / 31536000)
    return \`il y a \${years} an\${years > 1 ? 's' : ''}\`
  }
}

export function generateSlug(text: string) {
  return text
    .toLowerCase()
    .replace(/[^\w\s-]/g, '') // Remove special characters
    .replace(/\s+/g, '-') // Replace spaces with hyphens
    .replace(/-+/g, '-') // Replace multiple hyphens with a single hyphen
    .trim() // Remove leading/trailing hyphens
}

export function truncateText(text: string, maxLength: number) {
  if (text.length <= maxLength) return text
  return text.slice(0, maxLength) + '...'
}
EOF

# Création de la page d'accueil
cat > src/app/page.tsx << EOF
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { 
  BookOpen, 
  ClipboardList, 
  Users, 
  MessageSquare, 
  BarChart3, 
  Clock,
  Star,
  ArrowRight,
  CheckCircle,
  Lightbulb,
  Award,
  TrendingUp
} from 'lucide-react'
import { supabase } from '@/lib/supabase'

async function getCourses() {
  const { data, error } = await supabase
    .from('course_details')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(6)

  if (error) {
    console.error('Error fetching courses:', error)
    return []
  }

  return data || []
}

async function getExams() {
  const { data, error } = await supabase
    .from('exams')
    .select('*')
    .eq('is_published', true)
    .order('created_at', { ascending: false })
    .limit(3)

  if (error) {
    console.error('Error fetching exams:', error)
    return []
  }

  return data || []
}

async function getForumPosts() {
  const { data, error } = await supabase
    .from('forum_posts')
    .select('*, users(full_name)')
    .order('created_at', { ascending: false })
    .limit(3)

  if (error) {
    console.error('Error fetching forum posts:', error)
    return []
  }

  return data || []
}

export default async function HomePage() {
  const courses = await getCourses()
  const exams = await getExams()
  const forumPosts = await getForumPosts()

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="relative bg-gradient-to-r from-primary-600 to-secondary-700 text-white">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-24 md:py-32">
          <div className="max-w-3xl">
            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold mb-6">
              Préparez-vous au <span className="text-accent-300">concours de résidanat</span> avec excellence
            </h1>
            <p className="text-xl mb-8 text-primary-100">
              Rejoignez la plateforme éducative leader en Algérie pour la préparation au concours de résidanat à Constantine. Cours, examens, forum et bien plus encore.
            </p>
            <div className="flex flex-col sm:flex-row gap-4">
              <Button asChild size="lg" className="bg-white text-primary-700 hover:bg-gray-100">
                <Link href="/auth/signup">
                  Commencer gratuitement
                </Link>
              </Button>
              <Button asChild variant="outline" size="lg" className="border-white text-white hover:bg-white hover:text-primary-700">
                <Link href="/courses">
                  Explorer les cours
                </Link>
              </Button>
            </div>
          </div>
        </div>
        <div className="absolute bottom-0 left-0 right-0 h-16 bg-gradient-to-t from-gray-50 to-transparent"></div>
      </section>

      {/* Features Section */}
      <section className="py-16 bg-gray-50">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
              Tout ce dont vous avez besoin pour réussir
            </h2>
            <p className="text-lg text-gray-600">
              Notre plateforme offre des outils complets pour vous aider à préparer efficacement le concours de résidanat.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
              <div className="w-12 h-12 rounded-lg bg-primary-100 flex items-center justify-center mb-4">
                <BookOpen className="h-6 w-6 text-primary-600" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Cours de qualité</h3>
              <p className="text-gray-600">
                Accédez à des cours complets et structurés par des experts de la médecine.
              </p>
            </div>

            <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
              <div className="w-12 h-12 rounded-lg bg-secondary-100 flex items-center justify-center mb-4">
                <ClipboardList className="h-6 w-6 text-secondary-600" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Examens pratiques</h3>
              <p className="text-gray-600">
                Entraînez-vous avec des examens simulés pour évaluer votre progression.
              </p>
            </div>

            <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
              <div className="w-12 h-12 rounded-lg bg-accent-100 flex items-center justify-center mb-4">
                <Users className="h-6 w-6 text-accent-600" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Groupes d'étude</h3>
              <p className="text-gray-600">
                Rejoignez des groupes d'étude pour collaborer et apprendre ensemble.
              </p>
            </div>

            <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
              <div className="w-12 h-12 rounded-lg bg-green-100 flex items-center justify-center mb-4">
                <MessageSquare className="h-6 w-6 text-green-600" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Forum communautaire</h3>
              <p className="text-gray-600">
                Posez des questions et partagez vos connaissances avec la communauté.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-16 bg-white">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            <div className="text-center">
              <div className="text-4xl font-bold text-primary-600 mb-2">500+</div>
              <div className="text-gray-600">Étudiants inscrits</div>
            </div>
            <div className="text-center">
              <div className="text-4xl font-bold text-secondary-600 mb-2">50+</div>
              <div className="text-gray-600">Cours disponibles</div>
            </div>
            <div className="text-center">
              <div className="text-4xl font-bold text-accent-600 mb-2">100+</div>
              <div className="text-gray-600">Examens pratiques</div>
            </div>
            <div className="text-center">
              <div className="text-4xl font-bold text-green-600 mb-2">95%</div>
              <div className="text-gray-600">Taux de réussite</div>
            </div>
          </div>
        </div>
      </section>

      {/* Courses Section */}
      <section className="py-16 bg-gray-50">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center mb-12">
            <div>
              <h2 className="text-3xl font-bold text-gray-900 mb-2">Cours populaires</h2>
              <p className="text-gray-600">Découvrez nos cours les plus appréciés par nos étudiants</p>
            </div>
            <Button asChild variant="outline">
              <Link href="/courses">
                Voir tous les cours
                <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {courses.map((course) => (
              <Card key={course.id} className="overflow-hidden hover:shadow-md transition-shadow">
                <div className="h-48 bg-gray-200 relative">
                  {course.thumbnail_url ? (
                    <img 
                      src={course.thumbnail_url} 
                      alt={course.title} 
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-primary-100 to-secondary-100">
                      <BookOpen className="h-16 w-16 text-primary-600" />
                    </div>
                  )}
                  <Badge className="absolute top-4 left-4 bg-white text-gray-800">
                    {course.category}
                  </Badge>
                </div>
                <CardHeader>
                  <CardTitle className="text-xl">{course.title}</CardTitle>
                  <CardDescription className="line-clamp-2">
                    {course.description}
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex justify-between items-center mb-4">
                    <div className="flex items-center text-sm text-gray-500">
                      <Clock className="mr-1 h-4 w-4" />
                      {course.lesson_count} leçons
                    </div>
                    <div className="flex items-center text-sm text-gray-500">
                      <Users className="mr-1 h-4 w-4" />
                      {course.student_count} étudiants
                    </div>
                  </div>
                  <Button asChild className="w-full">
                    <Link href={\`/courses/\${course.id}\`}>
                      Commencer le cours
                    </Link>
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Exams Section */}
      <section className="py-16 bg-white">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center mb-12">
            <div>
              <h2 className="text-3xl font-bold text-gray-900 mb-2">Examens récents</h2>
              <p className="text-gray-600">Testez vos connaissances avec nos derniers examens</p>
            </div>
            <Button asChild variant="outline">
              <Link href="/exams">
                Voir tous les examens
                <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {exams.map((exam) => (
              <Card key={exam.id} className="overflow-hidden hover:shadow-md transition-shadow">
                <CardHeader className="bg-gradient-to-r from-primary-50 to-secondary-50 pb-4">
                  <div className="flex justify-between items-start">
                    <Badge variant="outline" className="mb-2">
                      {exam.duration} minutes
                    </Badge>
                    <Badge className="bg-green-100 text-green-800">
                      Publié
                    </Badge>
                  </div>
                  <CardTitle className="text-xl">{exam.title}</CardTitle>
                  <CardDescription>
                    {exam.description || "Testez vos connaissances"}
                  </CardDescription>
                </CardHeader>
                <CardContent className="pt-6">
                  <Button asChild className="w-full">
                    <Link href={\`/exams/\${exam.id}\`}>
                      Commencer l'examen
                    </Link>
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Forum Section */}
      <section className="py-16 bg-gray-50">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center mb-12">
            <div>
              <h2 className="text-3xl font-bold text-gray-900 mb-2">Discussions récentes</h2>
              <p className="text-gray-600">Participez aux conversations de notre communauté</p>
            </div>
            <Button asChild variant="outline">
              <Link href="/forum">
                Voir le forum
                <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
          </div>

          <div className="bg-white rounded-xl shadow-sm overflow-hidden">
            {forumPosts.map((post) => (
              <div key={post.id} className="border-b border-gray-100 last:border-0 hover:bg-gray-50 transition-colors">
                <div className="p-6">
                  <div className="flex justify-between">
                    <div>
                      <div className="flex items-center mb-2">
                        <Badge className="mr-2">{post.category}</Badge>
                        {post.is_pinned && (
                          <Badge variant="outline" className="text-yellow-600 border-yellow-600">
                            Épinglé
                          </Badge>
                        )}
                      </div>
                      <h3 className="text-lg font-semibold text-gray-900 mb-2">
                        <Link href={\`/forum/\${post.id}\`} className="hover:text-primary-600 transition-colors">
                          {post.title}
                        </Link>
                      </h3>
                      <div className="flex items-center text-sm text-gray-500">
                        <span>Par {post.users?.full_name || 'Anonyme'}</span>
                        <span className="mx-2">•</span>
                        <span>{new Date(post.created_at).toLocaleDateString('fr-FR')}</span>
                      </div>
                    </div>
                    <Button asChild variant="ghost" size="sm">
                      <Link href={\`/forum/\${post.id}\`}>
                        Lire
                      </Link>
                    </Button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-gradient-to-r from-primary-600 to-secondary-700 text-white">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="max-w-3xl mx-auto text-center">
            <h2 className="text-3xl md:text-4xl font-bold mb-6">
              Prêt à commencer votre préparation ?
            </h2>
            <p className="text-xl mb-8 text-primary-100">
              Rejoignez des milliers d'étudiants qui ont déjà amélioré leurs résultats avec MedEduDz.
            </p>
            <Button asChild size="lg" className="bg-white text-primary-700 hover:bg-gray-100">
              <Link href="/auth/signup">
                Créer un compte gratuit
              </Link>
            </Button>
          </div>
        </div>
      </section>
    </div>
  )
}
EOF

# Création des pages d'authentification
mkdir -p src/app/auth/signin src/app/auth/signup

# Page de connexion
cat > src/app/auth/signin/page.tsx << EOF
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Loader2, Eye, EyeOff } from 'lucide-react'
import Link from 'next/link'

export default function SignInPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    try {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (error) {
        setError(error.message)
      } else {
        router.push('/dashboard')
      }
    } catch (err) {
      setError('Une erreur est survenue. Veuillez réessayer.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div className="text-center">
          <div className="flex justify-center">
            <div className="h-12 w-12 rounded-full bg-gradient-to-r from-primary-600 to-secondary-600 flex items-center justify-center">
              <span className="text-white font-bold">ME</span>
            </div>
          </div>
          <h2 className="mt-6 text-3xl font-extrabold text-gray-900">
            Connectez-vous à votre compte
          </h2>
          <p className="mt-2 text-sm text-gray-600">
            Ou{' '}
            <Link href="/auth/signup" className="font-medium text-primary-600 hover:text-primary-500">
              créez un nouveau compte
            </Link>
          </p>
        </div>

        <Card>
          <CardHeader className="space-y-1">
            <CardTitle className="text-2xl text-center">Connexion</CardTitle>
            <CardDescription className="text-center">
              Entrez vos informations pour vous connecter
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="nom@exemple.com"
                  required
                />
              </div>
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <Label htmlFor="password">Mot de passe</Label>
                  <Link href="/auth/forgot-password" className="text-sm text-primary-600 hover:text-primary-500">
                    Mot de passe oublié?
                  </Link>
                </div>
                <div className="relative">
                  <Input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    required
                  />
                  <button
                    type="button"
                    className="absolute inset-y-0 right-0 pr-3 flex items-center"
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? (
                      <EyeOff className="h-4 w-4 text-gray-400" />
                    ) : (
                      <Eye className="h-4 w-4 text-gray-400" />
                    )}
                  </button>
                </div>
              </div>

              {error && (
                <Alert variant="destructive">
                  <AlertDescription>{error}</AlertDescription>
                </Alert>
              )}

              <Button type="submit" className="w-full" disabled={loading}>
                {loading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Connexion en cours...
                  </>
                ) : (
                  'Se connecter'
                )}
              </Button>
            </form>

            <div className="mt-6">
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-gray-300" />
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-2 bg-card text-muted-foreground">Ou continuer avec</span>
                </div>
              </div>

              <div className="mt-6 grid grid-cols-2 gap-3">
                <Button variant="outline" className="w-full">
                  <svg className="w-5 h-5" viewBox="0 0 24 24">
                    <path
                      fill="currentColor"
                      d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                    />
                    <path
                      fill="currentColor"
                      d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                    />
                    <path
                      fill="currentColor"
                      d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                    />
                    <path
                      fill="currentColor"
                      d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                    />
                  </svg>
                  <span className="ml-2">Google</span>
                </Button>
                <Button variant="outline" className="w-full">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12.017 0C5.396 0 .029 5.367.029 11.987c0 5.079 3.158 9.417 7.618 11.024-.105-.949-.199-2.403.041-3.439.219-.937 1.219-5.175 1.219-5.175s-.311-.623-.311-1.543c0-1.446.839-2.526 1.885-2.526.888 0 1.318.666 1.318 1.466 0 .893-.568 2.229-.861 3.467-.245 1.04.52 1.888 1.546 1.888 1.856 0 3.283-1.958 3.283-4.789 0-2.503-1.799-4.253-4.37-4.253-2.977 0-4.727 2.234-4.727 4.546 0 .9.347 1.863.781 2.387.085.104.098.195.072.301-.079.329-.254 1.037-.289 1.183-.047.196-.153.238-.353.144-1.314-.612-2.137-2.536-2.137-4.078 0-3.298 2.394-6.325 6.901-6.325 3.628 0 6.44 2.586 6.44 6.043 0 3.607-2.274 6.505-5.431 6.505-1.06 0-2.057-.552-2.396-1.209 0 0-.523 1.992-.65 2.479-.235.9-.871 2.028-1.297 2.717.976.301 2.018.461 3.096.461 6.624 0 11.99-5.367 11.99-11.987C24.007 5.367 18.641.001 12.017.001z" />
                  </svg>
                  <span className="ml-2">Facebook</span>
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
EOF

# Page d'inscription
cat > src/app/auth/signup/page.tsx << EOF
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Loader2, Eye, EyeOff } from 'lucide-react'
import Link from 'next/link'

export default function SignUpPage() {
  const [fullName, setFullName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [role, setRole] = useState('student')
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    if (password !== confirmPassword) {
      setError('Les mots de passe ne correspondent pas')
      setLoading(false)
      return
    }

    try {
      const { error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: fullName,
            role: role,
          },
        },
      })

      if (error) {
        setError(error.message)
      } else {
        setSuccess(true)
      }
    } catch (err) {
      setError('Une erreur est survenue. Veuillez réessayer.')
    } finally {
      setLoading(false)
    }
  }

  if (success) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-md w-full space-y-8">
          <div className="text-center">
            <div className="flex justify-center">
              <div className="h-16 w-16 rounded-full bg-green-100 flex items-center justify-center">
                <svg className="h-8 w-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7"></path>
                </svg>
              </div>
            </div>
            <h2 className="mt-6 text-3xl font-extrabold text-gray-900">
              Inscription réussie!
            </h2>
            <p className="mt-2 text-sm text-gray-600">
              Un email de confirmation a été envoyé à {email}. Veuillez vérifier votre boîte de réception et cliquer sur le lien pour activer votre compte.
            </p>
          </div>
          <div className="mt-6">
            <Button asChild className="w-full">
              <Link href="/auth/signin">
                Se connecter
              </Link>
            </Button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div className="text-center">
          <div className="flex justify-center">
            <div className="h-12 w-12 rounded-full bg-gradient-to-r from-primary-600 to-secondary-600 flex items-center justify-center">
              <span className="text-white font-bold">ME</span>
            </div>
          </div>
          <h2 className="mt-6 text-3xl font-extrabold text-gray-900">
            Créez votre compte
          </h2>
          <p className="mt-2 text-sm text-gray-600">
            Déjà un compte?{' '}
            <Link href="/auth/signin" className="font-medium text-primary-600 hover:text-primary-500">
              Connectez-vous
            </Link>
          </p>
        </div>

        <Card>
          <CardHeader className="space-y-1">
            <CardTitle className="text-2xl text-center">Inscription</CardTitle>
            <CardDescription className="text-center">
              Entrez vos informations pour créer un compte
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="fullName">Nom complet</Label>
                <Input
                  id="fullName"
                  type="text"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  placeholder="Jean Dupont"
                  required
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="nom@exemple.com"
                  required
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="role">Rôle</Label>
                <Select value={role} onValueChange={setRole}>
                  <SelectTrigger>
                    <SelectValue placeholder="Sélectionnez un rôle" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="student">Étudiant</SelectItem>
                    <SelectItem value="teacher">Enseignant</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="password">Mot de passe</Label>
                <div className="relative">
                  <Input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    required
                  />
                  <button
                    type="button"
                    className="absolute inset-y-0 right-0 pr-3 flex items-center"
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? (
                      <EyeOff className="h-4 w-4 text-gray-400" />
                    ) : (
                      <Eye className="h-4 w-4 text-gray-400" />
                    )}
                  </button>
                </div>
              </div>
              <div className="space-y-2">
                <Label htmlFor="confirmPassword">Confirmer le mot de passe</Label>
                <div className="relative">
                  <Input
                    id="confirmPassword"
                    type={showConfirmPassword ? 'text' : 'password'}
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    placeholder="••••••••"
                    required
                  />
                  <button
                    type="button"
                    className="absolute inset-y-0 right-0 pr-3 flex items-center"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                  >
                    {showConfirmPassword ? (
                      <EyeOff className="h-4 w-4 text-gray-400" />
                    ) : (
                      <Eye className="h-4 w-4 text-gray-400" />
                    )}
                  </button>
                </div>
              </div>

              {error && (
                <Alert variant="destructive">
                  <AlertDescription>{error}</AlertDescription>
                </Alert>
              )}

              <Button type="submit" className="w-full" disabled={loading}>
                {loading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Création du compte...
                  </>
                ) : (
                  "S'inscrire"
                )}
              </Button>
            </form>

            <div className="mt-6">
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-gray-300" />
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-2 bg-card text-muted-foreground">Ou continuer avec</span>
                </div>
              </div>

              <div className="mt-6 grid grid-cols-2 gap-3">
                <Button variant="outline" className="w-full">
                  <svg className="w-5 h-5" viewBox="0 0 24 24">
                    <path
                      fill="currentColor"
                      d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                    />
                    <path
                      fill="currentColor"
                      d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                    />
                    <path
                      fill="currentColor"
                      d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                    />
                    <path
                      fill="currentColor"
                      d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                    />
                  </svg>
                  <span className="ml-2">Google</span>
                </Button>
                <Button variant="outline" className="w-full">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12.017 0C5.396 0 .029 5.367.029 11.987c0 5.079 3.158 9.417 7.618 11.024-.105-.949-.199-2.403.041-3.439.219-.937 1.219-5.175 1.219-5.175s-.311-.623-.311-1.543c0-1.446.839-2.526 1.885-2.526.888 0 1.318.666 1.318 1.466 0 .893-.568 2.229-.861 3.467-.245 1.04.52 1.888 1.546 1.888 1.856 0 3.283-1.958 3.283-4.789 0-2.503-1.799-4.253-4.37-4.253-2.977 0-4.727 2.234-4.727 4.546 0 .9.347 1.863.781 2.387.085.104.098.195.072.301-.079.329-.254 1.037-.289 1.183-.047.196-.153.238-.353.144-1.314-.612-2.137-2.536-2.137-4.078 0-3.298 2.394-6.325 6.901-6.325 3.628 0 6.44 2.586 6.44 6.043 0 3.607-2.274 6.505-5.431 6.505-1.06 0-2.057-.552-2.396-1.209 0 0-.523 1.992-.65 2.479-.235.9-.871 2.028-1.297 2.717.976.301 2.018.461 3.096.461 6.624 0 11.99-5.367 11.99-11.987C24.007 5.367 18.641.001 12.017.001z" />
                  </svg>
                  <span className="ml-2">Facebook</span>
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
EOF

# Création du fichier vercel.json
cat > vercel.json << EOF
{
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "installCommand": "npm install",
  "env": {
    "NEXT_PUBLIC_SUPABASE_URL": "@supabase_url",
    "NEXT_PUBLIC_SUPABASE_ANON_KEY": "@supabase_anon_key",
    "SUPABASE_SERVICE_ROLE_KEY": "@supabase_service_role_key",
    "NEXTAUTH_URL": "@nextauth_url",
    "NEXTAUTH_SECRET": "@nextauth_secret"
  }
}
EOF

# Création du fichier README.md
cat > README.md << EOF
# MedEduDz - Plateforme éducative pour le concours de résidanat

MedEduDz est une plateforme éducative complète conçue pour aider les étudiants en médecine à préparer le concours de résidanat à Constantine, en Algérie.

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
- **Authentification**: Supabase Auth
- **Déploiement**: Vercel

## Installation

### Prérequis

- Node.js 18+ 
- npm ou yarn
- Un compte Supabase

### Configuration

1. Clonez ce dépôt
   \`\`\`bash
   git clone https://github.com/votre-username/MedEduDz.git
   cd MedEduDz
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
MedEduDz/
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
EOF

# Création du fichier .gitignore
cat > .gitignore << EOF
# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# next.js
/.next/
/out/

# production
/build

# misc
.DS_Store
*.pem

# debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# local env files
.env*.local

# vercel
.vercel

# typescript
*.tsbuildinfo
next-env.d.ts
EOF

echo "✅ Structure du projet créée avec succès!"
echo ""
echo "Prochaines étapes :"
echo "1. Configurez vos variables d'environnement dans .env.local"
echo "2. Créez un projet Supabase et exécutez le script SQL dans supabase/migrations/"
echo "3. Lancez le serveur de développement avec 'npm run dev'"
echo "4. Déployez sur Vercel en suivant les instructions du README.md"
