import { HttpClient } from '../utils/http.client'
import { parseLoginLink, parseFullTable, parseBeginDate } from './fdzc.parser'
import { baseURL } from './fdzc.const'
import { ParsedCourse } from '../importers/importer.interface'

export class FdzcFetcher {
  private client: HttpClient

  constructor() {
    this.client = new HttpClient(baseURL)
  }

  async initLogin(): Promise<{
    loginURL: string
    captchaImage: string
    cookies: Record<string, string>
  }> {
    const res1 = await this.client.get('default.asp')
    console.log('[DEBUG] default.asp:', res1.status, res1.url)
    const loginURL = await parseLoginLink(await res1.text())
    console.log('[DEBUG] loginURL:', loginURL)

    const res2 = await this.client.get('ValidateCookie.asp')
    console.log('[DEBUG] ValidateCookie.asp:', res2.status, res2.url)
    const arrayBuffer = await res2.arrayBuffer()
    const uint8Array = new Uint8Array(arrayBuffer)
    const captchaImage = Buffer.from(uint8Array).toString('base64')
    console.log('[DEBUG] captchaImage length:', captchaImage.length)

    const cookies = this.client.getAllCookies()
    console.log('[DEBUG] cookies:', cookies)

    return { loginURL, captchaImage, cookies }
  }

  async completeLogin(
    loginURL: string,
    captcha: string,
    cookies: Record<string, string>,
    username: string,
    password: string
  ): Promise<void> {
    this.client.setAllCookies(cookies)
    console.log('[DEBUG] restored cookies:', this.client.getAllCookies())

    const res3 = await this.client.get(`ajax/chkCode.asp?code=${captcha}&id=${Math.random()}`)
    console.log('[DEBUG] chkCode.asp:', res3.status, res3.url)
    const chkResult = await res3.text()
    console.log('[DEBUG] chkResult:', chkResult)
    if (chkResult.trim() !== 'ok') {
      throw new Error('验证码错误，请重新输入')
    }

    const loginRes = await this.client.post(loginURL, {
      muser: username,
      passwd: password,
      code: captcha,
    })
    console.log('[DEBUG] login response:', loginRes.status, loginRes.url)
    this.client.setCookie('muser', username)
  }

  async fetchTimetable(year: number, semester: string): Promise<ParsedCourse[]> {
    const res = await this.client.post('kb/kb_xs.asp', {
      xn: year.toString(),
      xq: semester,
    })
    console.log('[DEBUG] fetchTimetable response:', res.status, res.url)

    const html = await res.text()
    console.log('[DEBUG] fetchTimetable html length:', html.length)
    console.log('[DEBUG] fetchTimetable full html:', html)

    if (html.includes('出错提示')) {
      throw new Error('用户名或密码错误')
    }

    const courses = await parseFullTable(html)
    console.log('[DEBUG] parsed courses count:', courses.length)
    return courses
  }

  async fetchBeginDate(year: number, semester: string): Promise<[number, number, number]> {
    const res = await this.client.get(`kb/zkb_xs.asp?week1=1&kkxq=${year}${semester}`)
    return parseBeginDate(await res.text())
  }
}