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

export default async function HomePage() {
  const courses = await getCourses()
  const exams = await getExams()

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
              Rejoignez la plateforme éducative leader en Algérie pour la préparation du concours de résidanat à Constantine. Cours, examens, forum et bien plus encore.
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

      {/* CTA Section */}
      <section className="py-16 bg-gradient-to-r from-primary-600 to-secondary-700 text-white">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="max-w-3xl mx-auto text-center">
            <h2 className="text-3xl md:text-4xl font-bold mb-6">
              Prêt à commencer votre préparation ?
            </h2>
            <p className="text-xl mb-8 text-primary-100">
              Rejoignez des milliers d'étudiants qui ont déjà amélioré leurs résultats avec mededudz.
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
