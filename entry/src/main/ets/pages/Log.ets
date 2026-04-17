import { common } from '@kit.AbilityKit'
import { read } from '../common/File'
import copy from '../common/Pasteboard'
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
  @Local hoverId: number = -1
  @Local parameter: Record<string, Record<string, string>> = {}
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext

  async get() {
    this.loading = true
    const res = await read(this.context.filesDir + '/parameter.txt', true)
    if (res !== 'fail') {
      this.parameter = JSON.parse(res)
    }
    const resa = await haRequest(this.context, 'logbook', 'GET')
    this.loading = false
    if (resa !== 'fail') {
      this.logs = JSON.parse(resa)
    }
  }

  getValue(key: string, value: string) {
    if (!this.parameter[key] || !this.parameter[key][value]) {
      return value
    }
    return this.parameter[key][value]
  }

  build() {
    List() {
      if (this.loading) {
        ListItem() {
          LoadingProgress()
            .width('20%')
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })
        .width('100%')
      }
      if (this.logs.length === 0 && !this.loading) {
        ListItem() {
          Text('无数据')
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })
        .width('100%')
      }
      ForEach(this.logs, (item: LogItem, index) => {
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
                  $r('sys.color.ohos_id_color_card_bg'))
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
              Text(this.getValue('name', item.name))
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