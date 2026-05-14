import { Xb_PreferenceUtil } from "xb_components";

const KEY_APP_SETTINGS: string = 'retro_arch_settings'

@ObservedV2
export class _RetroSettings {

  @Trace first_start: boolean = true

  constructor() {}

  /**
   * 加载逻辑：绝对类型安全
   * 使用 ?? 运算符：如果 JSON 里没有这个字段（老版本），就保留类定义里的默认值
   */
  public async load(): Promise<void> {
    try {
      const jsonStr: string = await Xb_PreferenceUtil.get<string>(KEY_APP_SETTINGS, "");
      if (!jsonStr) return;

      const json: Record<string, Object> = JSON.parse(jsonStr);

      // 基础类型直接赋值
      this.first_start = (json["first_start"] as boolean) ?? this.first_start;

      console.info("[RetroSettings] 配置加载成功");
    } catch (e) {
      console.error("[RetroSettings] JSON 解析失败，使用默认配置", e);
    }
  }

  /**
   * 保存
   * 避免序列化出类内部不可控的元数据
   */
  public async save(): Promise<void> {
    try {
      const data: Record<string, Object> = {
        "first_start": this.first_start,

      };
      const jsonStr: string = JSON.stringify(data);
      await Xb_PreferenceUtil.put(KEY_APP_SETTINGS, jsonStr);
    } catch (error) {
      console.error("[RetroSettings] 保存失败:", error);
    }
  }

  /**
   * 清空配置：恢复默认值并删除磁盘缓存
   */
  public async clear(): Promise<void> {
    try {
      // 手动将内存中的每一项恢复为类定义的默认值
      // （修改 @Trace 变量会自动触发相关 UI 组件刷新）
      this.first_start = true

      // 删除首选项中持久化的 JSON 字符串
      await Xb_PreferenceUtil.delete(KEY_APP_SETTINGS);

      console.info("[RetroSettings] 配置已清空并恢复默认");
    } catch (error) {
      console.error("[RetroSettings] 清空失败:", error);
    }
  }

}

export const RetroSettings: _RetroSettings = new _RetroSettings()
