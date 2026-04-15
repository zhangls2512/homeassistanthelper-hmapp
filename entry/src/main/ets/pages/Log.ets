import { common } from '@kit.AbilityKit'
import { haRequest } from '../common/Request'

interface LogItem {
  entity_id: string,
  name: string,
  state: string,
  when: string
}

@ComponentV2
export default struct Log {
  @Local logs: LogItem[] = []
  @Local loading: boolean = false
  context = this.getUIContext().getHostContext() as common.UIAbilityContext

  async get() {
    this.loading = true
    const res = await haRequest(this.context, 'logbook', 'GET')
    this.loading = false
    if (res !== 'fail') {
      this.logs = JSON.parse(res)
    }
  }

  build() {
    Scroll() {
      Column() {
        if (this.loading) {
          LoadingProgress()
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
            .width('20%')
        }
        List() {
          if (this.logs.length === 0 && !this.loading) {
            ListItem() {
              Text('无数据')
            }
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
            .width('100%')
          }
          ForEach(this.logs, (item: LogItem) => {
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
                  Text(item.name)
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

                Divider()
                  .padding({
                    left: 12,
                    right: 12
                  })
                Row() {
                  Text('时间')
                    .fontWeight(FontWeight.Medium)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                  Text(item.when)
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .layoutWeight(1)
                    .textAlign(TextAlign.End)
                }
                .borderRadius(12)
                .padding(12)
              }
              .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
              .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
              .padding($r('sys.float.ohos_id_corner_radius_mark'))
            }
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
          })
        }
        .layoutWeight(1)
      }
    }
    .padding({
      bottom: $r('sys.float.ohos_id_default_padding_bottom_fixed'),
      left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
    })
    .onAppear(async () => {
      await this.get()
    })
  }
}