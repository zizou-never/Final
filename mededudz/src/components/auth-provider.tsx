'use client'

import { AuthProvider } from '@/hooks/use-auth'

export function AuthProviderComponent({ children }: { children: React.ReactNode }) {
  return <AuthProvider>{children}</AuthProvider>
}
