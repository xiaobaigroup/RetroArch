import { fileIo, fileUri, picker } from '@kit.CoreFileKit';
import retroApi, { StartParams } from 'libretroarch.so';
import zlib from '@ohos.zlib';
import { common } from '@kit.AbilityKit';
import { displaySync } from '@kit.ArkGraphics2D';
import { display } from '@kit.ArkUI';
import window from '@ohos.window';

async function initDownloadDir(context: Context) : Promise<string | undefined>{
  try {
    const documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
    const documentViewPicker = new picker.DocumentViewPicker(context);
    const path = await documentViewPicker.save(documentSaveOptions)
    const dir = new fileUri.FileUri(path[0]).path;
    return dir;
  } catch (e) {

  }
  return undefined;
}

enum NativeEventId{
  EVENT_NATIVE_OPEN_KEYBOARD,
  EVENT_NATIVE_APP_SHUTDOWN,
  EVENT_NATIVE_VIDEO_NOTCH_WRITE_OVER_ENABLE,
  EVENT_NATIVE_SET_SCREEN_ORIENTATION,
  EVENT_NATIVE_SHOW_FILE_PICKER
}

@ObservedV2
export class RetroArchViewModel{
  context?: common.UIAbilityContext

  @Trace loading: boolean = true;
  @Trace openKeyboard: boolean = false;
  @Trace fullScreen: boolean = false;
  @Trace currentRotation: number = 0
  dataDir: string = "";
  constructor() {
  }
  stopApp(){
    retroApi.stopApp()
  }
  init(context: common.UIAbilityContext){
    this.context = context;
    this.currentRotation = display.getDefaultDisplaySync().rotation
    display.on("change", ()=>{
      this.currentRotation = display.getDefaultDisplaySync().rotation
    })
    retroApi.onNativeEvent((eventId: number, value: number)=>{
      if(eventId == NativeEventId.EVENT_NATIVE_APP_SHUTDOWN){
        this.context?.terminateSelf();
      }
      if(eventId == NativeEventId.EVENT_NATIVE_OPEN_KEYBOARD){
        this.openKeyboard = true;
      }
      if(eventId == NativeEventId.EVENT_NATIVE_VIDEO_NOTCH_WRITE_OVER_ENABLE){
        this.fullScreen = value == 1;
      }
      if(eventId == NativeEventId.EVENT_NATIVE_VIDEO_NOTCH_WRITE_OVER_ENABLE){
        this.fullScreen = value == 1;
      }
      if(eventId == NativeEventId.EVENT_NATIVE_SHOW_FILE_PICKER){
        const documentSaveOptions = new picker.DocumentSelectOptions();
        documentSaveOptions.selectMode = picker.DocumentSelectMode.FILE;
        const documentViewPicker = new picker.DocumentViewPicker(context);
        documentViewPicker.select(documentSaveOptions).then(async  d=>{
            if(d.length > 0){
              let uri = new fileUri.FileUri(d[0])
              let file = await fileIo.statSync(uri.path)
              let target = this.dataDir+ "/downloads/" + uri.name;
              if(await file.isFile()){
                try {
                  if(! await fileIo.access(target))
                    await fileIo.copyFile(uri.path, target)
                  retroApi.openFile(target);
                }catch (e) {
                  console.error("复制文件失败:", e)
                }
              }
              if(await file.isDirectory()){
                retroApi.openFile(uri.path);
              }
            }
        })
      }
      if(eventId == NativeEventId.EVENT_NATIVE_SET_SCREEN_ORIENTATION){
        if(value == 0){
          this.context?.windowStage.getMainWindowSync().setPreferredOrientation(window.Orientation.AUTO_ROTATION_UNSPECIFIED)
        }
        if(value == 1){
          this.context?.windowStage.getMainWindowSync().setPreferredOrientation(window.Orientation.LANDSCAPE)
        }
        if(value == 2){
          this.context?.windowStage.getMainWindowSync().setPreferredOrientation(window.Orientation.LANDSCAPE_INVERTED)
        }
        if(value == 3){
          this.context?.windowStage.getMainWindowSync().setPreferredOrientation(window.Orientation.PORTRAIT_INVERTED)
        }
      }
    })
  }
  async StartApp(){
    this.dataDir = (await initDownloadDir(this.context!) ?? this.context!.filesDir) + "/GameBox"
    let dataDir = this.dataDir;
    let configPath = dataDir + "/gamebox.cfg";
    try {
      if (!await fileIo.access(dataDir))
        await fileIo.mkdir(dataDir)
      if (!await fileIo.access(configPath, fileIo.AccessModeType.EXIST)){
        let file = await fileIo.open(configPath, fileIo.OpenMode.CREATE);
        await fileIo.close(file.fd);
      }
      this.loading = true
      await this.initAssets(dataDir)
      this.loading = false;
    }catch (e) {
      console.error("testTag", e)
    }
    let coresDir =  this.context!.bundleCodeDir + "/libs/arm64"
    let dpi = display.getDefaultDisplaySync().densityDPI
    retroApi.startApp({
      CONFIGFILE: configPath,
      IME:"",
      DATADIR: dataDir,
      LIBRETRO: coresDir,
      ROM: "",
      Dpi: dpi,
    } as StartParams);

  }
  async initAssets(dataDir: string){
    await this.installAssets(dataDir, "assets");
    await this.installAssets(dataDir, "overlays");
    await this.installAssets(dataDir, "info");
    await this.installAssets(dataDir, "autoconfig");
    try {
      await this.overrideIcons(dataDir)
    }catch (e) {
      console.error("替换icon失败", e)
    }
  }
  async overrideIcons(dataDir: string){
    await this.overrideIcon(dataDir, "/glui/cores.png");
    await this.overrideIcon(dataDir, "/ozone/retroarch.png");
    await this.overrideIcon(dataDir, "/ozone/png/icons/menu_quickmenu.png");
    await this.overrideIcon(dataDir, "/ozone/png/sidebar/retroarch.png");
    await this.overrideIcon(dataDir, "/xmb/automatic/png/retroarch.png");
    await this.overrideIcon(dataDir, "/xmb/automatic/png/menu_quickmenu.png");
    await this.overrideIcon(dataDir, "/xmb/daite/png/retroarch.png");
    await this.overrideIcon(dataDir, "/xmb/daite/png/menu_quickmenu.png");
    await this.overrideIcon(dataDir, "/xmb/dot-art/png/retroarch.png");
    await this.overrideIcon(dataDir, "/xmb/dot-art/png/menu_quickmenu.png");
    await this.overrideIcon(dataDir, "/xmb/flatui/png/retroarch.png");
    await this.overrideIcon(dataDir, "/xmb/flatui/png/menu_quickmenu.png");
    await this.overrideIcon(dataDir, "/xmb/flatux/png/retroarch.png");
    await this.overrideIcon(dataDir, "/xmb/flatux/png/menu_quickmenu.png");
    await this.overrideIcon(dataDir, "/xmb/monochrome/png/retroarch.png");
    await this.overrideIcon(dataDir, "/xmb/monochrome/png/menu_quickmenu.png");
    await this.overrideIcon(dataDir, "/xmb/pixel/png/retroarch.png");
    await this.overrideIcon(dataDir, "/xmb/pixel/png/menu_quickmenu.png");
    await this.overrideIcon(dataDir, "/xmb/retrosystem/png/retroarch.png");
    await this.overrideIcon(dataDir, "/xmb/retrosystem/png/menu_quickmenu.png");
    await this.overrideIcon(dataDir, "/xmb/systematic/png/retroarch.png");
    await this.overrideIcon(dataDir, "/xmb/systematic/png/menu_quickmenu.png");
  }
  async overrideIcon(dataDir: string, name: string){
    let assetsDir = dataDir +"/assets";
    let iconPath = assetsDir + name;
    if(!await fileIo.access(assetsDir)){
      return ;
    }
    let fileData = await this.context?.resourceManager.getRawFileContent("retroarch.png");
    let targetFile = fileIo.openSync(iconPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.TRUNC);
    fileIo.writeSync(targetFile.fd, fileData?.buffer as ArrayBuffer);
    // await fileIo.copyFile(this.context!.resourceDir +"/retroarch.png", iconPath)
  }
  async installAssets(dataDir: string, name: string){
    let assetsDir = dataDir +"/" + name;
    if(!await fileIo.access(assetsDir)){
      await fileIo.mkdir(assetsDir)
    }
    let assetsCount = (await fileIo.listFile(assetsDir)).length;
    if (assetsCount == 0) {
      await zlib.decompressFile(this.context!.resourceDir + `/${name}.zip`, assetsDir);
    }
  }
}
export const retroArchVM =  new RetroArchViewModel()
