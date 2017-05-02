import { Component, OnInit } from '@angular/core';
import { DomSanitizer, SafeStyle } from '@angular/platform-browser';
import { LoginService } from '../services/login.service';
import { User } from '../models/user';

@Component({
  selector: 'app-header',
  template: `
    <header>
      <div class="logo">4s</div>
      <div class="user" *ngIf="user">
        <div class="user-thumbnail" [style.background-image]="backgroundImageStyle(user.image)"></div>
        <div class="user-id">{{user.email}}</div>
      </div>
    </header>
  `,
  styles: [`
    header {
      width: 100%;
      height: 30px;
      border-bottom: 2px solid #000;
      padding: 5px 0;
      margin: 0 auto 20px;
    }
    header > * {
      display: inline-block;
    }
    header:after {
      clear: both;
    }
    .logo {
      font-size: 20px;
      margin: 5px;
    }
    .user {
      float: right;
    }
    .user-thumbnail {
      display: inline-block;
      float: left;
      width: 30px;
      height: 30px;
      background-color: #AAA;
      background-size: contain;
      background-repeat: no-repeat;
      border-radius: 50%;
    }
    .user-id {
      display: inline-block;
      float: left;
      margin: 5px;
      font-size: 12px;
      line-height: 20px;
    }
  `],
  providers: []
})
export class HeaderComponent implements OnInit {
  user: User;

  constructor(private loginService: LoginService, private sanitizer: DomSanitizer) { }

  backgroundImageStyle(url: string): SafeStyle {
    return this.sanitizer.bypassSecurityTrustStyle('url(' + url + ')');
  }

  ngOnInit(): void {
    this.loginService.on('login').subscribe(user => this.user = user);
  }
}
