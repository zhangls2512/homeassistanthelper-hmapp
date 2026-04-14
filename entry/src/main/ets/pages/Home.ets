import { common } from '@kit.AbilityKit'
import { display } from '@kit.ArkUI'
import { getLoginStatus } from '../common/Account'
import { getPreferType } from '../common/Prefertype'

@ComponentV2
export default struct Home {
  @Local preferType: number = 1
  @Local isLogin: boolean = false
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext

  async get() {
    this.isLogin = await getLoginStatus(this.context)
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
          Text('敬请期待')
            .height('100%')
            .textAlign(TextAlign.Center)
            .width('100%')
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