import { promptAction } from '@kit.ArkUI'
import { fileIo } from '@kit.CoreFileKit'
import { rcp } from '@kit.RemoteCommunicationKit'
import { read, write } from './File'
import { sha256hash } from './Hash'
import { developerRequest } from './Request'

interface Response {
  downloadUrl: string
}

export async function downloadParameter(context: Context) {
  let oldHash = ''
  const filePath = context.filesDir + '/parameter.txt'
  if (fileIo.accessSync(filePath)) {
    const old = await read(filePath)
    oldHash = sha256hash(old)
  }
  const response = await developerRequest(context, '/product/getParameter', {
    type: 'homeassistanthelper'
  })
  if (response !== 'fail') {
    const res = JSON.parse(response) as Response
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
      const response = await session.get(res.downloadUrl)
      session.close()
      if (response.statusCode >= 200 && response.statusCode < 300) {
        const parameter = String(response)
        const newHash = sha256hash(parameter)
        if (oldHash !== newHash) {
          await write(filePath, parameter)
          return true
        }
        if (oldHash === newHash) {
          return false
        }
      } else {
        await promptAction.openToast({
          message: 'HTTP 请求失败，状态码：' + response.statusCode
        })
      }
    } catch (err) {
      session.close()
      await promptAction.openToast({
        message: '发生错误，错误码：' + err.code
      })
    }
  }
  return 'fail'
}