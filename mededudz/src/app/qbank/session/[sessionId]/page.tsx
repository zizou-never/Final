'use client'
import { useEffect, useState } from 'react'
import { useParams } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { Skeleton } from '@/components/ui/skeleton'
export default function Page() {
  const { sessionId } = useParams<{ sessionId: string }>()
  const [loading, setLoading] = useState(true)
  const [index, setIndex] = useState(0)
  const [questions, setQuestions] = useState<any[]>([])
  useEffect(() => {
    const fetchData = async () => {
      if (!sessionId) return;
      setLoading(true);
      const { data } = await supabase.from('qbank_session_questions').select(`id, index, question: qbank_questions (id, stem, explanation, difficulty, choices: qbank_choices (id, label, is_correct))`).eq('session_id', sessionId).order('index', { ascending: true })
      setQuestions(data ?? [])
      setLoading(false)
    }
    fetchData()
  }, [sessionId])
  if (loading) return (<div className="container mx-auto px-4 py-10"><Skeleton className="h-8 w-1/4 mb-4" /><Skeleton className="h-64 w-full mb-4" /><Skeleton className="h-32 w-full" /></div>)
  if (questions.length === 0) return <div className="container mx-auto px-4 py-10">Session invalide ou aucune question trouvée.</div>
  const q = questions[index]
  const progress = Math.round(((index + 1) / questions.length) * 100)
  return (
    <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-6">
      <div className="flex items-center justify-between mb-4"><div className="text-sm text-gray-600">Session {sessionId.substring(0, 8)}...</div><div className="w-64"><Progress value={progress} /></div></div>
      <Card className="mb-4"><CardContent className="p-5">
          <div className="flex items-center justify-between mb-3"><Badge variant="secondary">Question {index + 1} / {questions.length}</Badge><Badge variant="secondary">Difficulté {q?.question?.difficulty ?? '-'}</Badge></div>
          <p className="font-medium mb-4">{q?.question?.stem}</p>
          <div className="space-y-2">{(q?.question?.choices ?? []).map((c: any) => (<button key={c.id} className="w-full text-left rounded-lg border border-gray-200 px-3 py-2 hover:border-primary-300 hover:bg-primary-50 transition">{c.label}</button>))}</div>
          <div className="mt-4 flex items-center justify-between">
            <Button variant="outline" disabled={index === 0} onClick={() => setIndex((i) => Math.max(0, i - 1))}>Précédent</Button>
            <div className="flex gap-2"><Button variant="secondary">Révéler correction</Button><Button onClick={() => setIndex((i) => Math.min(questions.length - 1, i + 1))} disabled={index >= questions.length - 1}>Suivant</Button></div>
          </div>
      </CardContent></Card>
      <Card><CardContent className="p-5"><p className="font-semibold mb-2">Explication</p><p className="text-gray-700">{q?.question?.explanation ?? 'La correction sera affichée après avoir répondu.'}</p></CardContent></Card>
    </div>
  )
}
