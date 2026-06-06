
/**
 * 文件连接处理类
 * 负责处理外部文件管理器发起的文件打开请求
 */
import { Want } from '@kit.AbilityKit'
import { fileIo, fileUri } from '@kit.CoreFileKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { SUPPORTED_EXTENSIONS } from './FileExtensionName'
import retroApi from 'libretroarch.so';
import { retroArchVM } from '../RetroArchViewModel'
import { Xb_ToastUtil } from 'xb_components'

/**
 * 文件连接处理类
 * 负责处理外部文件管理器发起的文件打开请求
 */
@ObservedV2
class FileConnect {
  private readonly DOMAIN = 0x0001
  private readonly TAG = 'FileConnectApp'

  /**
   * 处理文件打开请求
   * @param want - 系统传递的Want对象
   */
  wantFile(want: Want): void {
    const startTime = Date.now()

    try {
      // 1. 提取URI
      const uri = this.extractUri(want)
      if (!uri) {
        hilog.warn(this.DOMAIN, this.TAG, 'URI无效，无法打开文件')
        return
      }

      // 2. 验证URI协议安全性
      if (!this.validateUriScheme(uri)) {
        this.logAndToast('不支持的文件协议', 'error')
        return
      }

      // 3. 验证文件存在性和可读性（使用URI，保留临时访问权限）
      if (!this.validateFileAccess(uri)) {
        this.logAndToast('文件不存在或无法访问', 'error')
        return
      }

      // 4. 从URI提取文件路径用于类型判断
      const realPath = this.getRealPath(uri)

      // 5. 验证文件类型
      if (!this.validateFileType(realPath)) {
        this.logAndToast('不支持此文件类型，请选择有效的游戏ROM文件', 'warn')
        return
      }

      // 6. 存入downloads文件夹，触发ROM加载
      this.triggerRomLoad(uri)

      // 7. 记录性能指标
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
    hilog.info(this.DOMAIN, this.TAG, '提取URI: %{public}s', uri)
    return uri
  }

  /**
   * 验证URI协议安全性
   */
  private validateUriScheme(uri: string): boolean {
    const validSchemes = ['file://', 'content://']
    return validSchemes.some(scheme => uri.startsWith(scheme))
  }

  /**
   * 获取真实文件路径
   * - file:// 协议：移除前缀得到文件系统路径
   * - content:// 协议：通过 fileUri 转换获取路径
   */
  private getRealPath(uri: string): string {
    if (uri.startsWith('file://')) {
      const path = uri.substring(7)
      hilog.info(this.DOMAIN, this.TAG, 'realPath: %{public}s', path)
      return path
    }
    // content:// 协议：通过 FileUri 转换
    try {
      const path = new fileUri.FileUri(uri).path
      hilog.info(this.DOMAIN, this.TAG, 'realPath from FileUri: %{public}s', path)
      return path
    } catch (err) {
      hilog.warn(this.DOMAIN, this.TAG, 'FileUri转换失败，使用原始URI')
      return uri
    }
  }

  /**
   * 验证文件类型
   */
  private validateFileType(filePath: string): boolean {
    const extension = this.getFileExtension(filePath).toLowerCase()
    return SUPPORTED_EXTENSIONS.includes(extension)
  }

  /**
   * 获取文件扩展名
   */
  private getFileExtension(filePath: string): string {
    const lastDot = filePath.lastIndexOf('.')
    if (lastDot === -1) {
      return ''
    }
    // 截取扩展名，去除可能的查询参数 (?xxx)
    let ext = filePath.substring(lastDot)
    const queryIndex = ext.indexOf('?')
    if (queryIndex !== -1) {
      ext = ext.substring(0, queryIndex)
    }
    return ext
  }

  /**
   * 验证文件访问权限
   * 使用 fileIo（@kit.CoreFileKit）操作URI，支持 file:// 和 content://
   */
  private validateFileAccess(uri: string): boolean {
    try {
      const stat = fileIo.statSync(uri)
      return stat.isFile() && stat.size > 0
    } catch (err) {
      hilog.error(this.DOMAIN, this.TAG, '文件访问验证失败: %{public}s', JSON.stringify(err))
      return false
    }
  }

  /**
   * 存入downloads文件夹，触发ROM加载
   * @param uri - 原始URI（用于实际文件操作，保留临时访问权限）
   */
  private async triggerRomLoad(uri: string): Promise<void> {
    try {
      let uriPath = new fileUri.FileUri(uri)
      let file = fileIo.statSync(uriPath.path)
      let target = retroArchVM.dataDir+ "/downloads/" + uriPath.name;
      if(file.isFile()){
        if(! await fileIo.access(target))
          await fileIo.copyFile(uriPath.path, target)
        retroApi.openFile(target);
      }
      hilog.info(this.DOMAIN, this.TAG, '存入download文件夹: %{public}s', target)
    } catch (error) {
      hilog.error(this.DOMAIN, this.TAG, '复制文件失败', error)
    }
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
    if (level === 'error') {
      hilog.error(this.DOMAIN, this.TAG, message)
    } else if (level === 'warn') {
      hilog.warn(this.DOMAIN, this.TAG, message)
    } else {
      hilog.info(this.DOMAIN, this.TAG, message)
    }

    try {
       Xb_ToastUtil.showToast({
         message: message,
         duration: 2000,
       })
    } catch (err) {
      hilog.warn(this.DOMAIN, this.TAG, 'ToastUtil未初始化，跳过用户提示')
    }
  }
}

export const FileConnectUtil: FileConnect = new FileConnect()

