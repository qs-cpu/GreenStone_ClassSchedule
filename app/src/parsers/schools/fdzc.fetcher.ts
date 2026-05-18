import { HttpClient } from '../utils/http.client'
import { recognizeCaptcha } from '../utils/captcha.recognizer'
import { parseLoginLink, parseFullTable, parseBeginDate } from './fdzc.parser'
import { baseURL } from './fdzc.const'
import { ParsedCourse } from '../importers/importer.interface'

export class FdzcFetcher {
  private client: HttpClient

  constructor() {
    this.client = new HttpClient(baseURL)
  }

  private loginURL = ''

  async fetchCaptcha(): Promise<Uint8Array> {
    const res1 = await this.client.get('default.asp')
    console.log('[DEBUG] default.asp:', res1.status, res1.url)
    this.loginURL = await parseLoginLink(await res1.text())
    console.log('[DEBUG] loginURL:', this.loginURL)

    if (!this.loginURL) {
      throw new Error('无法解析教务系统登录地址')
    }

    const res2 = await this.client.get('ValidateCookie.asp')
    console.log('[DEBUG] ValidateCookie.asp:', res2.status, res2.url)
    return new Uint8Array(await res2.arrayBuffer())
  }

  async loginWithCaptcha(username: string, password: string, captcha: string): Promise<void> {
    if (!this.loginURL) {
      throw new Error('验证码会话已失效，请刷新验证码后重试')
    }

    const res3 = await this.client.get(`ajax/chkCode.asp?code=${encodeURIComponent(captcha)}&id=${Math.random()}`)
    console.log('[DEBUG] chkCode.asp:', res3.status, res3.url)
    const chkResult = await res3.text()
    console.log('[DEBUG] chkResult:', chkResult)
    if (chkResult.trim() !== 'ok') {
      throw new Error('验证码错误，请刷新后重试')
    }

    const loginRes = await this.client.post(this.loginURL, {
      muser: username,
      passwd: password,
      code: captcha,
    })
    console.log('[DEBUG] login response:', loginRes.status, loginRes.url)
    const loginHtml = await loginRes.text()
    if (loginRes.url.includes('loginchk.asp') || loginHtml.includes('出错提示')) {
      throw new Error('教务系统登录失败，请检查账号、密码和验证码')
    }
    this.client.setCookie('muser', username)
  }

  async login(username: string, password: string): Promise<void> {
    const captchaImage = await this.fetchCaptcha()
    const captcha = await recognizeCaptcha(captchaImage)
    console.log('[DEBUG] captcha:', captcha)
    await this.loginWithCaptcha(username, password, captcha)
  }

  async fetchTimetable(year: number, semester: string): Promise<ParsedCourse[]> {
    const schoolSemester = normalizeSchoolSemester(semester)
    const res = await this.client.post('kb/kb_xs.asp', {
      xn: year.toString(),
      xq: schoolSemester,
    })
    console.log('[DEBUG] fetchTimetable response:', res.status, res.url)

    const html = await res.text()
    console.log('[DEBUG] fetchTimetable html length:', html.length)
    console.log('[DEBUG] fetchTimetable html preview:', html.slice(0, 300))

    if (res.url.includes('error.asp') || html.includes('出错提示')) {
      throw new Error('教务系统返回权限错误或登录已失效')
    }

    if (html.includes('暂无课程记录')) {
      throw new Error(`${year}年${schoolSemester}暂无课程记录，请确认学年和上下学期`)
    }

    const courses = await parseFullTable(html)
    console.log('[DEBUG] parsed courses count:', courses.length)
    return courses
  }

  async fetchBeginDate(year: number, semester: string): Promise<[number, number, number]> {
    const schoolSemester = normalizeSchoolSemester(semester)
    const res = await this.client.get(`kb/zkb_xs.asp?week1=1&kkxq=${year}${schoolSemester}`)
    return parseBeginDate(await res.text())
  }
}

function normalizeSchoolSemester(semester: string): string {
  if (semester === '1' || semester === '上') return '上'
  if (semester === '2' || semester === '下') return '下'
  return semester
}
