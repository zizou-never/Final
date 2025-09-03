-- Création des tables pour la plateforme éducative mededudz

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

-- Création d'une fonction pour mettre à jour le champ updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Création de triggers pour mettre à jour updated_at automatiquement
CREATE TRIGGER handle_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER handle_courses_updated_at BEFORE UPDATE ON public.courses FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

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

-- Création de la fonction pour gérer les nouveaux utilisateurs
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

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
  ('00000000-0000-0000-0000-000000000012', 'Pharmacologie', 'Étude des médicaments, leurs mécanismes d''action, leurs effets et leur utilisation thérapeutique.', 'Médecine', '00000000-0000-0000-0000-000000000003', 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80');
