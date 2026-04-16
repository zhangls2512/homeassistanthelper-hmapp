import { common } from '@kit.AbilityKit'
import { LoadingDialog, promptAction } from '@kit.ArkUI'
import { read } from '../common/File'
import { haRequest } from '../common/Request'
import { Param } from './Home'

@ComponentV2
export default struct Servicecall {
  @Consumer() isShowServicecallSheet: boolean = false
  @Param fields: Record<string, Param> = {}
  @Param path: string = ''
  @Local parameter: Record<string, Record<string, string>> = {}
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  body: Record<string, string | boolean | number> = {}
  supportedSelectors = ['text']

  getValue(key: string, value: string) {
    if (!this.parameter[key] || !this.parameter[key][value]) {
      return value
    }
    return this.parameter[key][value]
  }

  build() {
    List() {
      ForEach(Object.keys(this.fields), (item: string) => {
        ListItem() {
          Row() {
            if (this.fields[item].required) {
              Text('*')
                .fontColor(Color.Red)
                .fontWeight(FontWeight.Medium)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_s')
                })
            }
            Text(this.getValue('field', item))
              .fontWeight(FontWeight.Medium)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })

            ForEach(Object.keys(this.fields[item].selector), (selectorItem: string) => {
              if (selectorItem === 'text') {
                if (!this.fields[item].selector[selectorItem].multiline) {
                  TextInput({
                    placeholder: String(this.fields[item].example)
                  })
                    .enableAutoSpacing(true)
                    .layoutWeight(1)
                    .onChange(value => {
                      this.body[item] = value
                    })
                }
                if (this.fields[item].selector[selectorItem].multiline) {
                  TextArea({
                    placeholder: String(this.fields[item].example)
                  })
                    .enableAutoSpacing(true)
                    .layoutWeight(1)
                    .onChange(value => {
                      this.body[item] = value
                    })
                }
              }
              if (!this.supportedSelectors.includes(selectorItem)) {
                Text('此类型暂不支持输入')
                  .fontColor(Color.Red)
              }
            })
          }
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })
      })
      ListItem() {
        Button('提交')
          .width('100%')
          .onClick(async () => {
            let allInput = true
            Object.keys(this.fields).forEach(item => {
              if (this.fields[item].required && (this.body[item] === undefined || this.body[item] === '')) {
                allInput = false
              }
            })
            if (!allInput) {
              await promptAction.openToast({
                message: '请输入所有必填参数'
              })
              return
            }
            Object.keys(this.body).forEach(item => {
              if (typeof (this.fields[item].example) === 'string') {
                this.body[item] = String(this.body[item])
              }
              if (typeof (this.fields[item].example) === 'number') {
                this.body[item] = Number(this.body[item])
              }
            })
            const dialogControllerProgress = new CustomDialogController({
              builder: LoadingDialog({
                content: '请求中...'
              })
            })
            dialogControllerProgress.open()
            const res = await haRequest(this.context, this.path, 'POST', this.body)
            dialogControllerProgress.close()
            if (res !== 'fail') {
              await promptAction.openToast({
                message: '服务调用成功'
              })
              this.isShowServicecallSheet = false
            }
          })
      }
      .margin({
        top: $r('sys.float.ohos_id_elements_margin_vertical_l')
      })
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