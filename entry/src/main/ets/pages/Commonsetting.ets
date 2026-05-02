import { common, ConfigurationConstant } from '@kit.AbilityKit'
import { LengthMetrics, LoadingDialog, promptAction, window } from '@kit.ArkUI'
import { deviceInfo } from '@kit.BasicServicesKit'
import { fileIo } from '@kit.CoreFileKit'
import { image } from '@kit.ImageKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from '@kit.UIDesignKit'
import { generateBestAddress } from '../common/Account'
import { downloadParameter } from '../common/Parameter'
import { getFlushPreference, setFlushPreference } from '../common/Preference'

@Builder
export function CommonsettingBuilder() {
  Commonsetting()
}

@ComponentV2
struct Commonsetting {
  @Local allowContinue: boolean = false
  @Local exitAfterContinue: boolean = false
  @Local allowRestore: boolean = false
  @Local acceptCollaborate: boolean = false
  @Local destroyWhenBackPressed: boolean = false
  @Local statusBar: boolean = false
  @Local colorModeIndex: number = 0
  @Local colorModeValue: string = '跟随系统'
  @Local windowRectAutoSave: boolean = false
  @Local windowTopmost: boolean = false
  @Local keepScreenOn: boolean = false
  @Local showAccountlistSheetAfterAppLaunch: boolean = false
  @Local downloadParameterAfterAppLaunch: boolean = true
  @Local defaultUseWeb: boolean = false
  @Local checkVersionUpdateIndex: number = 1
  @Local checkVersionUpdateValue: string = '非流量下'
  @Local openLinkTypeIndex: number = 0
  @Local openLinkTypeValue: string = '系统默认'
  @Local hoverId: number = -1
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext
  pageInfos = new NavPathStack()
  dialogControllerProgress = new CustomDialogController({
    builder: LoadingDialog({
      content: '请求中...'
    })
  })

  build() {
    HdsNavDestination() {
      List() {
        ListItem()
          .margin({
            top: 64
          })
        ListItem() {
          Column() {
            Text('应用')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              Row() {
                Text('接续')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.allowContinue!!
                })
                  .onChange(async (isOn) => {
                    setFlushPreference(this.context, 'commonSetting', 'allowContinue', isOn)
                    const promptAction = this.UIContext.getPromptAction()
                    const data = await promptAction.showDialog({
                      title: '提示',
                      message: '设置成功，需重启应用生效，是否重启？',
                      buttons: [
                        {
                          text: '取消',
                          color: $r('sys.color.font_primary')
                        },
                        {
                          text: '重启',
                          color: $r('sys.color.font_emphasize')
                        }
                      ]
                    })
                    if (data.index === 1) {
                      const applicationContext = this.context.getApplicationContext()
                      applicationContext.restartApp({
                        bundleName: 'com.songjy.homeassistanthelper',
                        abilityName: 'EntryAbility'
                      })
                    }
                  })
              }
              .borderRadius(12)
              .padding(12)

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('接续成功后退出')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.exitAfterContinue!!
                })
                  .onChange(isOn => {
                    setFlushPreference(this.context, 'commonSetting', 'exitAfterContinue', isOn)
                  })
              }
              .borderRadius(12)
              .padding(12)

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('备份恢复')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.allowRestore!!
                })
                  .onChange(async (isOn) => {
                    setFlushPreference(this.context, 'commonSetting', 'allowRestore', isOn)
                    const promptAction = this.UIContext.getPromptAction()
                    const data = await promptAction.showDialog({
                      title: '提示',
                      message: '设置成功，需重启应用生效，是否重启？',
                      buttons: [
                        {
                          text: '取消',
                          color: $r('sys.color.font_primary')
                        },
                        {
                          text: '重启',
                          color: $r('sys.color.font_emphasize')
                        }
                      ]
                    })
                    if (data.index === 1) {
                      const applicationContext = this.context.getApplicationContext()
                      applicationContext.restartApp({
                        bundleName: 'com.songjy.homeassistanthelper',
                        abilityName: 'EntryAbility'
                      })
                    }
                  })
              }
              .borderRadius(12)
              .padding(12)

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('接受协同')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.acceptCollaborate!!
                })
                  .onChange(isOn => {
                    setFlushPreference(this.context, 'commonSetting', 'acceptCollaborate', isOn)
                  })
              }
              .borderRadius(12)
              .padding(12)

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('侧滑返回时退出')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.destroyWhenBackPressed!!
                })
                  .onChange(isOn => {
                    setFlushPreference(this.context, 'commonSetting', 'destroyWhenBackPressed', isOn)
                  })
              }
              .borderRadius(12)
              .padding(12)

              if (deviceInfo.deviceType === '2in1') {
                Divider()
                  .padding({
                    left: 12,
                    right: 12
                  })
                Row() {
                  Text('状态栏')
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                  Toggle({
                    type: ToggleType.Switch,
                    isOn: this.statusBar!!
                  })
                    .onChange(async (isOn) => {
                      setFlushPreference(this.context, 'commonSetting', 'statusBar', isOn)
                      const promptAction = this.UIContext.getPromptAction()
                      const data = await promptAction.showDialog({
                        title: '提示',
                        message: '设置成功，需重启应用生效，是否重启？',
                        buttons: [
                          {
                            text: '取消',
                            color: $r('sys.color.font_primary')
                          },
                          {
                            text: '重启',
                            color: $r('sys.color.font_emphasize')
                          }
                        ]
                      })
                      if (data.index === 1) {
                        const applicationContext = this.context.getApplicationContext()
                        applicationContext.restartApp({
                          bundleName: 'com.songjy.homeassistanthelper',
                          abilityName: 'EntryAbility'
                        })
                      }
                    })
                }
                .borderRadius(12)
                .padding(12)
              }
              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('防窥保护')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Text('去设置')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_s')
                  })
                Image($r('app.media.right'))
                  .fillColor($r('sys.color.icon_fourth'))
                  .height(12)
                  .width(12)
              }
              .borderRadius(12)
              .padding(12)
              .stateStyles({
                normal: {
                  .backgroundColor(this.hoverId === 0 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 0
                }
              })
              .onClick(async () => {
                await this.context.startAbility({
                  bundleName: 'com.huawei.hmos.settings',
                  abilityName: 'com.huawei.hmos.settings.MainAbility',
                  uri: 'privacy_settings',
                  parameters: {
                    pushParams: 'com.songjy.homeassistanthelper'
                  }
                })
              })
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_m')
        })

        ListItem() {
          Column() {
            Text('界面')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              Row() {
                Column() {
                  Text('深色模式')
                    .fontWeight(FontWeight.Medium)
                  Text('不对卡片生效')
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .margin({
                      top: $r('sys.float.ohos_id_text_margin_vertical')
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })

                Select([
                  { value: '跟随系统' },
                  { value: '浅色模式' },
                  { value: '深色模式' }
                ])
                  .selected(this.colorModeIndex!!)
                  .value(this.colorModeValue!!)
                  .onSelect(index => {
                    const applicationContext = this.context.getApplicationContext()
                    if (index === 0) {
                      applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
                    }
                    if (index === 1) {
                      applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
                    }
                    if (index === 2) {
                      applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
                    }
                    setFlushPreference(this.context, 'commonSetting', 'colorMode', index)
                  })
              }
              .borderRadius(12)
              .padding(12)

              if (deviceInfo.deviceType === '2in1') {
                Divider()
                  .padding({
                    left: 12,
                    right: 12
                  })
                Row() {
                  Text('记忆主窗口尺寸')
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                  Toggle({
                    type: ToggleType.Switch,
                    isOn: this.windowRectAutoSave!!
                  })
                    .onChange(async (isOn) => {
                      setFlushPreference(this.context, 'commonSetting', 'windowRectAutoSave', isOn)
                      const promptAction = this.UIContext.getPromptAction()
                      const data = await promptAction.showDialog({
                        title: '提示',
                        message: '设置成功，需重启应用生效，是否重启？',
                        buttons: [
                          {
                            text: '取消',
                            color: $r('sys.color.font_primary')
                          },
                          {
                            text: '重启',
                            color: $r('sys.color.font_emphasize')
                          }
                        ]
                      })
                      if (data.index === 1) {
                        const applicationContext = this.context.getApplicationContext()
                        applicationContext.restartApp({
                          bundleName: 'com.songjy.homeassistanthelper',
                          abilityName: 'EntryAbility'
                        })
                      }
                    })
                }
                .borderRadius(12)
                .padding(12)

                Divider()
                  .padding({
                    left: 12,
                    right: 12
                  })
                Row() {
                  Text('窗口置顶')
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                  Toggle({
                    type: ToggleType.Switch,
                    isOn: this.windowTopmost!!
                  })
                    .onChange(async (isOn) => {
                      const lastWindow = await window.getLastWindow(this.context)
                      await lastWindow.setWindowTopmost(isOn)
                      setFlushPreference(this.context, 'commonSetting', 'windowTopmost', isOn)
                    })
                }
                .borderRadius(12)
                .padding(12)
              }
              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Column() {
                  Text('屏幕常亮')
                    .fontWeight(FontWeight.Medium)
                  Text('仅在本次使用期间生效')
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .margin({
                      top: $r('sys.float.ohos_id_text_margin_vertical')
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({
                  right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                })

                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.keepScreenOn!!
                })
                  .onChange(async (isOn) => {
                    const lastWindow = await window.getLastWindow(this.context)
                    await lastWindow.setWindowKeepScreenOn(isOn)
                  })
              }
              .borderRadius(12)
              .padding(12)

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('背景图')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Image($r('app.media.right'))
                  .fillColor($r('sys.color.icon_fourth'))
                  .height(12)
                  .width(12)
              }
              .borderRadius(12)
              .padding(12)
              .stateStyles({
                normal: {
                  .backgroundColor(this.hoverId === 1 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 1
                }
              })
              .onClick(async () => {
                const backgroundImagePath = this.context.filesDir + '/media/backgroundimage.png'
                const res = fileIo.accessSync(backgroundImagePath)
                if (!res) {
                  try {
                    const photoPicker = new photoAccessHelper.PhotoViewPicker()
                    const pickerres = await photoPicker.select({
                      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
                      maxSelectNumber: 1,
                      isOriginalSupported: false
                    })
                    const fileSource = fileIo.openSync(pickerres.photoUris[0])
                    const imageSource = image.createImageSource(fileSource.fd)
                    const imagePixelMap = await imageSource.createPixelMap()
                    await imageSource.release()
                    if (!fileIo.accessSync(this.context.filesDir + '/media')) {
                      await fileIo.mkdir(this.context.filesDir + '/media')
                    }
                    const file =
                      fileIo.openSync(backgroundImagePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
                    const imagePacker = image.createImagePacker()
                    await imagePacker.packToFile(imagePixelMap, file.fd, {
                      format: 'image/png',
                      quality: 100
                    })
                    await imagePacker.release()
                    await imagePixelMap.release()
                    fileIo.closeSync(file)
                    this.context.eventHub.emit('refreshIndex')
                  } catch {
                  }
                  return
                }
                if (res) {
                  const promptAction = this.UIContext.getPromptAction()
                  const data = await promptAction.showActionMenu({
                    title: '设置背景图',
                    buttons: [
                      {
                        text: '从图库中选择',
                        color: $r('sys.color.font_primary')
                      },
                      {
                        text: '恢复默认',
                        color: $r('sys.color.font_primary')
                      }
                    ]
                  })
                  if (data.index === 0) {
                    try {
                      const photoPicker = new photoAccessHelper.PhotoViewPicker()
                      const pickerres = await photoPicker.select({
                        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
                        maxSelectNumber: 1,
                        isOriginalSupported: false
                      })
                      const fileSource = fileIo.openSync(pickerres.photoUris[0])
                      const imageSource = image.createImageSource(fileSource.fd)
                      const imagePixelMap = await imageSource.createPixelMap()
                      await imageSource.release()
                      const file =
                        fileIo.openSync(backgroundImagePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
                      const imagePacker = image.createImagePacker()
                      await imagePacker.packToFile(imagePixelMap, file.fd, {
                        format: 'image/png',
                        quality: 100
                      })
                      await imagePacker.release()
                      await imagePixelMap.release()
                      fileIo.closeSync(file)
                      this.context.eventHub.emit('refreshIndex')
                    } catch {
                    }
                  }
                  if (data.index === 1) {
                    await fileIo.unlink(backgroundImagePath)
                    this.context.eventHub.emit('refreshIndex')
                  }
                }
              })
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        ListItem() {
          Column() {
            Text('性能')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              Row() {
                Text('刷新最佳地址')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Image($r('app.media.right'))
                  .fillColor($r('sys.color.icon_fourth'))
                  .height(12)
                  .width(12)
              }
              .borderRadius(12)
              .padding(12)
              .stateStyles({
                normal: {
                  .backgroundColor(this.hoverId === 2 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 2
                }
              })
              .onClick(async () => {
                this.dialogControllerProgress.open()
                await generateBestAddress(this.context)
                this.dialogControllerProgress.close()
                await promptAction.openToast({
                  message: '刷新成功'
                })
              })

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('最佳地址')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Image($r('app.media.right'))
                  .fillColor($r('sys.color.icon_fourth'))
                  .height(12)
                  .width(12)
              }
              .borderRadius(12)
              .padding(12)
              .stateStyles({
                normal: {
                  .backgroundColor(this.hoverId === 3 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 3
                }
              })
              .onClick(() => {
                this.pageInfos.pushPath({
                  name: 'Bestaddress'
                })
              })
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        ListItem() {
          Column() {
            Text('更多')
              .fontColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Medium)
              .margin({
                bottom: 6,
                left: 12,
                right: 12
              })
            Column() {
              Row() {
                Text('应用启动后拉起切换账号弹窗')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.showAccountlistSheetAfterAppLaunch!!
                })
                  .onChange(isOn => {
                    setFlushPreference(this.context, 'commonSetting', 'showAccountlistSheetAfterAppLaunch', isOn)
                  })
              }
              .borderRadius(12)
              .padding(12)

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('应用启动后下载并更新参数')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Toggle({
                  type: ToggleType.Switch,
                  isOn: this.downloadParameterAfterAppLaunch!!
                })
                  .onChange(isOn => {
                    setFlushPreference(this.context, 'commonSetting', 'downloadParameterAfterAppLaunch', isOn)
                  })
              }
              .borderRadius(12)
              .padding(12)

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('下载并更新参数')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Image($r('app.media.right'))
                  .fillColor($r('sys.color.icon_fourth'))
                  .height(12)
                  .width(12)
              }
              .borderRadius(12)
              .padding(12)
              .stateStyles({
                normal: {
                  .backgroundColor(this.hoverId === 3 ? $r('sys.color.interactive_hover') :
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
                  this.hoverId = 3
                }
              })
              .onClick(async () => {
                this.dialogControllerProgress.open()
                const res = await downloadParameter(this.context)
                this.dialogControllerProgress.close()
                if (res !== 'fail') {
                  if (!res) {
                    await promptAction.openToast({
                      message: '已是最新'
                    })
                  }
                  if (res) {
                    await promptAction.openToast({
                      message: '已更新'
                    })
                  }
                }
              })

              if (deviceInfo.deviceType !== '2in1') {
                Divider()
                  .padding({
                    left: 12,
                    right: 12
                  })
                Row() {
                  Text('默认使用网页')
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
                    .margin({
                      right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                    })
                  Toggle({
                    type: ToggleType.Switch,
                    isOn: this.defaultUseWeb!!
                  })
                    .onChange(isOn => {
                      setFlushPreference(this.context, 'commonSetting', 'defaultUseWeb', isOn)
                    })
                }
                .borderRadius(12)
                .padding(12)
              }
              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('启动时检查更新')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Select([
                  { value: '从不' },
                  { value: '非流量下' },
                  { value: '始终' }
                ])
                  .selected(this.checkVersionUpdateIndex!!)
                  .value(this.checkVersionUpdateValue!!)
                  .onSelect(index => {
                    setFlushPreference(this.context, 'commonSetting', 'checkVersionUpdate', index)
                  })
              }
              .borderRadius(12)
              .padding(12)

              Divider()
                .padding({
                  left: 12,
                  right: 12
                })
              Row() {
                Text('链接打开方式')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .margin({
                    right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
                  })
                Select([
                  { value: '系统默认' },
                  { value: '自行选择' }
                ])
                  .selected(this.openLinkTypeIndex!!)
                  .value(this.openLinkTypeValue!!)
                  .onSelect(index => {
                    setFlushPreference(this.context, 'commonSetting', 'openLinkType', index)
                  })
              }
              .borderRadius(12)
              .padding(12)
            }
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .padding($r('sys.float.ohos_id_corner_radius_mark'))
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({
          top: $r('sys.float.ohos_id_elements_margin_vertical_l')
        })

        ListItem()
          .margin({
            bottom: 28
          })
      }
      .padding({
        left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
      })
    }
    .backgroundColor($r('app.color.sheet_background'))
    .recoverable(true)
    .titleBar({
      padding: {
        end: LengthMetrics.vp(60)
      },
      style: {
        scrollEffectOpts: {
          scrollEffectType: ScrollEffectType.IMMERSIVE_GRADIENT_BLUR
        },
        originalStyle: {
          contentStyle: {
            titleStyle: {
              mainTitleColor: $r('sys.color.font_primary')
            },
            backIconStyle: {
              iconColor: $r('sys.color.icon_primary')
            }
          }
        },
        thermoCtrl: true,
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        }
      },
      content: {
        title: {
          mainTitle: '通用'
        }
      }
    })
    .titleMode(HdsNavDestinationTitleMode.MODAL)
    .onReady(async (context) => {
      this.pageInfos = context.pathStack
      this.allowContinue = getFlushPreference(this.context, 'commonSetting', 'allowContinue', true) as boolean
      this.exitAfterContinue = getFlushPreference(this.context, 'commonSetting', 'exitAfterContinue', true) as boolean
      this.allowRestore = getFlushPreference(this.context, 'commonSetting', 'allowRestore', true) as boolean
      this.acceptCollaborate = getFlushPreference(this.context, 'commonSetting', 'acceptCollaborate', true) as boolean
      this.destroyWhenBackPressed =
        getFlushPreference(this.context, 'commonSetting', 'destroyWhenBackPressed', false) as boolean
      this.statusBar = getFlushPreference(this.context, 'commonSetting', 'statusBar', false) as boolean
      const colorMode = getFlushPreference(this.context, 'commonSetting', 'colorMode', 0)
      this.colorModeIndex = colorMode as number
      if (colorMode === 0) {
        this.colorModeValue = '跟随系统'
      }
      if (colorMode === 1) {
        this.colorModeValue = '浅色模式'
      }
      if (colorMode === 2) {
        this.colorModeValue = '深色模式'
      }
      this.windowRectAutoSave =
        getFlushPreference(this.context, 'commonSetting', 'windowRectAutoSave', false) as boolean
      this.windowTopmost = getFlushPreference(this.context, 'commonSetting', 'windowTopmost', false) as boolean
      const lastWindow = await window.getLastWindow(this.context)
      this.keepScreenOn = lastWindow.getWindowProperties().isKeepScreenOn
      this.showAccountlistSheetAfterAppLaunch =
        getFlushPreference(this.context, 'commonSetting', 'showAccountlistSheetAfterAppLaunch', false) as boolean
      this.downloadParameterAfterAppLaunch =
        getFlushPreference(this.context, 'commonSetting', 'downloadParameterAfterAppLaunch', true) as boolean
      this.defaultUseWeb = getFlushPreference(this.context, 'commonSetting', 'defaultUseWeb', false) as boolean
      const checkVersionUpdate = getFlushPreference(this.context, 'commonSetting', 'checkVersionUpdate', 1)
      this.checkVersionUpdateIndex = checkVersionUpdate as number
      if (checkVersionUpdate === 0) {
        this.checkVersionUpdateValue = '从不'
      }
      if (checkVersionUpdate === 1) {
        this.checkVersionUpdateValue = '非流量下'
      }
      if (checkVersionUpdate === 2) {
        this.checkVersionUpdateValue = '始终'
      }
      const openLinkType = getFlushPreference(this.context, 'commonSetting', 'openLinkType', 0)
      this.openLinkTypeIndex = openLinkType as number
      if (openLinkType === 0) {
        this.openLinkTypeValue = '系统默认'
      }
      if (openLinkType === 1) {
        this.openLinkTypeValue = '自行选择'
      }
    })
  }
}