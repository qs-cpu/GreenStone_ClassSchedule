const FORBIDDEN_HOSTS = ['localhost', '127.0.0.1', '0.0.0.0', '::1']
const FORBIDDEN_PROTOCOLS = ['http:', 'https:']

export function validateUrl(url: string): void {
  const parsed = new URL(url)

  if (!FORBIDDEN_PROTOCOLS.includes(parsed.protocol)) {
    throw new Error('Only HTTP/HTTPS allowed')
  }

  if (FORBIDDEN_HOSTS.includes(parsed.hostname)) {
    throw new Error('Internal addresses not allowed')
  }
}