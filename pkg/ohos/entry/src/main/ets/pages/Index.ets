import retroApi, { StartParams } from 'libretroarch.so';
import { RetroSettings } from '../entryability/RetroSetting';
import { RetroState } from '../entryability/RetroState';
import { User } from '../view/UserPrivacy';

enum CtlType{
  App_SHUTDOWN = 0
}

class GameXComponentController extends XComponentController{
  onSurfaceCreated(surfaceId: string): void {
    retroApi.surfaceChanged(parseInt(surfaceId), 0, 0)
  }
  onSurfaceChanged(surfaceId: string, rect: SurfaceRect): void {
    retroApi.surfaceChanged(parseInt(surfaceId), rect.surfaceWidth, rect.surfaceHeight)
  }
  onSurfaceDestroyed(surfaceId: string): void {
  }
}

@Entry
@ComponentV2
struct Index {

  private xController = new GameXComponentController();

  aboutToAppear(): void {

  }

  build() {
    Row() {
      XComponent({id:"game", type: XComponentType.TEXTURE, controller: this.xController})
        .backgroundColor(Color.Black)
        .width('100%')
        .height('100%')
        .constraintSize({ maxWidth: '100%', maxHeight: '100%' })
        .onLoad(()=>{
          setTimeout(()=>{
          }, 1000)
        })
        .onTouch((e: TouchEvent)=>{

          retroApi.onTouchEvent({
            id: e.target.id ?? 0,
            type: e.type,
            timestamp: e.timestamp,
            touches: e.touches.map((t)=>{
              return {
                id: t.id,
                x: this.vpToPx(t.x),
                y: this.vpToPx(t.y)
              } as TouchObject
            })
          })
        })
    }.width('100%')
    .foregroundBlurStyle(RetroState.showWelcome ? BlurStyle.BACKGROUND_THIN : BlurStyle.NONE,
      { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 0.3 })
    .bindSheet(RetroState.showWelcome!!, this.Welcome(), {
      height: 650,
      dragBar: false,
      showClose: false,
      preferType: SheetType.CENTER,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
      onWillSpringBackWhenDismiss: () => {},
      onWillAppear: () => {
      },
      onWillDismiss: (dis) => {
        if (!RetroState.showWelcome) {
          dis.dismiss()
        }
      },
      onDisappear: () => {
      }
    })
  }

  @Builder
  Welcome() {
    User()
  }

  public vpToPx(vp: number) {
    return this.getUIContext().vp2px(vp)
  }

  onPageShow(): void {
    if (RetroSettings.first_start) {
      // 延迟显示弹窗
      setTimeout(() => {
        RetroState.showWelcome = true;
        console.debug(`onPageShow: 半模态页已显示：${RetroState.showWelcome}`);
      }, 100);
    }
  }

  onBackPress(): boolean | void {
    // TODO 弹出提示退出
    //ßretroApi.sendCtl(CtlType.App_SHUTDOWN)
    return true;
  }

}
