export interface User {
  id: string
  email: string
  full_name: string
  avatar_url?: string
  role: 'student' | 'teacher' | 'admin'
  created_at: string
}

export interface Profile {
  id: string
  user_id: string
  full_name?: string
  avatar_url?: string
  bio?: string
  created_at: string
  updated_at: string
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
