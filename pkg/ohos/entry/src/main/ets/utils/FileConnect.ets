import { common, Want, wantConstant } from '@kit.AbilityKit'
import { fileIo, fileUri } from '@kit.CoreFileKit'
import { BusinessError, emitter } from '@kit.BasicServicesKit'
import fs from '@ohos.file.fs'
import { hilog } from '@kit.PerformanceAnalysisKit'

/**
 * 文件连接处理类
 * 负责处理外部文件管理器发起的文件打开请求
 */
@ObservedV2
class FileConnect {
  private readonly DOMAIN = 0x0000
  private readonly TAG = 'FileConnectApp'

  // 支持的ROM文件扩展名列表
  private readonly SUPPORTED_EXTENSIONS = [
    '.zip', '.7z',           // 压缩格式
    '.nes', '.sfc', '.smc',  // Nintendo
    '.gb', '.gbc', '.gba',   // Nintendo掌机
    '.n64', '.z64', '.v64',  // N64
    '.iso', '.cso', '.pbp',  // Sony
    '.bin', '.img',          // 通用镜像
    '.md', '.smd', '.gen',   // Sega
    '.gg', '.sms',           // Sega掌机
    '.chd', '.cue', '.m3u', '.d64'   // 其他格式
  ]

  /**
   * 处理文件打开请求
   * @param want - 系统传递的Want对象
   * @param filePath - 文件路径（可选）
   */
  wantFile(want: Want, filePath: string): void {
    const startTime = Date.now()

    try {
      // 1. 提取URI
      const uri = this.extractUri(want)
      if (!uri) {
        this.logAndToast('URI无效，无法打开文件', 'warn')
        return
      }

      // 2. 验证URI协议安全性
      if (!this.validateUriScheme(uri)) {
        this.logAndToast('不支持的文件协议', 'error')
        return
      }

      // 3. 获取文件路径
      const realPath = this.getRealPath(uri)

      // 4. 验证文件类型
      if (!this.validateFileType(realPath)) {
        this.logAndToast('不支持此文件类型，请选择有效的游戏ROM文件', 'warn')
        return
      }

      // 5. 验证文件存在性和可读性
      if (!this.validateFileAccess(realPath)) {
        this.logAndToast('文件不存在或无法访问', 'error')
        return
      }

      // 6. 打开文件（获取文件句柄）
      const file = fs.openSync(uri, fs.OpenMode.READ_ONLY)
      hilog.info(this.DOMAIN, this.TAG, '文件打开成功: %{public}s', realPath)

      // 7. 触发ROM加载（TODO: 集成到RetroArch核心）
      this.triggerRomLoad(realPath)

      // 8. 记录性能指标
      const elapsed = Date.now() - startTime
      hilog.info(this.DOMAIN, this.TAG, '文件处理完成，耗时: %{public}d ms', elapsed)

    } catch (err) {
      const error: BusinessError = err as BusinessError
      hilog.error(this.DOMAIN, this.TAG, '文件打开失败: %{public}s', error.message)
      this.handleFileError(error)
    }
  }

  /**
   * 提取URI
   */
  private extractUri(want: Want): string | null {
    const uri = want.uri

    if (!uri || uri.trim() === '') {
      return null
    }

    console.info('uri:',`${uri}`)
    return uri
  }

  /**
   * 验证URI协议安全性
   */
  private validateUriScheme(uri: string): boolean {
    // 仅允许file://和content://协议
    const validSchemes = ['file://', 'content://']
    return validSchemes.some(scheme => uri.startsWith(scheme))
  }

  /**
   * 获取真实文件路径
   */
  private getRealPath(uri: string): string {
    // 移除file://前缀
    if (uri.startsWith('file://')) {
      return uri.substring(7)
    }
    return uri
  }

  /**
   * 验证文件类型
   */
  private validateFileType(filePath: string): boolean {
    const extension = this.getFileExtension(filePath).toLowerCase()
    return this.SUPPORTED_EXTENSIONS.includes(extension)
  }

  /**
   * 获取文件扩展名
   */
  private getFileExtension(filePath: string): string {
    const lastDot = filePath.lastIndexOf('.')
    if (lastDot === -1) {
      return ''
    }
    return filePath.substring(lastDot)
  }

  /**
   * 验证文件访问权限
   */
  private validateFileAccess(filePath: string): boolean {
    try {
      const stat = fs.statSync(filePath)
      return stat.isFile() && stat.size > 0
    } catch (err) {
      return false
    }
  }

  /**
   * 触发ROM加载
   */
  private triggerRomLoad(filePath: string): void {
    // TODO: 集成到RetroArch模拟器核心
    // 通过事件总线或全局状态通知游戏加载模块
    hilog.info(this.DOMAIN, this.TAG, '触发ROM加载: %{public}s', filePath)

    // 示例：通过emitter发送事件
    // emitter.emit({ eventId: 1001 }, { data: filePath })
  }

  /**
   * 处理文件错误
   */
  private handleFileError(error: BusinessError): void {
    const errorMessages: Record<number, string> = {
      13900001: '文件不存在',
      13900002: '文件权限不足',
      13900003: '文件已被占用',
      13900004: '文件路径无效'
    }

    const message = errorMessages[error.code] || `文件操作失败: ${error.message}`
    this.logAndToast(message, 'error')
  }

  /**
   * 日志记录和用户提示
   */
  private logAndToast(message: string, level: 'info' | 'warn' | 'error'): void {
    // 记录日志
    if (level === 'error') {
      hilog.error(this.DOMAIN, this.TAG, message)
    } else if (level === 'warn') {
      hilog.warn(this.DOMAIN, this.TAG, message)
    } else {
      hilog.info(this.DOMAIN, this.TAG, message)
    }

    // 显示用户提示（需要ToastUtil已初始化）
    try {
      // Xb_ToastUtil.showToast(message)
    } catch (err) {
      hilog.warn(this.DOMAIN, this.TAG, 'ToastUtil未初始化，跳过用户提示')
    }
  }
}

export const fileConnect: FileConnect = new FileConnect()
