import { common } from '@kit.AbilityKit'
import { display } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'
import { getAccountInfo } from '../common/Account'
import { getFlushPreference, setTempPreference } from '../common/Preference'
import { getPreferType } from '../common/Prefertype'

@ComponentV2
export default struct Homeweb {
  @Local url: string = ''
  @Local darkMode: WebDarkMode = WebDarkMode.Auto
  @Local optimizeParserBudget: boolean = false
  @Local preferType: number = 1
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  controller = new webview.WebviewController()

  build() {
    List() {
      if (!this.url) {
        ListItem() {
          Text('未登录账号')
        }
        .height('100%')
        .width('100%')
      }
      if (this.url) {
        ListItem() {
          Web({
            src: this.url,
            controller: this.controller,
            incognitoMode: true
          })
            .darkMode(this.darkMode)
            .domStorageAccess(true)
            .enableDataDetector(true)
            .enableNativeEmbedMode(true)
            .geolocationAccess(false)
            .margin({
              bottom: this.preferType === 0 ? 80 : 0,
              top: this.preferType === 0 ? 36 : 0
            })
            .nestedScroll({
              scrollForward: NestedScrollMode.SELF_ONLY,
              scrollBackward: NestedScrollMode.SELF_ONLY
            })
            .optimizeParserBudget(this.optimizeParserBudget)
            .pinchSmooth(true)
            .onControllerAttached(() => {
              this.controller.enableAdsBlock(true)
              this.controller.enableIntelligentTrackingPrevention(true)
              this.controller.enableSafeBrowsing(true)
              this.controller.setErrorPageEnabled(true)
              this.context.eventHub.on('backHomeweb', () => {
                this.controller.backward()
              })
              this.controller.loadUrl(this.url)
            })
            .onDisAppear(() => {
              this.context.eventHub.off('backHomeweb')
            })
            .onRefreshAccessedHistory(() => {
              setTempPreference(this.context, 'back', 'homeweb', this.controller.accessBackward())
            })
        }
      }
    }
    .onAppear(async () => {
      this.preferType = getPreferType(this.UIContext)
      display.on('change', () => {
        setTimeout(() => {
          this.preferType = getPreferType(this.UIContext)
        }, 200)
      })
      const colorMode = getFlushPreference(this.context, 'commonSetting', 'colorMode', 0)
      if (colorMode === 0) {
        this.darkMode = WebDarkMode.Auto
      }
      if (colorMode === 1) {
        this.darkMode = WebDarkMode.Off
      }
      if (colorMode === 2) {
        this.darkMode = WebDarkMode.On
      }
      this.optimizeParserBudget =
        getFlushPreference(this.context, 'debugSetting', 'optimizeParserBudget', true) as boolean
      const destroyMode = getFlushPreference(this.context, 'debugSetting', 'destroyMode',
        webview.WebDestroyMode.NORMAL_MODE) as webview.WebDestroyMode
      webview.WebviewController.setWebDestroyMode(destroyMode)
      this.context.eventHub.on('refreshHome', async () => {
        const accountInfo = await getAccountInfo(this.context)
        const oldUrlExist = this.url ? true : false
        this.url = accountInfo.path
        if (!this.url) {
          setTempPreference(this.context, 'back', 'homeweb', false)
        }
        if (this.url && oldUrlExist) {
          this.controller.loadUrl(this.url)
        }
      })
      const accountInfo = await getAccountInfo(this.context)
      this.url = accountInfo.path
      if (!this.url) {
        setTempPreference(this.context, 'back', 'homeweb', false)
      }
    })
    .onDisAppear(() => {
      this.context.eventHub.off('refreshHome')
    })
  }
}