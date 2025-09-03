import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Toaster } from 'react-hot-toast'
import { AuthProviderComponent } from '@/components/auth-provider'
import { Navbar } from '@/components/layout/navbar'
import { Footer } from '@/components/layout/footer'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'mededudz - Plateforme éducative pour le concours de résidanat',
  description: 'Préparez-vous efficacement au concours de résidanat à Constantine avec nos cours, examens et ressources pédagogiques.',
  keywords: ['résidanat', 'médecine', 'Constantine', 'concours', 'éducation', 'cours', 'examens'],
  authors: [{ name: 'mededudz Team' }],
  openGraph: {
    title: 'mededudz - Plateforme éducative pour le concours de résidanat',
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
        <AuthProviderComponent>
          <div className="min-h-screen flex flex-col bg-gray-50">
            <Navbar />
            <main className="flex-1">
              {children}
            </main>
            <Footer />
          </div>
          <Toaster position="top-right" />
        </AuthProviderComponent>
      </body>
    </html>
  )
}
