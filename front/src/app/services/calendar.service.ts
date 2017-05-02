import { Injectable } from '@angular/core';
import 'rxjs/add/operator/toPromise';
import { Observable } from 'rxjs/Observable';
import { Broadcaster } from './broadcaster';
import { ApiService } from './api.service';
import { Calendar } from '../models/calendar';
import { Event } from '../models/event';

export const CalendarMode = {
  monthly: 0,
  weekly: 1
}

@Injectable()
export class CalendarService {
  static mode: number = 1
  static current: Date = new Date()
  static today: Date = new Date()
  static calendars: Calendar[]
  static events: Event[]

  constructor(private broadcaster: Broadcaster, private apiService: ApiService) { }

  getMonthArray(date: Date): Array<any> {
    var resultMonthData = []
      , monthTmp = []
      , lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0)
      , day = new Date(date.getFullYear(), date.getMonth(), 1)

    lastDay.setDate(lastDay.getDate() + 14)
    day.setDate(day.getDate() - 7)

    while (day <= lastDay) {
      monthTmp.push(new Date(day.getFullYear(), day.getMonth(), day.getDate()));
      day.setDate(day.getDate() + 1);
    }

    for (var i = 0; i < monthTmp.length; i++) {
      if (monthTmp[i].getDay() == 0 && resultMonthData.length < 6) {
        resultMonthData.push([])
        resultMonthData[resultMonthData.length - 1].push(monthTmp[i])
      } else if (resultMonthData[resultMonthData.length - 1] && resultMonthData[resultMonthData.length - 1].length < 7) {
        resultMonthData[resultMonthData.length - 1].push(monthTmp[i])
      }
    }

    return resultMonthData
  }

  getWeekArray(date: Date): Array<Date> {
    var resultWeekData = []
      , weekTmp = []
      , lastDay = new Date(date.getFullYear(), date.getMonth(), date.getDate() + 6)
      , day = new Date(date.getFullYear(), date.getMonth(), date.getDate() - 6)

    while (day <= lastDay) {
      weekTmp.push(new Date(day.getFullYear(), day.getMonth(), day.getDate()))
      day.setDate(day.getDate() + 1)
    }

    for (var i = 0; i < weekTmp.length; i++) {
      if (weekTmp[i].getDay() == 0 && resultWeekData.length == 0) {
        resultWeekData.push(weekTmp[i])
      } else if (resultWeekData.length > 0 && resultWeekData.length < 7) {
        resultWeekData.push(weekTmp[i])
      }
    }

    return resultWeekData
  }

  toDayString(date: Date): string {
    var dayList = '日月火水木金土'
    return dayList.charAt(date.getDay())
  }

  on(key: string): Observable<any> {
    return this.broadcaster.on<any>(key)
  }

  setMode(mode: number): void {
    CalendarService.mode = mode
    this.broadcaster.broadcast('mode:change', mode)
  }

  setDate(date: Date): void {
    CalendarService.current = date
    this.broadcaster.broadcast('date:set', {date: CalendarService.current, mode: CalendarService.mode})
  }

  next(): void {
    if (CalendarService.mode == CalendarMode.monthly) {
      CalendarService.current = new Date(CalendarService.current.getFullYear(), CalendarService.current.getMonth() + 1, 1)
    } else {
      CalendarService.current = new Date(CalendarService.current.getFullYear(), CalendarService.current.getMonth(), CalendarService.current.getDate() + 7)
    }
    this.broadcaster.broadcast('date:set', {date: CalendarService.current, mode: CalendarService.mode})
  }

  prev(): void {
    if (CalendarService.mode == CalendarMode.monthly) {
      CalendarService.current = new Date(CalendarService.current.getFullYear(), CalendarService.current.getMonth() - 1, 1)
    } else {
      CalendarService.current = new Date(CalendarService.current.getFullYear(), CalendarService.current.getMonth(), CalendarService.current.getDate() - 7)
    }
    this.broadcaster.broadcast('date:set', {date: CalendarService.current, mode: CalendarService.mode})
  }

  fetch(): Promise<void> {
    return this.apiService.call('/calendars')
      .then(calendarsResponse => {
        CalendarService.calendars = calendarsResponse as Calendar[]
        CalendarService.calendars.forEach(calendar => {
          this.broadcaster.broadcast('add:calendar', calendar)
          this.apiService.call(`/calendars/${calendar.id}/events`).then(eventsResponse => {
            CalendarService.events = eventsResponse as Event[]
            CalendarService.events.forEach(event => {
              event.start = new Date(event.start.toString());
              event.end = new Date(event.end.toString());
              event.backgroundColor = calendar.backgroundColor;
              event.foregroundColor = calendar.foregroundColor;
            })
            CalendarService.events.forEach(event => this.broadcaster.broadcast('add:event', event))
          })
        })
      });
  }
}
