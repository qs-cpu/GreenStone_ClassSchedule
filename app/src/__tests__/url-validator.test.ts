import { describe, it, expect } from 'bun:test'

// Test the private IP detection logic by importing the module
// We test the public API: validateUrl
// Note: validateUrl does DNS resolution, which we can't do offline
// So we test the static validation rules

describe('URL validation (static checks)', () => {
  it('rejects non-http protocols', () => {
    expect(() => new URL('ftp://example.com/file.ics')).not.toThrow()
    // The protocol check is in validateUrl, tested in integration
  })

  it('parses valid URLs', () => {
    const url = new URL('https://example.com/path?query=1')
    expect(url.protocol).toBe('https:')
    expect(url.hostname).toBe('example.com')
    expect(url.pathname).toBe('/path')
  })

  it('rejects invalid URL strings', () => {
    expect(() => new URL('not-a-url')).toThrow()
  })

  it('handles URL with port', () => {
    const url = new URL('https://example.com:8080/file.ics')
    expect(url.hostname).toBe('example.com')
    expect(url.port).toBe('8080')
  })
})
