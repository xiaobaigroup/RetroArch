

@ObservedV2
export class _RetroState {
  @Trace showWelcome: boolean = false
  @Trace showBlur: boolean = false
}

export const RetroState: _RetroState = new _RetroState()
