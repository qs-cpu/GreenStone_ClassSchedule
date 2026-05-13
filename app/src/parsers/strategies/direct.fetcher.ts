import axios from 'axios'

export interface FetchResult {
  content: string
  contentType?: string
  etag?: string
  lastModified?: string
}

export class DirectFetcher {
  async fetch(url: string): Promise<FetchResult> {
    const response = await axios.get(url, {
      timeout: 10000,
      maxContentLength: 5 * 1024 * 1024,
    })

    return {
      content: response.data,
      contentType: typeof response.headers['content-type'] === 'string'
        ? response.headers['content-type']
        : undefined,
      etag: typeof response.headers.etag === 'string'
        ? response.headers.etag
        : undefined,
      lastModified: typeof response.headers['last-modified'] === 'string'
        ? response.headers['last-modified']
        : undefined,
    }
  }
}