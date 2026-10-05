import { promptAction } from '@kit.ArkUI'
import { fileIo } from '@kit.CoreFileKit'
import { read, write } from './File'
import { sha256hash } from './Hash'
import { defaultGlobalSession, developerRequest } from './Request'

interface Response {
  downloadUrl: string
}

let globalParameter: Record<string, Record<string, string>> | undefined = undefined

export async function getParameter(context: Context) {
  if (!globalParameter) {
    const res = await read(context.filesDir + '/parameter.txt', true)
    if (res !== 'fail') {
      globalParameter = JSON.parse(res)
    }
    if (res === 'fail') {
      globalParameter = {}
    }
  }
  return globalParameter ?? {} as Record<string, Record<string, string>>
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
    try {
      const response = await defaultGlobalSession.get(res.downloadUrl)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        const parameter = String(response)
        const newHash = sha256hash(parameter)
        if (oldHash !== newHash) {
          await write(filePath, parameter)
          globalParameter = JSON.parse(parameter)
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
      await promptAction.openToast({
        message: '发生错误，错误码：' + err.code + (err.message ? '，错误信息：' + err.message : '')
      })
    }
  }
  return 'fail'
}