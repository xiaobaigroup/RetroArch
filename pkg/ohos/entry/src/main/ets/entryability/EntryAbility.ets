import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { SmartAvoidance, Xb_AvoidanceManager,
  Xb_GlobalContext, Xb_PreferenceUtil, Xb_ToastUtil } from 'xb_components';
import { RetroSettings } from './RetroSetting';
import { retroArchVM } from '../RetroArchViewModel';
import { RetroState } from './RetroState';
import { FileConnectUtil } from '../utils/FileConnectUtil';
import { deviceInfo } from '@kit.BasicServicesKit';

const DOMAIN = 0x0000;


export default class EntryAbility extends UIAbility {

  private avoidManager: Xb_AvoidanceManager | undefined = undefined;
  private avoidListener: (avoidance: SmartAvoidance) => void = (newAvoidance) => {
    RetroState.bottomRectHeight = newAvoidance.bottom
    RetroState.topRectHeight = newAvoidance.top
    RetroState.leftAvoidWidth = newAvoidance.left
    RetroState.rightAvoidWidth = newAvoidance.right
    console.debug(`EntryAbility avoidListener: ${JSON.stringify(newAvoidance)}`)
  }

  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    try {
      retroArchVM.init(this.context)
      Xb_GlobalContext.initContext(this.context)
      // 配置为深色模式
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      await Xb_PreferenceUtil.init(this.context, 'retro_arch_preference')
      // 加载配置
      RetroSettings.load()

      // 2. 处理文件打开请求（初始化后执行）
      setTimeout(()=>{
        FileConnectUtil.wantFile(want)
      }, 1000)
      
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  /**
   * 接收新的Want对象（热启动）
   * @param want - 新的Want对象
   * @param launchParam - 启动参数
   */
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'EntryAbility', 'Ability onNewWant')
    // 处理新的文件打开请求，替换当前游戏
    FileConnectUtil.wantFile(want)
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
    retroArchVM.stopApp();
  }

  onWindowStageWillDestroy(windowStage: window.WindowStage): void {
    retroArchVM.stopApp()
    // 销毁避让管理器并移除监听
    if (this.avoidManager) {
      this.avoidManager.offChangeListener(this.avoidListener);
      this.avoidManager.destroy();
      this.avoidManager = undefined;
    }
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    const mainWindow = windowStage.getMainWindowSync();
    //mainWindow.setPreferredOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
    mainWindow.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    mainWindow.setWindowSystemBarEnable([]);
    await mainWindow.setWindowLayoutFullScreen(true);
    windowStage.loadContent('pages/Index', async (err) => {
      await retroArchVM.StartApp();
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      try {
        const data = await windowStage.getMainWindow()
        Xb_ToastUtil.initContext(data.getUIContext(), this.context)
        // 获取布局避让遮挡的区域
        this.avoidManager = new Xb_AvoidanceManager(mainWindow, data.getUIContext());
        await this.avoidManager.init();
        // 注册监听器，当避让值变化时，更新UI状态
        this.avoidManager.onChangeListener(this.avoidListener);
      } catch (error) {
        console.error(`onWindowStageCreate error: ${error.message}`)
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

}
