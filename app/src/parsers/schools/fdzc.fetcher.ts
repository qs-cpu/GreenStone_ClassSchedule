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

  async login(username: string, password: string): Promise<void> {
    const res1 = await this.client.get('default.asp')
    console.log('[DEBUG] default.asp:', res1.status, res1.url)
    const loginURL = await parseLoginLink(await res1.text())
    console.log('[DEBUG] loginURL:', loginURL)

    const res2 = await this.client.get('ValidateCookie.asp')
    console.log('[DEBUG] ValidateCookie.asp:', res2.status, res2.url)
    const arrayBuffer = await res2.arrayBuffer()
    const captcha = await recognizeCaptcha(new Uint8Array(arrayBuffer))
    console.log('[DEBUG] captcha:', captcha)

    const res3 = await this.client.get(`ajax/chkCode.asp?code=${captcha}&id=${Math.random()}`)
    console.log('[DEBUG] chkCode.asp:', res3.status, res3.url)
    const chkResult = await res3.text()
    console.log('[DEBUG] chkResult:', chkResult)
    if (chkResult.trim() !== 'ok') {
      throw new Error('验证码识别失败，请重试')
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

    const html = await res.text()
    if (html.includes('出错提示')) {
      throw new Error('用户名或密码错误')
    }

    return parseFullTable(html)
  }

  async fetchBeginDate(year: number, semester: string): Promise<[number, number, number]> {
    const res = await this.client.get(`kb/zkb_xs.asp?week1=1&kkxq=${year}${semester}`)
    return parseBeginDate(await res.text())
  }
}