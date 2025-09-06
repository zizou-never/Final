import Link from 'next/link'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Brain, GraduationCap } from 'lucide-react'
export default function Page() {
  return (
    <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="max-w-3xl mb-10"><h1 className="text-4xl font-bold mb-3">Qbank</h1><p className="text-gray-600">Entraînez-vous avec des QCM ciblés: générale (6 années) et spéciale Résidanat.</p></div>
      <div className="grid md:grid-cols-2 gap-6">
        <Card className="hover:shadow-md transition-all"><CardHeader><CardTitle className="flex items-center gap-2"><GraduationCap className="h-5 w-5 text-primary-600" />Qbank Générale</CardTitle></CardHeader><CardContent><p className="text-gray-600 mb-3">Contient tous les modules des 6 années d’études.</p><Badge variant="secondary" className="mb-4">Années 1 à 6</Badge><div><Link className="text-primary-700 font-medium hover:underline" href="/qbank/general">Explorer →</Link></div></CardContent></Card>
        <Card className="hover:shadow-md transition-all"><CardHeader><CardTitle className="flex items-center gap-2"><Brain className="h-5 w-5 text-primary-600" />Qbank Résidanat</CardTitle></CardHeader><CardContent><p className="text-gray-600 mb-3">Ciblée sur les cours inclus dans le Résidanat.</p><Badge variant="secondary" className="mb-4">Ciblage concours</Badge><div><Link className="text-primary-700 font-medium hover:underline" href="/qbank/residanat">Explorer →</Link></div></CardContent></Card>
      </div>
    </div>
  )
}
