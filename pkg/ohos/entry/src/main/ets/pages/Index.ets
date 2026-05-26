import retroApi, { StartParams } from 'libretroarch.so';
import { RetroSettings, _RetroSettings } from '../entryability/RetroSetting';
import { RetroState } from '../entryability/RetroState';
import { User } from '../view/UserPrivacy';
import { KeyCode } from '@kit.InputKit';
import { RetroArchViewModel, retroArchVM } from '../RetroArchViewModel';
import window from '@ohos.window';
import { Xb_ToastUtil } from 'xb_components';

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
  @Local viewModel: RetroArchViewModel = retroArchVM;
  aboutToAppear(): void {
  }
  GetOrientation(): boolean {
    if (this.viewModel.currentRotation == window.Orientation.PORTRAIT || this.viewModel.currentRotation == window.Orientation.PORTRAIT_INVERTED) {
      return true
    } else
      return false
  }
  build() {
    Stack() {
      XComponent({id:"game", type: XComponentType.TEXTURE,libraryname: "retroarch", controller: this.xController})
        .backgroundColor(Color.Black)
        .width('100%')
        .height('100%')
        .constraintSize({ maxWidth: '100%', maxHeight: '100%' })
        // .aspectRatio(!this.viewModel.fullScreen ? this.GetAspectRatio(): undefined)
        .margin(!this.GetOrientation() ?
          { top: RetroState.topRectHeight, bottom: RetroState.bottomRectHeight, left: RetroState.leftAvoidWidth, right: RetroState.rightAvoidWidth} : undefined)
        .onLoad(()=>{ }).onTouch((e: TouchEvent)=>{
            // if(this.viewModel.loading)
            //   return;
            // retroApi.onTouchEvent({
            //   id: e.touches[e.touches.length - 1]?.id ?? 0,
            //   type: e.type,
            //   timestamp: e.timestamp,
            //   touches: e.touches.map((t)=>{
            //     return {
            //       id: t.id,
            //       x: this.vpToPx(t.x),
            //       y: this.vpToPx(t.y)
            //     } as TouchObject
            //   })
            // })
      }).defaultFocus(true).focusable(true).onKeyEvent((e: KeyEvent)=>{
        retroApi.onKeyEvent(e)
      })
      if (this.viewModel.loading) {
        Row () {
          Text("加载资源中").fontColor(Color.White)
        }
      }
    }.alignContent(Alignment.Center)
    .height('100%')
    .width('100%')
    .foregroundBlurStyle(RetroState.showBlur ? BlurStyle.BACKGROUND_THIN : BlurStyle.NONE,
      { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 0.3 })
  }

  public vpToPx(vp: number) {
    return this.getUIContext().vp2px(vp)
  }

  @Builder
  Welcome() {
    User()
  }

  onPageShow(): void {
  }

  onBackPress(): boolean | void {
    // TODO 弹出提示退出
    if (this.viewModel.openKeyboard) {
      this.viewModel.openKeyboard = false
      this.SendKeyEvent(KeyCode.KEYCODE_ENTER)
      return true;
    } else {
      this.SendKeyEvent(KeyCode.KEYCODE_DEL)
      // this.showExitDialog()
      return true;
    }
  }

  private showExitDialog() {
    Xb_ToastUtil.showAlertDialog({
      title: '是否退出应用',
      message: '',
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '退出',
        fontColor: Color.Red,
        action: async () => {
          Xb_ToastUtil.exitApp()
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }

  private SendKeyEvent(keycode: number){
    retroApi.onKeyEvent({
      type: 0,
      keyCode: keycode,
      source: KeySource.Keyboard,
    })
    setTimeout(()=>{
      retroApi.onKeyEvent({
        type: 1,
        keyCode: keycode,
        source: KeySource.Keyboard,
      })
    }, 100)
  }

}
