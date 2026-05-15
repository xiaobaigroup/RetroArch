import { Xb_GetResourceString, Xb_PriUserComWeb } from "xb_components"
import { RetroSettings } from "../entryability/RetroSetting"
import { RetroState } from "../entryability/RetroState"


@Builder
export function UserPageBuilder(name: string) {
  UserNavD()
}

@ComponentV2
struct UserNavD {

  @Local needTopMargin: boolean = false
  @Local pageStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      User({
        needTopMargin: this.needTopMargin,
        normalPageStack: this.pageStack
      })
    }
    .hideBackButton(true)
    .hideTitleBar(true)
    .onReady((ctx) => {
      this.pageStack = ctx.pathStack
      const param = ctx.pathInfo.param as boolean
      if (param) {
        this.needTopMargin = param
      }
    })
  }

}

@ComponentV2
export struct User {

  @Param normalPageStack: NavPathStack = new NavPathStack()
  @Param needTopMargin: boolean = false

  private pageStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.pageStack) {
      this.Content()
    }
    .width('100%')
    .height('100%')
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
    .padding({ top: RetroSettings.first_start ? 0 : 8 })
  }

  @Builder
  Content() {
    Stack() {
      Xb_PriUserComWeb({
        appName: Xb_GetResourceString($r('app.string.EntryAbility_label'), this),
        needAccount: true,
        needOpenSource: true,
        isWelcomeStack: RetroSettings.first_start,
        nextPage: 'privacy',
        topWebPaddingValue: { top: 35 },
        onRightCheck: RetroSettings.first_start ? () => {
          this.pageStack.pushPathByName('privacy', false, true)
        } : () => {
          this.normalPageStack.pushPathByName('privacy', this.needTopMargin, true)
        },
        onLeftCheck: RetroSettings.first_start ? undefined : () => {
          this.normalPageStack.pop(true)
        },
        priuserPageInfos: this.pageStack,
        currentLanguage: 'zh-CN',
        docSrc: $rawfile('html/user_agreement.html'),
      })
      Row() {
        Text($r('app.string.xb_user_agreement'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
      }
      .height(RetroSettings.first_start ? 72 : 27)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({ top: this.needTopMargin ? 8 : undefined })
    }
    .alignContent(Alignment.Top)
    .backgroundColor($r('sys.color.background_secondary'))
  }

}


@Builder
export function PrivacyPageBuilder(name: string) {
  Privacy()
}

@ComponentV2
struct Privacy {

  @Local needTopMargin: boolean = false
  private pageStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Xb_PriUserComWeb({
        isEnd: !RetroSettings.first_start,
        appName: Xb_GetResourceString($r('app.string.EntryAbility_label'), this),
        needAccount: true,
        needOpenSource: true,
        onLeftCheck: undefined,
        onRightCheck: RetroSettings.first_start ? () => {
          this.pageStack.pushPathByName('welcome', false, true)
        } : () => {
          this.pageStack.clear()
        },
        isWelcomeStack: RetroSettings.first_start,
        priuserPageInfos: this.pageStack,
        currentLanguage: 'zh-CN',
        docSrc: $rawfile('html/privacy.html'),
      })
    }
    .title($r('app.string.xb_privacy'))
    .width('100%')
    .height('100%')
    .padding({ top: this.needTopMargin ? 21 : 8 })
    .onReady((ctx) => {
      this.pageStack = ctx.pathStack
      const param = ctx.pathInfo.param as boolean
      if (param) {
        this.needTopMargin = param
      }
    })
  }

}

@Builder
export function WelcomePageBuilder(name: string) {
  Welcome()
}

@ComponentV2
struct Welcome {

  private pageStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column() {
        this.content()
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .title('欢迎')
    .width('100%')
    .height('100%')
    .onReady((ctx) => {
      this.pageStack = ctx.pathStack
    })
  }

  @Builder
  content() {
    // Logo & 欢迎语
    Column({space: 15}) {
      // logo
      Image($r(`app.media.app_icon_round`))
        .borderRadius(25)
        .height(106)
        .zIndex(1)
      // 名称
      // Image($r(`app.media.`))
      //   .width(192)
    }.width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    // 提示
    Column() {
      SymbolGlyph($r('sys.symbol.person_shield_fill'))
        .fontSize(20)
        .margin({bottom: 3})
        .fontColor([$r('sys.color.icon_emphasize')])
        .onClick(() => {
          this.pageStack.pop(true)
        })
      Flex({
        direction: FlexDirection.Row
      }) {
        Button($r('app.string.xb_return'))
          .width('50%')
          .margin({ right: 16 })
          .fontColor($r('sys.color.icon_emphasize'))
          .backgroundColor($r('sys.color.container_modal_background'))
          .onClick(() => {
            this.pageStack.pop(true)
          })
        Button($r('app.string.xb_confirm'))
          .width('50%')
          .fontColor(Color.White)
          .backgroundColor($r('sys.color.icon_emphasize'))
          .onClick(() => {
            // 第一次启动应用
            RetroSettings.first_start = false
            // 关闭模态页
            RetroState.showWelcome = false
            RetroSettings.save()
            // this.tryShowUpdateLog()
          })
      }.width('90%')
      .margin({ top: 12, bottom: 5 })
    }.width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({left: 5, right: 5, bottom: 15})
  }

  // tryShowUpdateLog() {
  //   setTimeout(() => {
  //     RetroState.showWelcome = true
  //     console.error(`Update WelcomePage isShowWelcome：${RetroState.showWelcome}`)
  //   }, 500)
  // }

}
