export const baseURL = 'https://jwc.fdzcxy.edu.cn/'

// 自动验证码识别字模表。
// 当前 Android/Web 前端使用“获取验证码图片 + 用户手动输入验证码”的流程，
// 因此后端启动不能依赖本表一定存在。若后续要恢复无感自动识别，
// 请在这里填入每个字符 90 个像素点的字模数据。
export const charDict: Record<string, number[]> = {}
