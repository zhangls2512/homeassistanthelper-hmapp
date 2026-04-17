import { common } from '@kit.AbilityKit'
import { haRequest } from '../common/Request'

interface ErrorLogItem {
  time: string,
  level: string,
  content: string
}

@ComponentV2
export default struct Errlog {
  @Local errorLogArray: ErrorLogItem[] = []
  @Local loading: boolean = false
  context = this.getUIContext().getHostContext() as common.UIAbilityContext

  async get() {
    this.loading = true
    const res = await haRequest(this.context, 'error_log', 'GET')
    this.loading = false
    if (res !== 'fail' && res !== 'null') {
      this.errorLogArray = res.split('\n').map((item): ErrorLogItem => {
        const data = item.split(' ')
        return {
          time: data[0] + ' ' + data[1],
          level: data[2],
          content: data.slice(3).join(' ')
        }
      })
      this.errorLogArray.pop()
    }
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
      if (this.errorLogArray.length === 0 && !this.loading) {
        ListItem() {
          Text('无数据')
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })
        .width('100%')
      }
      ForEach(this.errorLogArray, (item: ErrorLogItem) => {
        ListItem() {
          Column() {
            Row() {
              Text('等级')
                .fontWeight(FontWeight.Medium)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(item.level)
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
              Text('内容')
                .fontWeight(FontWeight.Medium)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Text(item.content)
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
              Text(item.time)
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