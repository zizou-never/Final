'use client'
import { useEffect, useState } from 'react'
import { useRouter, useSearchParams, useParams } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Checkbox } from '@/components/ui/checkbox'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import { Progress } from '@/components/ui/progress'
export default function Page() {
  const { bank } = useParams<{ bank: 'general' | 'residanat' }>()
  const router = useRouter()
  const sp = useSearchParams()
  const [chapters, setChapters] = useState<any[]>([])
  const [modules, setModules] = useState<any[]>([])
  const [selectedChapter, setSelectedChapter] = useState<string>(sp.get('chapter') || '')
  const [selectedModule, setSelectedModule] = useState<string>(sp.get('module') || '')
  const [year, setYear] = useState<string>(sp.get('year') || '')
  const [difficulty, setDifficulty] = useState<string>(sp.get('difficulty') || '')
  const [onlyUnseen, setOnlyUnseen] = useState<boolean>(sp.get('unseen') === '1')
  useEffect(() => { supabase.from('chapters').select('id, slug, title').then(({ data }) => setChapters(data ?? [])) }, [])
  useEffect(() => {
    if (!selectedChapter) { setModules([]); return; }
    supabase.from('modules').select('id, slug, title, chapter_id').eq('chapter_id', selectedChapter).then(({ data }) => setModules(data ?? []))
  }, [selectedChapter])
  const canSetYear = bank === 'general'
  const startSession = async () => {
    console.log("Starting session with filters:", { bank, selectedChapter, selectedModule, year, difficulty, onlyUnseen });
    alert('Session creation logic to be implemented.');
  }
  return (
    <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="max-w-3xl mb-8"><h1 className="text-3xl font-bold mb-2">Qbank {bank === 'general' ? 'Générale' : 'Résidanat'}</h1><p className="text-gray-600">{bank === 'general' ? 'Questions de toutes les années (1–6). Filtrez par année, chapitre, module…' : 'Questions ciblées sur les cours inclus dans le Résidanat.'}</p></div>
      <div className="grid lg:grid-cols-12 gap-8">
        <div className="lg:col-span-4">
          <Card><CardContent className="p-5 space-y-5">
              <div><p className="text-sm font-medium mb-1">Chapitre</p><Select value={selectedChapter} onValueChange={(v) => { setSelectedChapter(v); setSelectedModule('') }}><SelectTrigger><SelectValue placeholder="Choisir un chapitre" /></SelectTrigger><SelectContent>{chapters.map((c) => (<SelectItem key={c.id} value={c.id}>{c.title}</SelectItem>))}</SelectContent></Select></div>
              <div><p className="text-sm font-medium mb-1">Module</p><Select value={selectedModule} onValueChange={setSelectedModule} disabled={!selectedChapter}><SelectTrigger><SelectValue placeholder={selectedChapter ? 'Choisir un module' : 'Sélectionnez d’abord un chapitre'} /></SelectTrigger><SelectContent>{modules.map((m) => (<SelectItem key={m.id} value={m.id}>{m.title}</SelectItem>))}</SelectContent></Select></div>
              <div><p className="text-sm font-medium mb-1">Difficulté</p><Select value={difficulty} onValueChange={setDifficulty}><SelectTrigger><SelectValue placeholder="Toutes" /></SelectTrigger><SelectContent><SelectItem value="all">Toutes</SelectItem><SelectItem value="1">1</SelectItem><SelectItem value="2">2</SelectItem><SelectItem value="3">3</SelectItem><SelectItem value="4">4</SelectItem><SelectItem value="5">5</SelectItem></SelectContent></Select></div>
              <div className={canSetYear ? '' : 'opacity-50'}><p className="text-sm font-medium mb-1">Année</p><Select value={year} onValueChange={setYear} disabled={!canSetYear}><SelectTrigger><SelectValue placeholder="Toutes" /></SelectTrigger><SelectContent><SelectItem value="all">Toutes</SelectItem><SelectItem value="1">1</SelectItem><SelectItem value="2">2</SelectItem><SelectItem value="3">3</SelectItem><SelectItem value="4">4</SelectItem><SelectItem value="5">5</SelectItem><SelectItem value="6">6</SelectItem></SelectContent></Select></div>
              <div className="flex items-center gap-2"><Checkbox id="unseen" checked={onlyUnseen} onCheckedChange={(v) => setOnlyUnseen(Boolean(v))} /><label htmlFor="unseen" className="text-sm">Uniquement non vues</label></div>
              <Separator />
              <Button className="w-full" onClick={startSession}>Démarrer une session</Button>
          </CardContent></Card>
        </div>
        <div className="lg:col-span-8"><Card><CardContent className="p-5"><p className="font-semibold mb-2">Aperçu</p><p className="text-sm text-gray-600 mb-4">Calcul du nombre de questions...</p></CardContent></Card></div>
      </div>
    </div>
  )
}
