import { common } from '@kit.AbilityKit'
import { read } from '../common/File'
import { ServiceItem } from './Home'

@ComponentV2
export default struct Servicecall {
  @Consumer() isShowServicecallSheet: boolean = false
  @Param services: ServiceItem = {
    domain: '',
    services: {}
  }
  @Param service: string = ''
  @Local parameter: Record<string, Record<string, string>> = {}
  context = this.getUIContext().getHostContext() as common.UIAbilityContext

  getValue(key: string, value: string) {
    if (!this.parameter[key] || !this.parameter[key][value]) {
      return value
    }
    return this.parameter[key][value]
  }

  build() {
    List() {
      ListItem() {
        Text(this.service)
          .onClick(() => {
            this.isShowServicecallSheet = false
          })
      }
    }
    .padding({
      bottom: $r('sys.float.ohos_id_default_padding_bottom_fixed'),
      left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
    })
    .onAppear(async () => {
      const res = await read(this.context.filesDir + '/parameter.txt', true)
      if (res !== 'fail') {
        this.parameter = JSON.parse(res)
      }
    })
  }
}