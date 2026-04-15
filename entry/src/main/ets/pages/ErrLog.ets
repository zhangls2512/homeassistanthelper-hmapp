import { common } from '@kit.AbilityKit'
import { haRequest } from '../common/Request'

@ComponentV2
export default struct Errlog {
  @Local errlog: string = ''
  @Local loading: boolean = false
  context = this.getUIContext().getHostContext() as common.UIAbilityContext

  async get() {
    this.loading = true
    const res = await haRequest(this.context, 'error_log', 'GET')
    this.loading = false
    if (res !== 'fail') {
      this.errlog = res
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
          if (this.errlog.length === 0 && !this.loading) {
            ListItem() {
              Text('无数据')
            }
            .margin({
              top: $r('sys.float.ohos_id_elements_margin_vertical_m')
            })
            .width('100%')
          }
          ListItem() {
            Text(this.errlog)
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })
          .width('100%')
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