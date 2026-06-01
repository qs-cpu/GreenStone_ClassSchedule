import { Elysia, t } from 'elysia'
import { ImportService } from '../services/import.service'
import { validateUrl } from '../utils/url.validator'
import { getUserFromRequest } from '../middleware/auth'

export const importRoutes = new Elysia()
  .group('/api/import', (app) =>
    app.post(
      '/',
      async ({ body, request, set }) => {
        const user = await getUserFromRequest(request)
        if (!user) {
          set.status = 401
          return { error: '未授权，请先登录' }
        }

        const { url, termId } = body as { url: string; termId?: string }

        const validatedUrl = await validateUrl(url)
        const result = await new ImportService().import(validatedUrl, user.userId, termId)
        
        set.status = 201
        return result
      },
      {
        body: t.Object({
          url: t.String({ format: 'uri' }),
          termId: t.Optional(t.String()),
        }),
      }
    )
  )
