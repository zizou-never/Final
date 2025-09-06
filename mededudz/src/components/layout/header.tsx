import Link from 'next/link'
import Image from 'next/image'
import { Button } from '@/components/ui/button'

export function Header() {
  return (
    <header className="sticky top-0 z-40 w-full border-b border-gray-200 bg-white/70 backdrop-blur supports-[backdrop-filter]:bg-white/60">
      <div className="container mx-auto flex h-16 items-center justify-between px-4 sm:px-6 lg:px-8">
        <Link href="/" className="flex items-center gap-2">
          <Image 
            src="/images/logo.png"
            alt="Mededudz Logo"
            width={32}
            height={32}
          />
          <span className="font-bold text-lg">mededudz</span>
        </Link>
        <nav className="hidden md:flex items-center gap-6 text-sm">
          <Link href="/qbank" className="text-gray-700 hover:text-gray-900 transition-colors">Qbank</Link>
          <Link href="/residanat" className="text-gray-700 hover:text-gray-900 transition-colors">Résidanat</Link>
        </nav>
        <div className="flex items-center gap-2">
          <Button asChild variant="ghost" className="hidden sm:inline-flex">
            <Link href="/auth/signin">Se connecter</Link>
          </Button>
          <Button asChild>
            <Link href="/auth/signup">S’inscrire</Link>
          </Button>
        </div>
      </div>
    </header>
  )
}
