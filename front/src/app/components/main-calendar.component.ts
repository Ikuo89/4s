import { Component, ElementRef, OnInit } from '@angular/core';
import { CalendarService, CalendarMode } from '../services/calendar.service';
import { Calendar } from '../models/calendar'
import { Event } from '../models/event'

@Component({
  selector: 'main-calendar',
  template: `
    <div class="main-calendar-wrapper">
      <div class="btn-area">
        <div class="btn today left" (click)="setToday()">今日</div>
        <div class="btn left" (click)="onPrev()"><i class="fa fa-chevron-left" aria-hidden="true"></i></div>
        <div class="btn left" (click)="onNext()"><i class="fa fa-chevron-right" aria-hidden="true"></i></div>
        <div class="title left">
          <span *ngIf="mode == 0">{{year}}/{{month}}</span>
          <span *ngIf="mode == 1">{{weekFirstDate.getFullYear()}}/{{weekFirstDate.getMonth() + 1}}/{{weekFirstDate.getDate()}} 〜 {{weekLastDate.getFullYear()}}/{{weekLastDate.getMonth() + 1}}/{{weekLastDate.getDate()}}</span>
        </div>
        <div class="btn month-view right" (click)="setMonth()">月</div>
        <div class="btn week-view right" (click)="setWeek()">週</div>
      </div>
      <div class="main-wrapper">
        <div *ngIf="mode == 0">
          <table class="main-monthly-head">
            <tbody>
              <tr>
                <th title="日曜日">日</th>
                <th title="月曜日">月</th>
                <th title="火曜日">火</th>
                <th title="水曜日">水</th>
                <th title="木曜日">木</th>
                <th title="金曜日">金</th>
                <th title="土曜日">土</th>
              </tr>
            </tbody>
          </table>
          <table class="main-monthly" [style.height]="getTableHeight('.main-monthly') + 'px'">
            <tbody>
              <tr *ngFor="let weekData of monthData">
                <td *ngFor="let date of weekData"
                  [class.current]="date.getMonth() + 1 == month"
                  [class.today]="date.toString() == today.toString()">
                  {{date.getDate()}}
                  <ng-container *ngFor="let event of targetEventList">
                    <div *ngIf="event.isDate && event.start.getTime() >= date.getTime() && event.start.getTime() <= (date.getTime() + 24 * 60 * 60 * 1000)"
                      class="event"
                      [style.background-color]="event.backgroundColor" >{{event.summary}}</div>
                    <div *ngIf="!event.isDate && event.start.getTime() >= date.getTime() && event.start.getTime() <= (date.getTime() + 24 * 60 * 60 * 1000) && event.end.getTime() >= date.getTime() && event.end.getTime() <= (date.getTime() + 24 * 60 * 60 * 1000)"
                      class="event"
                      [style.color]="event.backgroundColor" >{{('0' + event.start.getHours()).slice(-2)}}:{{('0' + event.start.getMinutes()).slice(-2)}} {{event.summary}}</div>
                  </ng-container>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div *ngIf="mode == 1">
          <table class="main-weekly-head">
            <tbody>
              <tr>
                <td style="width: 60px;"></td>
                <th *ngFor="let date of weekData">
                  {{date.getMonth() + 1}}/{{date.getDate()}} ({{calendarService.toDayString(date)}})
                </th>
              </tr>
            </tbody>
          </table>
          <table class="main-weekly-head-no-time">
            <tbody>
              <tr>
                <td style="width: 59px;"></td>
                <td *ngFor="let date of weekData"
                  [class.today]="date.toString() == today.toString()"
                  [attr.data-date]="date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate()">
                  <ng-container *ngFor="let event of targetEventList">
                    <div *ngIf="event.isDate && event.start.getTime() >= date.getTime() && event.start.getTime() <= (date.getTime() + 24 * 60 * 60 * 1000)"
                      class="event"
                      [style.background-color]="event.backgroundColor" >{{event.summary}}</div>
                  </ng-container>
                </td>
              </tr>
            </tbody>
          </table>
          <table class="main-weekly-head">
            <tbody>
              <tr class="margin">
                <td style="width: 60px;"></td>
                <td colspan="7"></td>
              </tr>
            </tbody>
          </table>
          <div class="main-weekly-wrapper" [style.height]="getTableHeight('.main-weekly-wrapper') + 'px'">
            <table class="main-weekly">
              <tbody>
                <tr class="row-line" height="1">
                  <td style="width: 60px;"></td>
                  <td colspan="7">
                    <div class="hour-markers-wrapper">
                      <div class="hour-markers">
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                        <div class="hour"><div class="half"></div></div>
                      </div>
                    </div>
                  </td>
                </tr>
                <tr class="time">
                  <td class="time-marker">
                    <div class="hour">00:00</div>
                    <div class="hour">01:00</div>
                    <div class="hour">02:00</div>
                    <div class="hour">03:00</div>
                    <div class="hour">04:00</div>
                    <div class="hour">05:00</div>
                    <div class="hour">06:00</div>
                    <div class="hour">07:00</div>
                    <div class="hour">08:00</div>
                    <div class="hour">09:00</div>
                    <div class="hour">10:00</div>
                    <div class="hour">11:00</div>
                    <div class="hour">12:00</div>
                    <div class="hour">13:00</div>
                    <div class="hour">14:00</div>
                    <div class="hour">15:00</div>
                    <div class="hour">16:00</div>
                    <div class="hour">17:00</div>
                    <div class="hour">18:00</div>
                    <div class="hour">19:00</div>
                    <div class="hour">20:00</div>
                    <div class="hour">21:00</div>
                    <div class="hour">22:00</div>
                    <div class="hour">23:00</div>
                  </td>
                  <td *ngFor="let date of weekData"
                    [class.today]="date.toString() == today.toString()"
                    [attr.data-date]="date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate()">
                    <ng-container *ngFor="let event of targetEventList">
                      <div *ngIf="event.start.getTime() >= date.getTime() && event.end.getTime() <= (date.getTime() + 24 * 60 * 60 * 1000)"
                        class="event"
                        [style.background-color]="event.backgroundColor"
                        [style.top]="(event.start.getHours() + event.start.getMinutes() / 60) * 42 + 'px'"
                        [style.height]="(event.end.getHours() + event.end.getMinutes() / 60 - event.start.getHours() - event.start.getMinutes() / 60) * 42 + 'px'">{{('0' + event.start.getHours()).slice(-2)}}:{{('0' + event.start.getMinutes()).slice(-2)}} {{event.summary}}</div>
                    </ng-container>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .btn-area {
      margin-bottom: 5px;
      line-height: 30px;
      height: 30px;
    }
    .btn-area > .left {
      float: left;
      margin-right: 5px;
    }
    .btn-area > .right {
      float: right;
      margin-left: 5px;
    }
    table {
      width: 100%;
      height: 100%;
      table-layout: fixed;
    }
    table.main-monthly {
      border-right: 1px solid #DDD;
    }
    table.main-monthly-head tbody tr th, table.main-monthly tbody tr td {
      font-size: 14px;
      text-align: left;
      padding: 5px;
    }
    table.main-monthly-head tbody tr th {
      height: 14px;
    }
    table.main-monthly tbody tr td {
      // cursor: pointer;
      color: #777;
      border: 1px solid #DDD;
      border-right: none;
    }
    table.main-monthly tbody tr td.current {
      color: #000;
    }
    // table.main-monthly tbody tr td:hover {
    //   background-color: #DDD;
    // }
    table.main-monthly .event {
      overflow: hidden;
      white-space: nowrap;
      text-overflow: ellipsis;
    }
    table.main-weekly-head tbody th {
      font-size: 12px;
      font-weight: normal;
      text-align: center;
      height: 12px;
    }
    table.main-weekly-head-no-time {
      border-right: 1px solid #DDD;
    }
    table.main-weekly-head-no-time tbody tr td {
      height: 10px;
      border: 1px solid #DDD;
      border-right: none;
    }
    table.main-weekly-head-no-time tbody tr td > div {
      overflow: hidden;
      white-space: nowrap;
      text-overflow: ellipsis;
      width: 100%;
      font-size: 12px;
      height: 18px;
      line-height: 18px;
    }
    table.main-weekly-head tbody tr.margin td {
      height: 5px;
    }
    .main-weekly-wrapper {
      overflow-y: scroll;
    }
    .hour-markers-wrapper {
      position: relative;
    }
    .hour-markers {
      position: absolute;
      width: 100%;
      padding-top: 2px;
    }
    table.main-weekly {
      border-right: 1px solid #DDD;
    }
    table.main-weekly tbody tr.row-line td .hour{
      height: 41px;
      border-bottom: 1px solid #DDD;
    }
    table.main-weekly tbody tr.row-line td .hour:last-child {
      border: none;
    }
    table.main-weekly tbody tr.row-line td .hour .half {
      height: 21px;
      border-bottom: 0.5px solid #EEE;
    }
    table.main-weekly tbody tr.time td .hour {
      height: 41px;
      font-size: 12px;
      border-bottom: 1px solid #DDD;
      text-align: right;
    }
    table.main-weekly tbody tr.time td .hour:last-child {
      border-bottom: none;
    }
    table.main-weekly tbody tr.time td {
      position: relative;
      border: 1px solid #DDD;
      border-right: none;
      height: 1007px;
    }
    table.main-weekly tbody tr.time td .event {
      position: absolute;
      overflow: hidden;
      white-space: nowrap;
      text-overflow: ellipsis;
      width: 100%;
      font-size: 12px;
    }
  `],
  providers: []
})
export class MainCalendarComponent implements OnInit {
  mode: number;
  year: number;
  month: number;
  today: Date;
  monthData: any[];
  weekData: any[];
  weekFirstDate: Date;
  weekLastDate: Date;
  calendarList: Calendar[] = [];
  eventList: Event[] = [];
  targetEventList: Event[] = [];
  constructor(private calendarService: CalendarService, private el: ElementRef) { }

  getTableHeight(selector: string): number {
    var $mainCalendar = this.el.nativeElement.querySelector(selector)
    return window.innerHeight - $mainCalendar.offsetTop - 62; // 62 はheaderの値
  }

  setMonthArray(date: Date): void {
    this.year = date.getFullYear()
    this.month = date.getMonth() + 1
    this.monthData = this.calendarService.getMonthArray(date)
    this.targetEventList = []
    this.eventList.forEach(event => {
      if (event.start.getTime() >= this.monthData[0][0].getTime() && event.end.getTime() <= (this.monthData[5][6].getTime() + 24 * 60 * 60 * 1000)) {
        this.targetEventList.push(event)
      }
    })
  }

  setWeekArray(date: Date): void {
    this.year = date.getFullYear()
    this.month = date.getMonth() + 1
    this.weekData = this.calendarService.getWeekArray(date)
    this.weekFirstDate = this.weekData[0]
    this.weekLastDate = this.weekData[6]
  }

  setMonth(): void {
    this.calendarService.setMode(CalendarMode.monthly)
  }

  setWeek(): void {
    this.calendarService.setMode(CalendarMode.weekly)
  }

  setToday(): void {
    this.calendarService.setDate(this.today)
  }

  onNext(): void {
    this.calendarService.next()
  }

  onPrev(): void {
    this.calendarService.prev()
  }

  ngOnInit(): void {
    this.calendarService.on('mode:change').subscribe(mode => this.mode = mode)
    this.calendarService.on('date:set').subscribe(data => {
      this.mode = data.mode
      this.setWeekArray(data.date)
      this.setMonthArray(data.date)
    })
    this.calendarService.on('add:calendar').subscribe(calendar => this.calendarList.push(calendar))
    this.calendarService.on('add:event').subscribe(event => {
      this.eventList.push(event)
      this.eventList.sort((a, b) => a.start > b.start ? 1 : -1)

      if (event.start.getTime() >= this.monthData[0][0].getTime() && event.end.getTime() <= (this.monthData[5][6].getTime() + 24 * 60 * 60 * 1000)) {
        this.targetEventList.push(event)
      }
    })
    this.mode = 1
    this.today = CalendarService.today
    this.setWeekArray(CalendarService.today)
    this.setMonthArray(CalendarService.today)
  }
}
