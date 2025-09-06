import Link from 'next/link'

export function Footer() {
  return (
    <footer className="border-t border-gray-200 bg-white">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <div className="grid md:grid-cols-4 gap-8">
          <div>
            <div className="flex items-center gap-2 mb-3">
              <div className="h-8 w-8 rounded-lg bg-blue-500" />
              <span className="font-bold text-lg">mededudz</span>
            </div>
            <p className="text-sm text-gray-600">
              Plateforme pour la préparation du concours de résidanat.
            </p>
          </div>
          <div>
            <p className="font-semibold mb-2">Produit</p>
            <ul className="space-y-2 text-sm text-gray-600">
              <li><Link href="/qbank">Qbank</Link></li>
              <li><Link href="/residanat">Résidanat</Link></li>
            </ul>
          </div>
          <div>
            <p className="font-semibold mb-2">Ressources</p>
            <ul className="space-y-2 text-sm text-gray-600">
              <li><Link href="/faq">FAQ</Link></li>
            </ul>
          </div>
          <div>
            <p className="font-semibold mb-2">Légal</p>
            <ul className="space-y-2 text-sm text-gray-600">
              <li><Link href="/legal/cgu">Conditions</Link></li>
            </ul>
          </div>
        </div>
        <div className="mt-8 border-t border-gray-100 pt-4 text-xs text-gray-500 text-center">
          © {new Date().getFullYear()} mededudz — Tous droits réservés.
        </div>
      </div>
    </footer>
  )
}
