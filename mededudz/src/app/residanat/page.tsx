import Link from 'next/link'
import { supabase } from '@/lib/supabase'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Breadcrumb, BreadcrumbItem, BreadcrumbLink, BreadcrumbList, BreadcrumbPage, BreadcrumbSeparator } from '@/components/ui/breadcrumb'
import { BookOpen, Stethoscope, Scissors } from 'lucide-react'
async function getChapters() {
  const { data, error } = await supabase.from('chapters').select('id, slug, title, description').order('sort_order', { ascending: true })
  if (error) { console.error(error); return [] }
  return data ?? []
}
const chapterIcon: Record<string, any> = { biologie: BookOpen, clinique: Stethoscope, chirurgie: Scissors }
export default async function Page() {
  const chapters = await getChapters()
  return (
    <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <Breadcrumb><BreadcrumbList><BreadcrumbItem><BreadcrumbLink href="/">Accueil</BreadcrumbLink></BreadcrumbItem><BreadcrumbSeparator /><BreadcrumbItem><BreadcrumbPage>Résidanat</BreadcrumbPage></BreadcrumbItem></BreadcrumbList></Breadcrumb>
      <div className="max-w-3xl mt-6 mb-10"><h1 className="text-4xl font-bold mb-3">Parcours Résidanat</h1><p className="text-gray-600">Trois chapitres majeurs — Biologie, Clinique et Chirurgie — organisés en modules et cours ciblés.</p></div>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {chapters.map((ch) => {
          const Icon = chapterIcon[ch.slug] ?? BookOpen
          return (
            <Card key={ch.id} className="hover:shadow-md transition-all">
              <CardHeader><div className="flex items-center gap-2"><div className="h-10 w-10 rounded-lg bg-primary-50 flex items-center justify-center"><Icon className="h-5 w-5 text-primary-600" /></div><CardTitle>{ch.title}</CardTitle></div></CardHeader>
              <CardContent><p className="text-gray-600 mb-4">{ch.description}</p><Badge variant="secondary" className="mb-4">Modules organisés</Badge><div><Link className="text-primary-700 font-medium hover:underline" href={`/residanat/${ch.slug}`}>Voir les modules →</Link></div></CardContent>
            </Card>
          )
        })}
        {chapters.length === 0 && <Card><CardContent className="py-10 text-gray-500">Aucun chapitre — ajoute Biologie, Clinique, Chirurgie.</CardContent></Card>}
      </div>
    </div>
  )
}
