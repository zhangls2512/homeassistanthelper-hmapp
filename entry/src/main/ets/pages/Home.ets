import { common } from '@kit.AbilityKit'
import { display, LoadingDialog, promptAction, SegmentButtonV2Items, TabSegmentButtonV2 } from '@kit.ArkUI'
import { getLoginStatus } from '../common/Account'
import { read } from '../common/File'
import copy from '../common/Pasteboard'
import { getPreferType } from '../common/Prefertype'
import { haRequest } from '../common/Request'
import Servicecall from './Servicecall'

interface Attributes {
  friendly_name: string
}

interface StateItem {
  entity_id: string,
  state: string,
  attributes: Attributes
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
  fields: Record<string, Param> = {}
  path = ''
  title = ''

  async get(refresh: number = 2) {
    this.isLogin = await getLoginStatus(this.context)
    if (this.isLogin) {
      const res = await read(this.context.filesDir + '/parameter.txt', true)
      if (res !== 'fail') {
        this.parameter = JSON.parse(res)
      }
      if (refresh !== 1) {
        this.states = []
        const stateres = await haRequest(this.context, 'states', 'GET')
        if (stateres !== 'fail') {
          this.states = JSON.parse(stateres)
          this.states = this.states.sort((a, b) => a.entity_id.localeCompare(b.entity_id))
        }
      }
      if (refresh !== 0) {
        this.services = []
        const serviceres = await haRequest(this.context, 'services', 'GET')
        if (serviceres !== 'fail') {
          this.services = JSON.parse(serviceres)
          this.services = this.services.sort((a, b) => a.domain.localeCompare(b.domain))
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
              bottom: $r('sys.float.ohos_id_elements_margin_vertical_m'),
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
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
                ForEach(this.states, (item: StateItem, index) => {
                  ListItem() {
                    Column() {
                      Row() {
                        Text('实体ID')
                          .enableAutoSpacing(true)
                          .fontWeight(FontWeight.Medium)
                          .margin({
                            right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                          })
                        Text(item.entity_id)
                          .fontColor($r('sys.color.font_secondary'))
                          .fontSize($r('sys.float.ohos_id_text_size_body2'))
                          .layoutWeight(1)
                          .textAlign(TextAlign.End)
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
                          this.hoverId = -1
                        }
                        if (isHover) {
                          this.hoverId = index
                        }
                      })
                      .onClick(async () => {
                        await copy(this.context, this.UIContext, item.entity_id)
                      })

                      Divider()
                        .padding({
                          left: 12,
                          right: 12
                        })
                      Row() {
                        Text('名称')
                          .fontWeight(FontWeight.Medium)
                          .margin({
                            right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                          })
                        Text(item.attributes.friendly_name)
                          .fontColor($r('sys.color.font_secondary'))
                          .fontSize($r('sys.float.ohos_id_text_size_body2'))
                          .layoutWeight(1)
                          .textAlign(TextAlign.End)
                      }
                      .borderRadius(12)
                      .padding(12)

                      Divider()
                        .padding({
                          left: 12,
                          right: 12
                        })
                      Row() {
                        Text('状态')
                          .fontWeight(FontWeight.Medium)
                          .margin({
                            right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                          })
                        Text(this.getValue('state', item.state))
                          .fontColor($r('sys.color.font_secondary'))
                          .fontSize($r('sys.float.ohos_id_text_size_body2'))
                          .layoutWeight(1)
                          .textAlign(TextAlign.End)
                      }
                      .borderRadius(12)
                      .padding(12)
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
                          if (Object.keys(item.services[serviceItem].fields).length === 0 &&
                            !item.services[serviceItem].target) {
                            const data = await promptAction.showDialog({
                              title: '提示',
                              message: '确定' + this.getValue('service', serviceItem) +
                                this.getValue('domain', item.domain) + '？',
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
                              }
                            }
                          } else {
                            this.target = item.services[serviceItem].target ? true : false
                            this.fields = item.services[serviceItem].fields
                            this.path = 'services/' + item.domain + '/' + serviceItem
                            this.title = this.getValue('service', serviceItem) + this.getValue('domain', item.domain)
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
            .bindSheet(this.isShowServicecallSheet!!, this.ServicecallSheetBuilder(), {
              preferType: this.preferType,
              title: {
                title: this.title
              }
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
        await this.get()
      })
      await this.get()
    })
    .onDisAppear(() => {
      this.context.eventHub.off('refreshHome')
      display.off('change')
    })
  }
}