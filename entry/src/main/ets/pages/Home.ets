import { common } from '@kit.AbilityKit'
import { display, LoadingDialog, SegmentButtonV2Items, TabSegmentButtonV2 } from '@kit.ArkUI'
import { getLoginStatus } from '../common/Account'
import { read } from '../common/File'
import { getEntityIconPath } from '../common/Getentityicon'
import { getPreferType } from '../common/Prefertype'
import { haRequest } from '../common/Request'
import Servicecall from './Servicecall'

interface Attributes {
  friendly_name: string,
  unit_of_measurement: string,
  icon: string
}

interface StateItem {
  entity_id: string,
  domain: string,
  state: string,
  attributes: Attributes,
  services: Record<string, Service>
}

interface Service {
  fields: Record<string, Param>,
  target?: object
}

export interface Param {
  example: string,
  required: boolean,
  selector: Record<string, Selector>
}

interface Selector {
  multiline: boolean,
  multiple: boolean,
  mode: string,
  min: number,
  max: number,
  step: number,
  options: string[],
  attribute: string,
  unit: string
}

interface ServiceItem {
  domain: string,
  services: Record<string, Service>
}

@ComponentV2
export default struct Home {
  @Provider() isShowServicecallSheet: boolean = false
  @Local selectedIndex: number = 0
  @Local domains: string[] = []
  @Local states: StateItem[] = []
  @Local services: ServiceItem[] = []
  @Local preferType: number = 1
  @Local loading: boolean = false
  @Local isLogin: boolean = false
  @Local hoverId: number | string = -1
  @Local parameter: Record<string, Record<string, string>> = {}
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  target = false
  entityId = ''
  fields: Record<string, Param> = {}
  path = ''
  title = ''

  async get(refresh: number = 2) {
    if (this.isLogin) {
      const res = await read(this.context.filesDir + '/parameter.txt', true)
      if (res !== 'fail') {
        this.parameter = JSON.parse(res)
      }
      this.services = []
      const serviceres = await haRequest(this.context, 'services', 'GET')
      if (serviceres !== 'fail') {
        this.services = JSON.parse(serviceres)
        this.services = this.services.sort((a, b) => this.getValue('domain', a.domain)
          .localeCompare(this.getValue('domain', b.domain)))
        if (refresh !== 1) {
          this.domains = []
          this.states = []
          const stateres = await haRequest(this.context, 'states', 'GET')
          if (stateres !== 'fail') {
            this.states = JSON.parse(stateres)
            this.states = this.states.map(item => {
              if (!item.attributes.friendly_name) {
                item.attributes.friendly_name = '未知'
              }
              return item
            }).sort((a, b) => a.attributes.friendly_name.localeCompare(b.attributes.friendly_name))
            const states: StateItem[] = []
            const promises = this.states.map(async (item) => {
              const domain = item.entity_id.split('.')[0]
              const service = this.services.find(serviceItem => serviceItem.domain === domain)
              if (item.attributes.icon) {
                item.attributes.icon = await getEntityIconPath(this.context, item.attributes.icon)
              }
              states.push({
                entity_id: item.entity_id,
                domain: domain,
                state: item.state,
                attributes: item.attributes,
                services: service ? service.services : {}
              })
            })
            await Promise.all(promises)
            const map = new Map<string, boolean>()
            states.map(item => item.domain).forEach(item => {
              map.set(item, true)
            })
            this.domains = Array.from(map.keys())
              .sort((a, b) => this.getValue('domain', a).localeCompare(this.getValue('domain', b)))
            this.states = states
          }
        }
      }
    }
  }

  getValue(key: string, value: string) {
    if (!this.parameter[key] || !this.parameter[key][value]) {
      return value
    }
    return this.parameter[key][value]
  }

  @Builder
  ServicecallSheetBuilder() {
    Servicecall({
      target: this.target,
      entityId: this.entityId,
      fields: this.fields,
      path: this.path
    })
  }

  build() {
    Scroll() {
      Column() {
        if (!this.isLogin) {
          Text('未登录账号')
            .height('100%')
            .textAlign(TextAlign.Center)
            .width('100%')
        }
        if (this.isLogin) {
          TabSegmentButtonV2({
            items: new SegmentButtonV2Items([
              { text: '状态' },
              { text: '服务' }
            ]),
            selectedIndex: this.selectedIndex!!
          })
            .margin({
              bottom: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
            .bindSheet(this.isShowServicecallSheet!!, this.ServicecallSheetBuilder(), {
              preferType: this.preferType,
              title: {
                title: this.title
              }
            })
          if (this.selectedIndex === 0) {
            Refresh({
              refreshing: $$this.loading
            }) {
              List() {
                if (this.states.length === 0 && !this.loading) {
                  ListItem() {
                    Text('无数据')
                  }
                  .margin({
                    top: $r('sys.float.ohos_id_elements_margin_vertical_m')
                  })
                  .width('100%')
                }
                ForEach(this.domains, (domainItem: string, domainIndex) => {
                  ListItem() {
                    Text(this.getValue('domain', domainItem))
                      .fontSize($r('sys.float.ohos_id_text_size_dialog_tittle'))
                      .fontWeight(FontWeight.Bold)
                  }
                  .margin({
                    top: domainIndex !== 0 ? $r('sys.float.ohos_id_elements_margin_vertical_l') :
                      $r('sys.float.ohos_id_elements_margin_vertical_m')
                  })

                  ForEach(this.states.filter(item => item.domain === domainItem), (item: StateItem, index) => {
                    ListItem() {
                      Column() {
                        Row() {
                          if (item.attributes.icon) {
                            Image(item.attributes.icon)
                              .fillColor('#44739E')
                              .height(24)
                              .margin({
                                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                              })
                              .width(24)
                          }
                          Text(item.attributes.friendly_name)
                            .enableAutoSpacing(true)
                            .fontWeight(FontWeight.Medium)
                            .layoutWeight(1)
                            .margin({
                              right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                            })
                          Text(this.getValue('state', item.state) +
                            (item.attributes.unit_of_measurement ? item.attributes.unit_of_measurement : ''))
                            .enableAutoSpacing(true)
                            .fontColor($r('sys.color.font_secondary'))
                            .fontSize($r('sys.float.ohos_id_text_size_body2'))
                            .textAlign(TextAlign.End)
                        }
                        .borderRadius(12)
                        .padding(12)

                        if (item.services) {
                          ForEach(Object.keys(item.services), (serviceItem: string, serviceIndex) => {
                            Divider()
                              .padding({
                                left: 12,
                                right: 12
                              })
                            Row() {
                              Text(this.getValue('service', serviceItem))
                                .enableAutoSpacing(true)
                                .fontColor($r('sys.color.font_secondary'))
                                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                                .layoutWeight(1)
                                .margin({
                                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                                })
                              Image($r('app.media.right'))
                                .fillColor($r('sys.color.icon_fourth'))
                                .height(12)
                                .width(12)
                            }
                            .borderRadius(12)
                            .padding(12)
                            .stateStyles({
                              normal: {
                                .backgroundColor(this.hoverId === index + ',' + serviceIndex ?
                                  $r('sys.color.interactive_hover') : $r('sys.color.comp_background_primary'))
                              },
                              pressed: {
                                .backgroundColor($r('sys.color.interactive_pressed'))
                              }
                            })
                            .onHover(isHover => {
                              if (!isHover) {
                                this.hoverId = ''
                              }
                              if (isHover) {
                                this.hoverId = index + ',' + serviceIndex
                              }
                            })
                            .onClick(async () => {
                              const promptAction = this.UIContext.getPromptAction()
                              if (Object.keys(item.services[serviceItem].fields).length === 0) {
                                const data = await promptAction.showDialog({
                                  title: '提示',
                                  message: '确定' + this.getValue('service', serviceItem) + '？',
                                  buttons: [
                                    {
                                      text: '取消',
                                      color: $r('sys.color.warning')
                                    },
                                    {
                                      text: '确定',
                                      color: $r('sys.color.font_emphasize')
                                    }
                                  ]
                                })
                                if (data.index === 1) {
                                  const dialogControllerProgress = new CustomDialogController({
                                    builder: LoadingDialog({
                                      content: '请求中...'
                                    })
                                  })
                                  dialogControllerProgress.open()
                                  let res = ''
                                  if (!item.services[serviceItem].target) {
                                    res =
                                      await haRequest(this.context, 'services/' + item.domain + '/' + serviceItem,
                                        'POST')
                                  }
                                  if (item.services[serviceItem].target) {
                                    res =
                                      await haRequest(this.context, 'services/' + item.domain + '/' + serviceItem,
                                        'POST',
                                        {
                                          entity_id: item.entity_id
                                        })
                                  }
                                  dialogControllerProgress.close()
                                  if (res !== 'fail') {
                                    await promptAction.openToast({
                                      message: '调用成功'
                                    })
                                    this.loading = true
                                  }
                                }
                              } else {
                                this.target = item.services[serviceItem].target ? true : false
                                this.entityId = item.services[serviceItem].target ? item.entity_id : ''
                                this.fields = item.services[serviceItem].fields
                                this.path = 'services/' + item.domain + '/' + serviceItem
                                this.title = this.getValue('service', serviceItem)
                                this.isShowServicecallSheet = true
                              }
                            })
                          })
                        }
                        Divider()
                          .padding({
                            left: 12,
                            right: 12
                          })
                        Row() {
                          Text('删除')
                            .fontColor($r('sys.color.warning'))
                            .fontWeight(FontWeight.Medium)
                            .layoutWeight(1)
                            .margin({
                              right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                            })
                          Image($r('app.media.right'))
                            .fillColor($r('sys.color.icon_fourth'))
                            .height(12)
                            .width(12)
                        }
                        .borderRadius(12)
                        .padding(12)
                        .stateStyles({
                          normal: {
                            .backgroundColor(this.hoverId === index ? $r('sys.color.interactive_hover') :
                              $r('sys.color.comp_background_primary'))
                          },
                          pressed: {
                            .backgroundColor($r('sys.color.interactive_pressed'))
                          }
                        })
                        .onHover(isHover => {
                          if (!isHover) {
                            this.hoverId = ''
                          }
                          if (isHover) {
                            this.hoverId = index
                          }
                        })
                        .onClick(async () => {
                          const promptAction = this.UIContext.getPromptAction()
                          const data = await promptAction.showDialog({
                            title: '提示',
                            message: '删除成功后无法恢复，确定删除？',
                            buttons: [
                              {
                                text: '取消',
                                color: $r('sys.color.font_primary')
                              },
                              {
                                text: '确定',
                                color: $r('sys.color.warning')
                              }
                            ]
                          })
                          if (data.index === 1) {
                            const dialogControllerProgress = new CustomDialogController({
                              builder: LoadingDialog({
                                content: '请求中...'
                              })
                            })
                            dialogControllerProgress.open()
                            const res = await haRequest(this.context, 'states/' + item.entity_id, 'DELETE')
                            dialogControllerProgress.close()
                            if (res !== 'fail') {
                              await promptAction.openToast({
                                message: '删除成功'
                              })
                              this.loading = true
                            }
                          }
                        })
                      }
                      .backgroundColor($r('sys.color.comp_background_primary'))
                      .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
                      .padding($r('sys.float.ohos_id_corner_radius_mark'))
                    }
                    .margin({
                      top: $r('sys.float.ohos_id_elements_margin_vertical_m')
                    })
                  })
                })
                ListItem()
                  .margin({
                    bottom: this.preferType === 0 ? 80 : 0
                  })
              }
            }
            .layoutWeight(1)
            .onRefreshing(async () => {
              await this.get(0)
              this.loading = false
            })
          }
          if (this.selectedIndex === 1) {
            Refresh({
              refreshing: $$this.loading
            }) {
              List() {
                if (this.services.length === 0 && !this.loading) {
                  ListItem() {
                    Text('无数据')
                  }
                  .margin({
                    top: $r('sys.float.ohos_id_elements_margin_vertical_m')
                  })
                  .width('100%')
                }
                ForEach(this.services, (item: ServiceItem, index) => {
                  ListItem() {
                    Column() {
                      Row() {
                        Text(this.getValue('domain', item.domain))
                          .enableAutoSpacing(true)
                          .fontWeight(FontWeight.Medium)
                      }
                      .borderRadius(12)
                      .padding(12)
                      .width('100%')

                      ForEach(Object.keys(item.services), (serviceItem: string, serviceIndex) => {
                        Divider()
                          .padding({
                            left: 12,
                            right: 12
                          })
                        Row() {
                          Text(this.getValue('service', serviceItem))
                            .enableAutoSpacing(true)
                            .fontColor($r('sys.color.font_secondary'))
                            .fontSize($r('sys.float.ohos_id_text_size_body2'))
                            .layoutWeight(1)
                            .margin({
                              right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                            })
                          Image($r('app.media.right'))
                            .fillColor($r('sys.color.icon_fourth'))
                            .height(12)
                            .width(12)
                        }
                        .borderRadius(12)
                        .padding(12)
                        .stateStyles({
                          normal: {
                            .backgroundColor(this.hoverId === index + ',' + serviceIndex ?
                              $r('sys.color.interactive_hover') : $r('sys.color.comp_background_primary'))
                          },
                          pressed: {
                            .backgroundColor($r('sys.color.interactive_pressed'))
                          }
                        })
                        .onHover(isHover => {
                          if (!isHover) {
                            this.hoverId = ''
                          }
                          if (isHover) {
                            this.hoverId = index + ',' + serviceIndex
                          }
                        })
                        .onClick(async () => {
                          const promptAction = this.UIContext.getPromptAction()
                          if (Object.keys(item.services[serviceItem].fields).length === 0 &&
                            !item.services[serviceItem].target) {
                            const data = await promptAction.showDialog({
                              title: '提示',
                              message: '确定' + this.getValue('service', serviceItem) + '？',
                              buttons: [
                                {
                                  text: '取消',
                                  color: $r('sys.color.warning')
                                },
                                {
                                  text: '确定',
                                  color: $r('sys.color.font_emphasize')
                                }
                              ]
                            })
                            if (data.index === 1) {
                              const dialogControllerProgress = new CustomDialogController({
                                builder: LoadingDialog({
                                  content: '请求中...'
                                })
                              })
                              dialogControllerProgress.open()
                              const res =
                                await haRequest(this.context, 'services/' + item.domain + '/' + serviceItem, 'POST')
                              dialogControllerProgress.close()
                              if (res !== 'fail') {
                                await promptAction.openToast({
                                  message: '调用成功'
                                })
                                this.loading = true
                              }
                            }
                          } else {
                            this.target = item.services[serviceItem].target ? true : false
                            this.entityId = ''
                            this.fields = item.services[serviceItem].fields
                            this.path = 'services/' + item.domain + '/' + serviceItem
                            this.title = this.getValue('service', serviceItem)
                            this.isShowServicecallSheet = true
                          }
                        })
                      })
                    }
                    .backgroundColor($r('sys.color.comp_background_primary'))
                    .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
                    .padding($r('sys.float.ohos_id_corner_radius_mark'))
                  }
                  .margin({
                    top: $r('sys.float.ohos_id_elements_margin_vertical_m')
                  })
                })
                ListItem()
                  .margin({
                    bottom: this.preferType === 0 ? 80 : 0
                  })
              }
            }
            .layoutWeight(1)
            .onRefreshing(async () => {
              await this.get(1)
              this.loading = false
            })
          }
        }
      }
    }
    .padding({
      left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      right: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      top: this.preferType === 0 ? 0 : $r('sys.float.ohos_id_default_padding_top')
    })
    .onAppear(async () => {
      this.preferType = getPreferType(this.UIContext)
      display.on('change', () => {
        setTimeout(() => {
          this.preferType = getPreferType(this.UIContext)
        }, 200)
      })
      this.context.eventHub.on('refreshHome', async () => {
        this.isLogin = await getLoginStatus(this.context)
        this.loading = true
      })
      this.isLogin = await getLoginStatus(this.context)
      this.loading = true
    })
    .onDisAppear(() => {
      this.context.eventHub.off('refreshHome')
      display.off('change')
    })
  }
}