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
  @Local body: Record<string, string | boolean | number | string[] | object> = {}
  @Local parameter: Record<string, Record<string, string>> = {}
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  supportedSelectors =
    ['text', 'number', 'boolean', 'select', 'date', 'time', 'datetime', 'entity', 'config_entry', 'theme', 'object',
      'statistic', 'state']

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
                    if (this.body[item]) {
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
                if (selectorItem === 'date') {
                  DatePicker({
                    start: new Date()
                  })
                    .onDateChange(value => {
                      this.body[item] =
                        value.getFullYear() + '/' + String(value.getMonth() + 1).padStart(2, '0') + '/' +
                          String(value.getDate()).padStart(2, '0')
                    })
                }
                if (selectorItem === 'time') {
                  TimePicker({
                    format: this.fields[item].example.split(':').length === 3 ? TimePickerFormat.HOUR_MINUTE_SECOND :
                      TimePickerFormat.HOUR_MINUTE
                  })
                    .margin({
                      top: $r('sys.float.ohos_id_elements_margin_vertical_m')
                    })
                    .onChange(value => {
                      this.body[item] = this.fields[item].example.split(':').length === 3 ?
                        String(value.hour).padStart(2, '0') + ':' + String(value.minute).padStart(2, '0') + ':' +
                          String(value.second).padStart(2, '0') :
                        String(value.hour).padStart(2, '0') + ':' + String(value.minute).padStart(2, '0')
                    })
                }
                if (selectorItem === 'datetime') {
                  DatePicker({
                    start: new Date()
                  })
                    .onDateChange(value => {
                      const data = value.getFullYear() + '-' + String(value.getMonth() + 1).padStart(2, '0') + '-' +
                        String(value.getDate()).padStart(2, '0') + ' '
                      if (!this.body[item]) {
                        this.body[item] = data
                        return
                      }
                      const old = this.body[item] as string
                      if (old.length === 8) {
                        this.body[item] = data + old
                        return
                      }
                      if (old.length === 11) {
                        this.body[item] = data
                        return
                      }
                      if (old.length === 19) {
                        this.body[item] = data + old.slice(11)
                      }
                    })
                  TimePicker({
                    format: TimePickerFormat.HOUR_MINUTE_SECOND
                  })
                    .margin({
                      top: $r('sys.float.ohos_id_elements_margin_vertical_m')
                    })
                    .onChange(value => {
                      const data =
                        String(value.hour).padStart(2, '0') + ':' + String(value.minute).padStart(2, '0') + ':' +
                          String(value.second).padStart(2, '0')
                      if (!this.body[item]) {
                        this.body[item] = data
                        return
                      }
                      const old = this.body[item] as string
                      if (old.length === 8) {
                        this.body[item] = data
                        return
                      }
                      if (old.length === 11) {
                        this.body[item] = old + data
                        return
                      }
                      if (old.length === 19) {
                        this.body[item] = old.slice(0, 11) + data
                      }
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
                if (selectorItem === 'config_entry') {
                  TextInput({
                    placeholder: this.fields[item].example
                  })
                    .enableAutoSpacing(true)
                    .onChange(value => {
                      this.body[item] = value
                    })
                }
                if (selectorItem === 'theme') {
                  TextInput({
                    placeholder: this.fields[item].example
                  })
                    .enableAutoSpacing(true)
                    .onChange(value => {
                      this.body[item] = value
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
                if (selectorItem === 'state') {
                  TextInput({
                    placeholder: this.fields[item].example
                  })
                    .enableAutoSpacing(true)
                    .onChange(value => {
                      this.body[this.fields[item].selector[selectorItem].attribute] = value
                    })
                }
                if (!this.supportedSelectors.includes(selectorItem)) {
                  Text('暂不支持输入' + selectorItem + '类型')
                    .enableAutoSpacing(true)
                    .fontColor(Color.Red)
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
                message: '请合法输入所有必填参数'
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
                message: '调用成功'
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