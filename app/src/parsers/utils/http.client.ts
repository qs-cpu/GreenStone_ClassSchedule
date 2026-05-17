export class HttpClient {
  private baseUrl: string
  private cookies: Map<string, string>

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl
    this.cookies = new Map()
  }

  private getCookieHeader(): string {
    return [...this.cookies.entries()]
      .map(([k, v]) => `${k}=${v}`)
      .join('; ')
  }

  private storeSetCookies(setCookies: string[]): void {
    for (const raw of setCookies) {
      const [cookiePair] = raw.split(';')
      const [key, val] = cookiePair.split('=')
      if (key && val) {
        this.cookies.set(key.trim(), val.trim())
      }
    }
  }

  setCookie(key: string, value: string): void {
    this.cookies.set(key, value)
  }

  getAllCookies(): Record<string, string> {
    const result: Record<string, string> = {}
    for (const [key, value] of this.cookies.entries()) {
      result[key] = value
    }
    return result
  }

  setAllCookies(cookies: Record<string, string>): void {
    for (const [key, value] of Object.entries(cookies)) {
      this.cookies.set(key, value)
    }
  }

  async request(method: string, path: string, options: Record<string, any> = {}): Promise<Response> {
    const url = path.startsWith('http') ? path : this.baseUrl + path
    const headers: Record<string, string> = {
      'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      ...(options.headers || {}),
    }

    if (this.cookies.size > 0) {
      headers['Cookie'] = this.getCookieHeader()
    }

    const res = await fetch(url, {
      ...options,
      method,
      headers,
    })

    const setCookies = res.headers.getSetCookie?.()
    if (setCookies && Array.isArray(setCookies)) {
      this.storeSetCookies(setCookies)
    }

    return res
  }

  async get(path: string): Promise<Response> {
    return this.request('GET', path)
  }

  async post(path: string, body: Record<string, any> | string): Promise<Response> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/x-www-form-urlencoded',
    }
    const bodyData = typeof body === 'string' 
      ? body 
      : new URLSearchParams(body as Record<string, string>).toString()

    return this.request('POST', path, { headers, body: bodyData })
  }
}