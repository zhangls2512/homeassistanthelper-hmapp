import { util } from '@kit.ArkTS'
import { promptAction } from '@kit.ArkUI'
import { appAccount } from '@kit.BasicServicesKit'
import { fileIo } from '@kit.CoreFileKit'
import { rcp } from '@kit.RemoteCommunicationKit'
import { getDnsServer } from './Dnsserver'
import { readUri, write } from './File'
import { getFlushPreference } from './Preference'
import { AddressGroupItem } from '../pages/Addressgroup'

export interface AccountInfo {
  id: string,
  path: string,
  token: string,
  bz: string,
  isLogin: string
}

interface InAccountInfo {
  path: string,
  token: string,
  bz: string,
  isLogin: string
}

export interface BestAddressItem {
  list: string[],
  best: string
}

export async function setAccount(context: Context, accountInfo: InAccountInfo) {
  await exitAccount(context)
  const accounts = await getAccountList(context)
  let accountIndex = -1
  accounts.forEach((item, index) => {
    if (accountInfo.path === item.path && accountInfo.token === item.token) {
      accountIndex = index
    }
  })
  const appAccountManager = appAccount.createAppAccountManager()
  if (accountIndex !== -1) {
    const id = accounts[accountIndex].id
    await appAccountManager.setCredential(id, 'token', accountInfo.token)
    await appAccountManager.setCustomData(id, 'bz', accountInfo.bz)
    await appAccountManager.setCustomData(id, 'isLogin', accountInfo.isLogin)
  }
  if (accountIndex === -1) {
    let oldAccountIndex = -1
    accounts.forEach((item, index) => {
      if (accountInfo.path === item.path && accountInfo.token === item.token) {
        oldAccountIndex = index
      }
    })
    const id = util.generateRandomUUID()
    await appAccountManager.createAccount(id, {
      customData: {
        path: accountInfo.path,
        bz: accountInfo.bz,
        isLogin: accountInfo.isLogin
      }
    })
    await appAccountManager.setCredential(id, 'token', accountInfo.token)
    if (oldAccountIndex !== -1) {
      await removeAccount(context, accounts[oldAccountIndex].id)
    }
  }
}

export async function setAccountBz(id: string, bz: string) {
  const appAccountManager = appAccount.createAppAccountManager()
  await appAccountManager.setCustomData(id, 'bz', bz)
}

export async function getLoginStatus(context: Context) {
  const res = await getAccountInfo(context)
  if (res.id) {
    return true
  }
  return false
}

export async function getAccountInfo(context: Context): Promise<AccountInfo> {
  const accounts = await getAccountList(context, true)
  const account = accounts.find(item => item.isLogin === 'true')
  if (account) {
    return account
  }
  return {
    id: '',
    path: '',
    token: '',
    bz: '',
    isLogin: 'false'
  }
}

export async function getAccountList(context: Context, bestPath = false): Promise<AccountInfo[]> {
  const appAccountManager = appAccount.createAppAccountManager()
  const appAccountIds = await appAccountManager.getAccountsByOwner('com.songjy.homeassistanthelper')
  const appAccounts: AccountInfo[] = []
  const promises = appAccountIds.map(async (item) => {
    const id = item.name
    appAccounts.push({
      id: id,
      path: bestPath ? getBestAddress(context, appAccountManager.getCustomDataSync(id, 'path')) :
        appAccountManager.getCustomDataSync(id, 'path'),
      token: await appAccountManager.getCredential(id, 'token'),
      bz: appAccountManager.getCustomDataSync(item.name, 'bz'),
      isLogin: appAccountManager.getCustomDataSync(item.name, 'isLogin')
    })
  })
  await Promise.all(promises)
  return appAccounts
}

export async function exitAccount(context: Context) {
  const accounts = await getAccountList(context)
  const account = accounts.find(item => item.isLogin === 'true')
  if (account) {
    const appAccountManager = appAccount.createAppAccountManager()
    await appAccountManager.setCustomData(account.id, 'isLogin', 'false')
  }
}

export async function removeAccount(context: Context, id: string) {
  const accounts = await getAccountList(context)
  if (accounts.find(item => item.id === id)) {
    const appAccountManager = appAccount.createAppAccountManager()
    await appAccountManager.removeAccount(id)
    await promptAction.openToast({
      message: '删除成功'
    })
  }
}

export async function importAccounts(context: Context, uri: string) {
  try {
    const array = await getAccountList(context)
    if (array.length > 0) {
      await promptAction.openToast({
        message: '导入失败，原因：本地存在账号'
      })
      return
    }
    const filestring = await readUri(uri)
    const accounts = JSON.parse(filestring) as AccountInfo[]
    const promises = accounts.map(async (item) => {
      const bz = item.bz ? item.bz : ''
      await setAccount(context, {
        path: item.path,
        token: item.token,
        bz: bz,
        isLogin: item.isLogin
      })
    })
    await Promise.all(promises)
    await promptAction.openToast({
      message: '导入成功'
    })
  } catch {
    await promptAction.openToast({
      message: '导入失败'
    })
  }
}

function getBestAddress(context: Context, path: string) {
  const filePath = context.cacheDir + '/bestaddress.txt'
  if (fileIo.accessSync(filePath)) {
    const bestAddress = JSON.parse(fileIo.readTextSync(filePath)) as BestAddressItem[]
    for (let i = 0; i < bestAddress.length; i++) {
      const item = bestAddress[i]
      if (item.list.includes(path)) {
        return item.best
      }
    }
  }
  return path
}

export async function generateBestAddress(context: Context) {
  const bestAddressArray: BestAddressItem[] = []
  const filePath = context.filesDir + '/addressgroup.txt'
  if (fileIo.accessSync(filePath)) {
    const addressGroup = JSON.parse(fileIo.readTextSync(filePath)) as AddressGroupItem[]
    const promisesa = addressGroup.map(async (addressItem, indexa) => {
      let bestAddress = ''
      const promisesb = addressItem.list.map(async (item, indexb) => {
        const session = rcp.createSession({
          requestConfiguration: {
            dns: {
              dnsRules: getDnsServer(context)
            },
            security: {
              remoteValidation: getFlushPreference(context, 'debugSetting', 'closeRemoteValidationWhenLinkWebdav',
                'system') as 'system' | 'skip',
              tlsRange: {
                min: 'TlsV1.2'
              }
            }
          }
        })
        context.eventHub.on('cancelTry,' + indexa + ',' + indexb, (cancelTryIndex: number) => {
          if (cancelTryIndex !== indexb) {
            session.cancel()
          }
          context.eventHub.off('cancelTry,' + indexa + ',' + indexb)
        })
        try {
          await session.get(item)
          session.close()
          bestAddress = item
          for (let j = 0; j < addressItem.list.length; j++) {
            context.eventHub.emit('cancelTry,' + indexa + ',' + j, indexb)
          }
        } catch {
          session.close()
        }
      })
      await Promise.all(promisesb)
      if (bestAddress) {
        bestAddressArray.push({
          list: addressItem.list,
          best: bestAddress
        })
      }
    })
    await Promise.all(promisesa)
  }
  await write(context.cacheDir + '/bestaddress.txt', JSON.stringify(bestAddressArray))
}