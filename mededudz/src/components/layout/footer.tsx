import Link from 'next/link'
import { Facebook, Twitter, Instagram, Youtube, Mail, Phone, MapPin } from 'lucide-react'

export function Footer() {
  return (
    <footer className="bg-dark-900 text-white">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div className="col-span-1 md:col-span-2">
            <div className="flex items-center mb-4">
              <div className="h-10 w-10 rounded-full bg-gradient-to-r from-primary-600 to-secondary-600 flex items-center justify-center">
                <span className="text-white font-bold">ME</span>
              </div>
              <span className="ml-2 text-2xl font-bold">mededudz</span>
            </div>
            <p className="text-gray-300 mb-4 max-w-md">
              Plateforme éducative dédiée à la préparation du concours de résidanat à Constantine. 
              Nous offrons des cours de qualité, des examens pratiques et une communauté d'apprentissage.
            </p>
            <div className="flex space-x-4">
              <a href="#" className="text-gray-400 hover:text-white transition-colors">
                <Facebook className="h-6 w-6" />
                <span className="sr-only">Facebook</span>
              </a>
              <a href="#" className="text-gray-400 hover:text-white transition-colors">
                <Twitter className="h-6 w-6" />
                <span className="sr-only">Twitter</span>
              </a>
              <a href="#" className="text-gray-400 hover:text-white transition-colors">
                <Instagram className="h-6 w-6" />
                <span className="sr-only">Instagram</span>
              </a>
              <a href="#" className="text-gray-400 hover:text-white transition-colors">
                <Youtube className="h-6 w-6" />
                <span className="sr-only">YouTube</span>
              </a>
            </div>
          </div>

          <div>
            <h3 className="text-lg font-semibold mb-4">Liens rapides</h3>
            <ul className="space-y-2">
              <li>
                <Link href="/" className="text-gray-300 hover:text-white transition-colors">
                  Accueil
                </Link>
              </li>
              <li>
                <Link href="/courses" className="text-gray-300 hover:text-white transition-colors">
                  Cours
                </Link>
              </li>
              <li>
                <Link href="/exams" className="text-gray-300 hover:text-white transition-colors">
                  Examens
                </Link>
              </li>
              <li>
                <Link href="/forum" className="text-gray-300 hover:text-white transition-colors">
                  Forum
                </Link>
              </li>
              <li>
                <Link href="/groups" className="text-gray-300 hover:text-white transition-colors">
                  Groupes d'étude
                </Link>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="text-lg font-semibold mb-4">Contact</h3>
            <ul className="space-y-3">
              <li className="flex items-start">
                <MapPin className="h-5 w-5 text-primary-400 mr-2 mt-0.5" />
                <span className="text-gray-300">Université Constantine 1, Algérie</span>
              </li>
              <li className="flex items-center">
                <Mail className="h-5 w-5 text-primary-400 mr-2" />
                <span className="text-gray-300">contact@mededudz.com</span>
              </li>
              <li className="flex items-center">
                <Phone className="h-5 w-5 text-primary-400 mr-2" />
                <span className="text-gray-300">+213 123 456 789</span>
              </li>
            </ul>
          </div>
        </div>

        <div className="border-t border-gray-800 mt-8 pt-8 flex flex-col md:flex-row justify-between items-center">
          <p className="text-gray-400 text-sm">
            © {new Date().getFullYear()} mededudz. Tous droits réservés.
          </p>
          <div className="flex space-x-6 mt-4 md:mt-0">
            <Link href="/privacy" className="text-gray-400 hover:text-white text-sm transition-colors">
              Politique de confidentialité
            </Link>
            <Link href="/terms" className="text-gray-400 hover:text-white text-sm transition-colors">
              Conditions d'utilisation
            </Link>
            <Link href="/cookies" className="text-gray-400 hover:text-white text-sm transition-colors">
              Cookies
            </Link>
          </div>
        </div>
      </div>
    </footer>
  )
}
