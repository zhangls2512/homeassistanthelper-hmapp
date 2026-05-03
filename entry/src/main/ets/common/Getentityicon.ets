import { fileIo, fileUri } from '@kit.CoreFileKit'
import { rcp } from '@kit.RemoteCommunicationKit'
import { write } from './File'

interface Response {
  icons: Record<string, Body>
}

interface Body {
  body: string
}

export async function getEntityIconPath(context: Context, icon: string) {
  const name = icon.split(':', 2)[1]
  const filePath = context.cacheDir + '/entityicon/' + name + '.svg'
  if (fileIo.accessSync(filePath)) {
    return fileUri.getUriFromPath(filePath)
  }
  const session = rcp.createSession({
    requestConfiguration: {
      security: {
        tlsRange: {
          min: 'TlsV1.2'
        }
      }
    }
  })
  try {
    const response = await session.get('https://api.iconify.design/mdi.json?icons=' + name)
    session.close()
    if (response.statusCode >= 200 && response.statusCode < 300) {
      const res = response.toJSON() as Response
      if (res.icons[name]) {
        await write(filePath,
          '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24">' + res.icons[name].body + '</svg>')
        return fileUri.getUriFromPath(filePath)
      }
      return ''
    } else {
      return ''
    }
  } catch {
    session.close()
    return ''
  }
}