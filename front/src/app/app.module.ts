import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { CookieService } from 'angular2-cookie/services/cookies.service';

import { AppComponent } from './components/app.component';
import { FooterComponent } from './components/footer.component';
import { HeaderComponent } from './components/header.component';
import { LoginComponent } from './components/login.component';
import { MainComponent } from './components/main.component';
import { MiniCalendarComponent } from './components/mini-calendar.component';
import { MainCalendarComponent } from './components/main-calendar.component';
import { CalendarListComponent } from './components/calendar-list.component';
import { AddCalendarModalComponent } from './components/add-calendar.modal.component';
import { LoadingComponent } from './components/loading.component';
import { ApiService } from './services/api.service';
import { LoginService } from './services/login.service';
import { UserService } from './services/user.service';
import { CalendarService } from './services/calendar.service';
import { TwitterService } from './services/twitter.service';
import { Broadcaster } from './services/broadcaster';

import { AppRoutingModule } from './app-routing.module';

export function cookieServiceFactory() {
  return new CookieService();
}

@NgModule({
  declarations: [
    AppComponent,
    LoadingComponent,
    FooterComponent,
    LoginComponent,
    MainComponent,
    HeaderComponent,
    MainCalendarComponent,
    MiniCalendarComponent,
    CalendarListComponent,
    AddCalendarModalComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    AppRoutingModule
  ],
  providers: [
    { provide: CookieService, useFactory: cookieServiceFactory },
    ApiService,
    LoginService,
    UserService,
    CalendarService,
    TwitterService,
    Broadcaster
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
