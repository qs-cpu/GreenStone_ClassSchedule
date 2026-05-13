import { FdzcFetcher } from './fdzc.fetcher'
import { ParsedCourse } from '../importers/importer.interface'

export interface SchoolFetcher {
  id: string
  name: string
  login(username: string, password: string): Promise<void>
  fetchTimetable(year: number, semester: string): Promise<ParsedCourse[]>
  fetchBeginDate(year: number, semester: string): Promise<[number, number, number]>
}

export const schools: Record<string, SchoolFetcher> = {
  fdzc: Object.assign(new FdzcFetcher(), {
    id: 'fdzc',
    name: '福州大学至诚学院',
  }),
}