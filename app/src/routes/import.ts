import { Elysia, t } from 'elysia'
import { ImportService } from '../services/import.service'
import { validateUrl } from '../utils/url.validator'

export const importRoutes = new Elysia()
  .group('/api/import', (app) =>
    app.post(
      '/',
      async ({ body, set }) => {
        const { url } = body as { url: string }

        const validatedUrl = await validateUrl(url)
        const result = await new ImportService().import(validatedUrl)
        
        set.status = 201
        return result
      },
      {
        body: t.Object({
          url: t.String({ format: 'uri' }),
        }),
      }
    )
  )
