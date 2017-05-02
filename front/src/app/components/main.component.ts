import { Component, OnInit, AfterViewInit, ViewChild } from '@angular/core';

import { CalendarService } from '../services/calendar.service';
import { AddCalendarModalComponent } from '../components/add-calendar.modal.component';

@Component({
  template: `
    <app-header></app-header>
    <div class="content">
      <nav>
        <mini-calendar></mini-calendar>
        <div>
          <div class="btn" (click)="showAddCalendarModal()">追加</div>
        </div>
        <calendar-list></calendar-list>
      </nav>
      <div class="main">
        <main-calendar></main-calendar>
      </div>
    </div>
    <add-calendar-modal></add-calendar-modal>
  `,
  styles: [`
    .content {
      position: relative;
    }
    nav {
      position: absolute;
      top: 0;
      left: 0;
      width: 170px;
    }
    .main {
      width: auto;
      margin-left: 170px;
    }
  `],
  providers: []
})
export class MainComponent implements AfterViewInit {
  constructor(private calendarService: CalendarService) { }
  @ViewChild(AddCalendarModalComponent)
  addCalendarModal:AddCalendarModalComponent;

  showAddCalendarModal(): void {
    this.addCalendarModal.open();
  }

  ngAfterViewInit(): void {
    this.calendarService.fetch();
  }
}
