import { common } from '@kit.AbilityKit'
import { LoadingDialog, promptAction } from '@kit.ArkUI'
import { read } from '../common/File'
import { haRequest } from '../common/Request'
import { Param } from './Home'

@ComponentV2
export default struct Servicecall {
  @Consumer() isShowServicecallSheet: boolean = false
  @Param target: boolean = false
  @Param entityId: string = ''
  @Param fields: Record<string, Param> = {}
  @Param path: string = ''
  @Local body: Record<string, string | boolean | number | string[] | object> = {}
  @Local parameter: Record<string, Record<string, string>> = {}
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  supportedSelectors =
    ['text', 'number', 'boolean', 'select', 'date', 'time', 'datetime', 'entity', 'config_entry', 'theme', 'state',
      'conversation_agent', 'media', 'object', 'statistic', 'area', 'duration', 'color_rgb', 'color_temp']

  getValue(key: string, value: string) {
    if (!this.parameter[key] || !this.parameter[key][value]) {
      return value
    }
    return this.parameter[key][value]
  }

  build() {
    List() {
      if (this.target && !this.entityId) {
        ListItem() {
          Row() {
            Text('*')
              .fontColor($r('sys.color.warning'))
              .fontWeight(FontWeight.Medium)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_s')
              })
            Text(this.getValue('field', 'entity_id'))
              .enableAutoSpacing(true)
              .fontWeight(FontWeight.Medium)
              .margin({
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
            TextInput({
              placeholder: '实体ID'
            })
              .enableAutoSpacing(true)
              .layoutWeight(1)
              .onChange(value => {
                this.body.entity_id = value
              })
          }
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })
      }
      ForEach(Object.keys(this.fields), (item: string, index) => {
        if ((index !== 0 || (this.target && !this.entityId)) && this.fields[item].selector) {
          ListItem() {
            Divider()
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })
        }
        if (this.fields[item].selector) {
          ListItem() {
            Row() {
              if (this.fields[item].required) {
                Text('*')
                  .fontColor($r('sys.color.warning'))
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_s')
                  })
              }
              Text(this.getValue('field', item))
                .enableAutoSpacing(true)
                .fontWeight(FontWeight.Medium)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })
              Column() {
                ForEach(Object.keys(this.fields[item].selector), (selectorItem: string) => {
                  if (selectorItem === 'text') {
                    if (!this.fields[item].selector[selectorItem]) {
                      TextInput({
                        placeholder: this.fields[item].example ? String(this.fields[item].example) : ''
                      })
                        .enableAutoSpacing(true)
                        .onChange(value => {
                          this.body[item] = value
                        })
                    }
                    if (this.fields[item].selector[selectorItem]) {
                      if (!this.fields[item].selector[selectorItem].multiline) {
                        TextInput({
                          placeholder: this.fields[item].example ? String(this.fields[item].example) : ''
                        })
                          .enableAutoSpacing(true)
                          .onChange(value => {
                            this.body[item] = value
                          })
                      }
                      if (this.fields[item].selector[selectorItem].multiline) {
                        TextArea({
                          placeholder: this.fields[item].example ? String(this.fields[item].example) : ''
                        })
                          .enableAutoSpacing(true)
                          .onChange(value => {
                            this.body[item] = value
                          })
                      }
                    }
                  }
                  if (selectorItem === 'number') {
                    if (this.fields[item].selector[selectorItem].mode === 'box') {
                      TextInput({
                        placeholder: this.fields[item].example ? String(this.fields[item].example) : ''
                      })
                        .enableAutoSpacing(true)
                        .onChange(value => {
                          const num = Number(value)
                          if (!Number.isNaN(num) && num >= this.fields[item].selector[selectorItem].min &&
                            num <= this.fields[item].selector[selectorItem].max) {
                            this.body[item] = num
                          } else {
                            this.body[item] = ''
                          }
                        })
                    }
                    if (this.fields[item].selector[selectorItem].mode === 'slider') {
                      if (this.body[item] || this.body[item] === 0) {
                        Text(String(this.body[item]))
                      }
                      Slider({
                        min: this.fields[item].selector[selectorItem].min,
                        max: this.fields[item].selector[selectorItem].max,
                        step: this.fields[item].selector[selectorItem].step
                      })
                        .onChange(value => {
                          this.body[item] = value
                          this.body = JSON.parse(JSON.stringify(this.body))
                        })
                    }
                  }
                  if (selectorItem === 'boolean') {
                    Toggle({
                      type: ToggleType.Switch
                    })
                      .onChange(isOn => {
                        this.body[item] = isOn
                      })
                  }
                  if (selectorItem === 'select') {
                    if (!this.fields[item].selector[selectorItem].multiple) {
                      Select(this.fields[item].selector[selectorItem].options.map((item): SelectOption => {
                        return {
                          value: this.getValue('selectitem', item)
                        }
                      }))
                        .onSelect(index => {
                          this.body[item] = this.fields[item].selector[selectorItem].options[index]
                        })
                    }
                    if (this.fields[item].selector[selectorItem].multiple) {
                      Row() {
                        CheckboxGroup({
                          group: item
                        })
                          .checkboxShape(CheckBoxShape.ROUNDED_SQUARE)
                          .margin({
                            right: $r('sys.float.ohos_id_elements_margin_horizontal_s')
                          })
                          .onChange(itemName => {
                            const selectItemMap: Record<string, string> = {}
                            this.fields[item].selector[selectorItem].options.forEach(item => {
                              selectItemMap[this.getValue('selectitem', item)] = item
                            })
                            this.body[item] = itemName.name.map(item => selectItemMap[item])
                          })
                        Text('全选')
                          .fontWeight(FontWeight.Medium)
                      }

                      ForEach(this.fields[item].selector[selectorItem].options, (optionItem: string) => {
                        Row() {
                          Checkbox({
                            name: this.getValue('selectitem', optionItem),
                            group: item
                          })
                            .margin({
                              right: $r('sys.float.ohos_id_elements_margin_horizontal_s')
                            })
                            .shape(CheckBoxShape.ROUNDED_SQUARE)
                          Text(this.getValue('selectitem', optionItem))
                            .fontWeight(FontWeight.Medium)
                        }
                      })
                    }
                  }
                  if (['date', 'time', 'datetime', 'config_entry', 'theme', 'state', 'conversation_agent',
                    'media'].includes(selectorItem)) {
                    TextInput({
                      placeholder: this.fields[item].example ? this.fields[item].example : ''
                    })
                      .enableAutoSpacing(true)
                      .onChange(value => {
                        this.body[item] = value
                      })
                  }
                  if (selectorItem === 'entity') {
                    TextInput({
                      placeholder: this.fields[item].selector[selectorItem].multiple ? '实体ID数组' : '实体ID'
                    })
                      .enableAutoSpacing(true)
                      .onChange(value => {
                        if (!this.fields[item].selector[selectorItem].multiple) {
                          this.body[item] = value
                        }
                        if (this.fields[item].selector[selectorItem].multiple) {
                          try {
                            const entityIdArray = JSON.parse(value) as string[]
                            if (Array.isArray(entityIdArray) &&
                              entityIdArray.every(entityId => typeof (entityId) === 'string')) {
                              this.body[item] = entityIdArray
                            } else {
                              this.body[item] = ''
                            }
                          } catch {
                            this.body[item] = ''
                          }
                        }
                      })
                  }
                  if (selectorItem === 'object') {
                    TextInput({
                      placeholder: 'JSON对象'
                    })
                      .enableAutoSpacing(true)
                      .onChange(value => {
                        try {
                          const object = JSON.parse(value) as object
                          if (value.startsWith('{') && value.endsWith('}')) {
                            this.body[item] = object
                          } else {
                            this.body[item] = ''
                          }
                        } catch {
                          this.body[item] = ''
                        }
                      })
                  }
                  if (selectorItem === 'statistic') {
                    TextInput({
                      placeholder: '统计ID数组'
                    })
                      .enableAutoSpacing(true)
                      .onChange(value => {
                        try {
                          const statisticIdArray = JSON.parse(value) as string[]
                          if (Array.isArray(statisticIdArray) &&
                            statisticIdArray.every(statisticId => typeof (statisticId) === 'string')) {
                            this.body[item] = statisticIdArray
                          } else {
                            this.body[item] = ''
                          }
                        } catch {
                          this.body[item] = ''
                        }
                      })
                  }
                  if (selectorItem === 'area') {
                    TextInput({
                      placeholder: this.fields[item].selector[selectorItem].multiple ? '区域ID数组' : '区域ID'
                    })
                      .enableAutoSpacing(true)
                      .onChange(value => {
                        if (!this.fields[item].selector[selectorItem].multiple) {
                          this.body[item] = value
                        }
                        if (this.fields[item].selector[selectorItem].multiple) {
                          try {
                            const areaIdArray = JSON.parse(value) as string[]
                            if (Array.isArray(areaIdArray) &&
                              areaIdArray.every(areaId => typeof (areaId) === 'string')) {
                              this.body[item] = areaIdArray
                            } else {
                              this.body[item] = ''
                            }
                          } catch {
                            this.body[item] = ''
                          }
                        }
                      })
                  }
                  if (selectorItem === 'duration') {
                    TextInput({
                      placeholder: '符合ISO8601标准的持续时间字符串'
                    })
                      .enableAutoSpacing(true)
                      .onChange(value => {
                        this.body[item] = value
                      })
                  }
                  if (selectorItem === 'color_rgb') {
                    TextInput({
                      placeholder: 'RGB颜色值数组'
                    })
                      .enableAutoSpacing(true)
                      .onChange(value => {
                        try {
                          const rgbArray = JSON.parse(value) as number[]
                          if (!Array.isArray(rgbArray) || rgbArray.length !== 3 ||
                            rgbArray.some(rgb => !Number.isInteger(rgb))) {
                            this.body[item] = ''
                            return
                          }
                          if (!rgbArray.every(rgb => rgb >= 0 && rgb <= 255)) {
                            this.body[item] = ''
                            return
                          }
                          this.body[item] = rgbArray
                        } catch {
                          this.body[item] = ''
                        }
                      })
                  }
                  if (selectorItem === 'color_temp') {
                    TextInput({
                      placeholder: '色温值，单位：' + this.fields[item].selector[selectorItem].unit
                    })
                      .enableAutoSpacing(true)
                      .onChange(value => {
                        const colorTemp = Number(value)
                        if (!Number.isInteger(colorTemp) || colorTemp < this.fields[item].selector[selectorItem].min ||
                          colorTemp > this.fields[item].selector[selectorItem].max) {
                          this.body[item] = ''
                        } else {
                          this.body[item] = colorTemp
                        }
                      })
                  }
                  if (!this.supportedSelectors.includes(selectorItem)) {
                    Text('暂不支持输入' + selectorItem + '类型')
                      .enableAutoSpacing(true)
                      .fontColor($r('sys.color.warning'))
                  }
                })
              }
              .alignItems(HorizontalAlign.End)
              .layoutWeight(1)
            }
          }
          .margin({
            top: $r('sys.float.ohos_id_elements_margin_vertical_m')
          })
        }
      })
      ListItem() {
        Button('提交')
          .width('100%')
          .onClick(async () => {
            let allInput = true
            if (!this.body.entity_id && this.target) {
              allInput = false
            }
            Object.keys(this.fields).forEach(item => {
              if (this.fields[item].required && (this.body[item] === undefined || this.body[item] === '')) {
                allInput = false
              }
            })
            if (!allInput) {
              await promptAction.openToast({
                message: '请合法输入所有必填参数'
              })
              return
            }
            Object.keys(this.body).forEach(item => {
              if (this.fields[item] && this.fields[item].example) {
                if (typeof (this.fields[item].example) === 'string') {
                  this.body[item] = String(this.body[item])
                }
                if (typeof (this.fields[item].example) === 'number') {
                  this.body[item] = Number(this.body[item])
                }
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
                message: '调用成功'
              })
              this.context.eventHub.emit('refreshHome')
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
      if (this.entityId) {
        this.body.entity_id = this.entityId
      }
    })
  }
}