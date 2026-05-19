

@ObservedV2
export class _RetroState {
  @Trace showWelcome: boolean = false
  @Trace showBlur: boolean = false
  /** @description 导航栏高度 */
  @Trace bottomRectHeight: number = 0
  /** @description 状态栏高度 */
  @Trace topRectHeight: number = 0
  /** @description 左侧避让宽度 */
  @Trace leftAvoidWidth: number = 0
  /** @description 右侧避让宽度 */
  @Trace rightAvoidWidth: number = 0

}

export const RetroState: _RetroState = new _RetroState()
