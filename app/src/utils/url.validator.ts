import { lookup } from 'node:dns/promises'
import { isIP } from 'node:net'

const FORBIDDEN_HOSTS = new Set(['localhost', 'localhost.', '0.0.0.0', '127.0.0.1', '::1'])

function isPrivateIpv4(address: string): boolean {
  const parts = address.split('.').map((part) => Number(part))
  if (parts.length !== 4 || parts.some((part) => !Number.isInteger(part) || part < 0 || part > 255)) {
    return true
  }

  const [a, b] = parts
  return (
    a === 0 ||
    a === 10 ||
    a === 127 ||
    (a === 100 && b >= 64 && b <= 127) ||
    (a === 169 && b === 254) ||
    (a === 172 && b >= 16 && b <= 31) ||
    (a === 192 && b === 168) ||
    a >= 224
  )
}

function isPrivateIpv6(address: string): boolean {
  const normalized = address.toLowerCase()
  return (
    normalized === '::1' ||
    normalized === '::' ||
    normalized.startsWith('fc') ||
    normalized.startsWith('fd') ||
    normalized.startsWith('fe80:') ||
    normalized.startsWith('::ffff:10.') ||
    normalized.startsWith('::ffff:127.') ||
    normalized.startsWith('::ffff:192.168.') ||
    /^::ffff:172\.(1[6-9]|2\d|3[0-1])\./.test(normalized)
  )
}

function assertPublicAddress(address: string): void {
  const family = isIP(address)
  if (family === 4 && isPrivateIpv4(address)) {
    throw new Error('Private or internal addresses are not allowed')
  }
  if (family === 6 && isPrivateIpv6(address)) {
    throw new Error('Private or internal addresses are not allowed')
  }
  if (family === 0) {
    throw new Error('Invalid resolved address')
  }
}

export async function validateUrl(url: string): Promise<string> {
  let parsed: URL
  try {
    parsed = new URL(url)
  } catch {
    throw new Error('Invalid URL')
  }

  if (!['http:', 'https:'].includes(parsed.protocol)) {
    throw new Error('Only HTTP/HTTPS allowed')
  }

  const hostname = parsed.hostname.toLowerCase().replace(/^\[(.*)]$/, '$1')
  if (FORBIDDEN_HOSTS.has(hostname) || hostname.endsWith('.localhost')) {
    throw new Error('Internal addresses not allowed')
  }

  const directIpFamily = isIP(hostname)
  if (directIpFamily !== 0) {
    assertPublicAddress(hostname)
    return parsed.toString()
  }

  const records = await lookup(hostname, { all: true, verbatim: true })
  if (records.length === 0) {
    throw new Error('URL hostname could not be resolved')
  }
  for (const record of records) {
    assertPublicAddress(record.address)
  }

  return parsed.toString()
}
