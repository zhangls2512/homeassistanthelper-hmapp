import { common } from '@kit.AbilityKit'
import { display, SegmentButtonV2Items, TabSegmentButtonV2 } from '@kit.ArkUI'
import { getLoginStatus } from '../common/Account'
import { getPreferType } from '../common/Prefertype'
import { haRequest } from '../common/Request'

interface Attributes {
  friendly_name: string
}

interface StateItem {
  entity_id: string,
  state: string,
  attributes: Attributes
}

interface ServiceItem {
  domain: string,
  services: object
}

@ComponentV2
export default struct Home {
  @Local selectedIndex: number = 0
  @Local states: StateItem[] = []
  @Local services: ServiceItem[] = []
  @Local preferType: number = 1
  @Local loading: boolean = false
  @Local isLogin: boolean = false
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext

  async get(refresh: number = 2) {
    this.isLogin = await getLoginStatus(this.context)
    if (this.isLogin) {
      if (refresh !== 1) {
        const stateres = await haRequest(this.context, 'states', 'GET')
        if (stateres !== 'fail') {
          this.states = JSON.parse(stateres)
        }
      }
      if (refresh !== 0) {
        const serviceres = await haRequest(this.context, 'services', 'GET')
        if (serviceres !== 'fail') {
          this.services = JSON.parse(serviceres)
        }
      }
    }
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
                ForEach(this.states, (item: StateItem) => {
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
                        Text(item.state)
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
                ForEach(this.services, (item: ServiceItem) => {
                  ListItem() {
                    Column() {
                      Row() {
                        Text(item.domain)
                          .fontWeight(FontWeight.Medium)
                      }
                      .borderRadius(12)
                      .padding(12)

                      ForEach(Object.keys(item.services), (serviceItem: string) => {
                        Divider()
                          .padding({
                            left: 12,
                            right: 12
                          })
                        Row() {
                          Text(serviceItem)
                            .fontColor($r('sys.color.font_secondary'))
                            .fontSize($r('sys.float.ohos_id_text_size_body2'))
                        }
                        .borderRadius(12)
                        .padding(12)
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