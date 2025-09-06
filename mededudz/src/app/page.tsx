'use client'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { ArrowRight, Brain, BookOpen, BarChart3, MessageSquare } from 'lucide-react'

export default function HomePage() {
  return (
    <>
      <section className="relative bg-gray-50 overflow-hidden">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 pt-28 pb-16 md:pt-36 md:pb-24 text-center">
            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight mb-6">
              Votre Qbank et cours pour le résidanat de Constantine
            </h1>
            <p className="text-lg md:text-xl text-gray-600 mb-8 max-w-3xl mx-auto">
              Tout-en-un pour préparer efficacement: questions validées, explications, cours structurés et suivi de progression.
            </p>
            <div className="flex flex-col sm:flex-row gap-3 justify-center">
              <Button asChild size="lg" className="bg-primary-600 hover:bg-primary-700">
                <Link href="/auth/signup">Commencer gratuitement</Link>
              </Button>
              <Button asChild size="lg" variant="outline" className="border-gray-300">
                <Link href="/qbank">
                  Explorer la Qbank
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
            </div>
        </div>
      </section>
      <section className="py-16 bg-white">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-12">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">Tout ce qu’il faut pour réussir</h2>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div className="bg-white rounded-xl p-6 text-center">
              <Brain className="h-8 w-8 text-primary-600 mx-auto mb-3" />
              <h3 className="text-lg font-semibold mb-1">Qbank validée</h3>
              <p className="text-gray-600 text-sm">QCM au format concours, corrections détaillées.</p>
            </div>
            <div className="bg-white rounded-xl p-6 text-center">
              <BookOpen className="h-8 w-8 text-primary-600 mx-auto mb-3" />
              <h3 className="text-lg font-semibold mb-1">Cours structurés</h3>
              <p className="text-gray-600 text-sm">Synthèses ciblées, fiches, vidéos et tableaux.</p>
            </div>
            <div className="bg-white rounded-xl p-6 text-center">
              <BarChart3 className="h-8 w-8 text-primary-600 mx-auto mb-3" />
              <h3 className="text-lg font-semibold mb-1">Stats & suivi</h3>
              <p className="text-gray-600 text-sm">Courbe de progression, points faibles, révisions.</p>
            </div>
            <div className="bg-white rounded-xl p-6 text-center">
              <MessageSquare className="h-8 w-8 text-primary-600 mx-auto mb-3" />
              <h3 className="text-lg font-semibold mb-1">Communauté</h3>
              <p className="text-gray-600 text-sm">Forum d’entraide, groupes d’étude, Q&R.</p>
            </div>
          </div>
        </div>
      </section>
    </>
  )
}
