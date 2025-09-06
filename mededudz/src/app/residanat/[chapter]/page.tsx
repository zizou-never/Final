import Link from 'next/link'
import { notFound } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Breadcrumb, BreadcrumbItem, BreadcrumbLink, BreadcrumbList, BreadcrumbPage, BreadcrumbSeparator } from '@/components/ui/breadcrumb'
async function getChapter(slug: string) {
  const { data, error } = await supabase.from('chapters').select('id, slug, title, description').eq('slug', slug).maybeSingle()
  if (error) console.error(error)
  return data
}
async function getModules(chapterId: string) {
  const { data, error } = await supabase.from('modules').select('id, slug, title, description, year_min, year_max').eq('chapter_id', chapterId).order('sort_order', { ascending: true })
  if (error) { console.error(error); return [] }
  return data ?? []
}
export default async function Page({ params }: { params: { chapter: string }}) {
  const chapter = await getChapter(params.chapter)
  if (!chapter) return notFound()
  const modules = await getModules(chapter.id)
  return (
    <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <Breadcrumb><BreadcrumbList><BreadcrumbItem><BreadcrumbLink href="/">Accueil</BreadcrumbLink></BreadcrumbItem><BreadcrumbSeparator /><BreadcrumbItem><BreadcrumbLink href="/residanat">Résidanat</BreadcrumbLink></BreadcrumbItem><BreadcrumbSeparator /><BreadcrumbItem><BreadcrumbPage>{chapter.title}</BreadcrumbPage></BreadcrumbItem></BreadcrumbList></Breadcrumb>
      <div className="max-w-3xl mt-6 mb-8"><h1 className="text-3xl font-bold mb-2">{chapter.title}</h1><p className="text-gray-600">{chapter.description}</p></div>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {modules.map((m) => (
          <Card key={m.id} className="hover:shadow-md transition-all">
            <CardHeader><CardTitle className="text-lg">{m.title}</CardTitle></CardHeader>
            <CardContent><p className="text-gray-600 mb-4 line-clamp-3">{m.description}</p><p className="text-sm text-gray-500 mb-4">Années: {m.year_min ?? '—'}{m.year_max ? `–${m.year_max}` : ''}</p><Link href={`/residanat/${chapter.slug}/${m.slug}`} className="text-primary-700 font-medium hover:underline">Voir les cours →</Link></CardContent>
          </Card>
        ))}
        {modules.length === 0 && <Card><CardContent className="py-10 text-gray-500">Aucun module.</CardContent></Card>}
      </div>
    </div>
  )
}
