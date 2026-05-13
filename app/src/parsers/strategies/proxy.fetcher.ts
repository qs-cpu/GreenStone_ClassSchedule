import { redis } from '../../lib/redis'
import { DirectFetcher, FetchResult } from './direct.fetcher'

export class ProxyFetcher {
  private direct = new DirectFetcher()

  async fetch(url: string): Promise<FetchResult> {
    const cached = await redis.get(`proxy:${url}`)
    if (cached) {
      return JSON.parse(cached)
    }

    const result = await this.direct.fetch(url)

    await redis.set(`proxy:${url}`, JSON.stringify(result), {
      EX: 300,
    })

    return result
  }
}