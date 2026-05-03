import { fileIo } from '@kit.CoreFileKit'
import { getAccountInfo } from './Account'
import { read, write } from './File'
import { AddressGroupItem } from '../pages/Addressgroup'

interface HideEntity {
  path: string,
  list: HideEntityListItem[]
}

export interface HideEntityListItem {
  entityId: string,
  friendlyName: string
}

async function getPathIndex(context: Context) {
  const res = await read(context.filesDir + '/hideentity.txt', true)
  if (res !== 'fail') {
    const hideEntity = JSON.parse(res) as HideEntity[]
    const accountInfo = await getAccountInfo(context)
    const filePath = context.filesDir + '/addressgroup.txt'
    if (fileIo.accessSync(filePath)) {
      const addressGroup = JSON.parse(fileIo.readTextSync(filePath)) as AddressGroupItem[]
      for (let i = 0; i < addressGroup.length; i++) {
        if (addressGroup[i].list.includes(accountInfo.path)) {
          for (let j = 0; j < addressGroup[i].list.length; j++) {
            const index = hideEntity.findIndex(item => item.path === addressGroup[i].list[j])
            if (index !== -1) {
              return index
            }
          }
        }
      }
    }
    return hideEntity.findIndex(item => item.path === accountInfo.path)
  }
  return -1
}

export async function getHideEntity(context: Context) {
  const res = await read(context.filesDir + '/hideentity.txt', true)
  if (res !== 'fail') {
    const hideEntity = JSON.parse(res) as HideEntity[]
    const index = await getPathIndex(context)
    if (index !== -1) {
      return hideEntity[index].list
    }
    return []
  }
  return []
}

export async function setHideEntity(context: Context, hideEntity: HideEntityListItem[]) {
  const accountInfo = await getAccountInfo(context)
  const res = await read(context.filesDir + '/hideentity.txt', true)
  if (res !== 'fail') {
    const hideEntityList = JSON.parse(res) as HideEntity[]
    const index = await getPathIndex(context)
    if (index !== -1) {
      hideEntityList[index].list = hideEntity
    }
    if (index === -1) {
      hideEntityList.push({
        path: accountInfo.path,
        list: hideEntity
      })
    }
    await write(context.filesDir + '/hideentity.txt', JSON.stringify(hideEntityList))
  }
  if (res === 'fail') {
    await write(context.filesDir + '/hideentity.txt', JSON.stringify([{
      path: accountInfo.path,
      list: hideEntity
    }]))
  }
}