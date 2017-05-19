import { Component, OnInit } from '@angular/core';
import { CalendarService, CalendarMode } from '../services/calendar.service';
import { Calendar } from '../models/calendar'

@Component({
  selector: 'calendar-list',
  template: `
    <div>
      <ul class="calendar-list">
        <li *ngFor="let calendar of calendarList">
          <span class="calendar-color" [style.background-color]="calendar.backgroundColor"></span>
          {{calendar.summary}}
        </li>
      </ul>
    </div>
  `,
  styles: [`
    ul.calendar-list {
      font-size: 14px;
      padding: 10px;
    }
    ul.calendar-list li {
      width: 150px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      -webkit-text-overflow: ellipsis;
      -o-text-overflow: ellipsis;
      line-height: 18px;
    }
    ul.calendar-list li span.calendar-color {
      display: inline-block;
      height: 10px;
      width: 10px;
      border: solid 0.5px #DDD;
    }
  `],
  providers: []
})
export class CalendarListComponent implements OnInit{
  constructor(private calendarService: CalendarService) { }
  calendarList: Calendar[] = [];

  ngOnInit(): void {
    this.calendarService.on('add:calendar').subscribe(calendar => this.calendarList.push(calendar))
    this.calendarService.on('reload:calendar').subscribe(() => {
      this.calendarList = []
    })
  }
}
