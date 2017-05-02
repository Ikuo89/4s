import { Component, OnInit } from '@angular/core';

import { CalendarService } from '../services/calendar.service';

@Component({
  selector: 'mini-calendar',
  template: `
    <div class="mini-calendar-wrapper">
      <table class="mini-calendar-header">
        <tbody>
          <tr>
            <td class="title" colspan="5">
              <span>{{year}}年 {{month}}月</span>
            </td>
            <td class="operator" colspan="2">
              <span (click)="onPrev()"><i class="fa fa-chevron-left" aria-hidden="true"></i></span>
              <span (click)="onNext()"><i class="fa fa-chevron-right" aria-hidden="true"></i></span>
            </td>
          </tr>
        </tbody>
      </table>
      <table class="mini-calendar">
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
          <tr *ngFor="let weekData of monthData"
            [class.selected]="mode == 0 ? (current.getMonth() + 1 == month) : (current >= weekData[0] && current <= weekData[6])">
            <td *ngFor="let date of weekData"
              [class.current]="date.getMonth() + 1 == month"
              [class.today]="date.toString() == today.toString()"
              (click)="setDate(date)">
              {{date.getDate()}}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  `,
  styles: [`
    * {
      font-size: 15px;
    }
    .mini-calendar-wrapper {
      display: inline-block;
      width: 170px;
    }
    table.mini-calendar-header {
      width: 100%;
      margin-bottom: 5px;
    }
    .title {
      padding-left: 5px;
    }
    .operator {
      text-align: right;
      padding-right: 5px;
    }
    .operator > span {
      display: inline-block;
      cursor: pointer;
      padding: 4px;
      font-size: 12px;
      cursor: pointer;
    }
    .operator > span:hover {
      background-color: #DDD;
    }
    table.mini-calendar tbody tr th, table.mini-calendar tbody tr td {
      text-align: center;
      padding: 4px;
      font-size: 12px;
    }
    table.mini-calendar tbody tr td {
      cursor: pointer;
      color: #777;
    }
    table.mini-calendar tbody tr td.current {
      color: #000;
    }
    table.mini-calendar tbody tr td:hover, table.mini-calendar tbody tr.selected td {
      background-color: #DDD;
    }
  `],
  providers: []
})
export class MiniCalendarComponent implements OnInit{
  year: number;
  month: number;
  today: Date;
  current: Date;
  mode: number;
  monthData: any[];
  constructor(private calendarService: CalendarService) { }

  setMonthArray(date: Date): void {
    this.year = date.getFullYear()
    this.month = date.getMonth() + 1
    this.monthData = this.calendarService.getMonthArray(date)
  }

  onNext(): void {
    this.setMonthArray(new Date(this.year, this.month - 1 + 1, 1))
  }

  onPrev(): void {
    this.setMonthArray(new Date(this.year, this.month - 1 - 1, 1))
  }

  setDate(date: Date): void {
    this.calendarService.setDate(date)
  }

  ngOnInit(): void {
    this.today = CalendarService.today
    this.current = CalendarService.current
    this.calendarService.on('mode:change').subscribe(mode => this.mode = mode)
    this.calendarService.on('date:set').subscribe(data => {
      this.current = data.date
      this.mode = data.mode
      this.setMonthArray(data.date)
    })
    this.setMonthArray(this.today)
  }
}
