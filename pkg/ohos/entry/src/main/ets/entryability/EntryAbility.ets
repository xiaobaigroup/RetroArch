import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Xb_GlobalContext, Xb_PreferenceUtil } from 'xb_components';
import { RetroSettings } from './RetroSetting';
import { fileIo, fileUri, picker } from '@kit.CoreFileKit';
import { emitter, zlib } from '@kit.BasicServicesKit';
import { retroArchVM } from '../RetroArchViewModel';

const DOMAIN = 0x0000;


export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    try {
      retroArchVM.init(this.context)
      Xb_GlobalContext.initContext(this.context)
      // 配置为深色模式
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      await Xb_PreferenceUtil.init(this.context, 'retro_arch_preference')
      // 加载配置
      RetroSettings.load()
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
    retroArchVM.stopApp();
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.getMainWindowSync().setPreferredOrientation(window.Orientation.AUTO_ROTATION_UNSPECIFIED)
    windowStage.getMainWindowSync().setWindowSystemBarEnable([])
    windowStage.loadContent('pages/Index', async (err) => {
      await retroArchVM.StartApp();
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
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
