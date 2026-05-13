import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import retroApi, { StartParams } from 'libretroarch.so';


import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { fileIo } from '@kit.CoreFileKit';
import { Xb_GlobalContext } from 'xb_components';
import zlib from '@ohos.zlib';

const DOMAIN = 0x0000;


export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      Xb_GlobalContext.initContext(this.context)
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.getMainWindowSync().setPreferredOrientation(window.Orientation.AUTO_ROTATION)
    windowStage.getMainWindowSync().setWindowSystemBarEnable([])

    windowStage.loadContent('pages/Index', async (err) => {

      await this.StartApp();
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }
  async StartApp(){
    await Xb_GlobalContext.initDownloadDir()
    let dataDir =  Xb_GlobalContext.downloadDir + "/RetroArch";
    let configPath = dataDir + "/retroarch.cfg";
    try {
      if(!await fileIo.access(dataDir)){
        await fileIo.mkdir(dataDir)
      }
      if(!await fileIo.access(configPath, fileIo.AccessModeType.EXIST)){
        let file = await fileIo.open(configPath, fileIo.OpenMode.CREATE);
        await fileIo.close(file.fd);
      }
      await this.initAssets();
    }catch (e) {
      console.error("testTag", e)
    }
    retroApi.startApp({
      CONFIGFILE: configPath,
      IME:"",
      DATADIR: dataDir,
      LIBRETRO: dataDir + "/cores",
      ROM: "",
    } as StartParams);

  }
  async initAssets(){
    let dataDir =  Xb_GlobalContext.downloadDir + "/RetroArch";
    let assetsDir = dataDir +"/assets";
    if(!await fileIo.access(assetsDir)){
      await fileIo.mkdir(assetsDir)
    }
    let assetsCount = (await fileIo.listFile(assetsDir)).length;
    if(assetsCount == 0){
      await zlib.decompressFile(this.context.resourceDir + "/assets.zip", assetsDir);
    }
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
