import { Component, OnInit } from '@angular/core';

import { LoginService } from '../services/login.service';
import { Util } from '../util';

@Component({
  template: `
    <div class="main">
      <div class="notification" *ngIf="error == 'invalid_authenticity'">
        Googleの認証に失敗しました。<br />お手数ですが<a href="https://myaccount.google.com/permissions" target="_blank">こちら</a>よりGoogleから4sへの連携を解除した上で<br />再度ログインをお試しください。
      </div>
      <div>
        <div class="logo-container">
          <section class="logo">4s</section>
          <section class="copy">
            <ul>schedule</ul>
            <ul>sync</ul>
            <ul>search</ul>
            <ul>share</ul>
          </section>
        </div>
        <div class="note">ログインして、今すぐはじめよう</div>
        <a class="btn google-login" href="{{loginUrl}}">Google ログイン</a>
      </div>
    </div>
    <app-footer></app-footer>
  `,
  styles: [`
    .main {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%,-50%);
      text-align: center;
    }
    .logo-container {
      display: inline-block;
      height: 280px;
    }
    .logo-container > * {
      display: inline-block;
      float: left;
    }
    .logo-container:after {
      clear: both;
    }
    .logo {
      font-size: 100px;
      margin-top: 95px;
      margin-right: 20px;
    }
    .copy {
      margin: 85px 20px 0;
      font-size: 20px;
      line-height: 32px;
      text-align: left;
    }
    .note {
      margin: 10px;
    }
    .google-login {
      background-color: #DF4A32;
      color: #FFF;
      font-size: 20px;
      padding: 8px 18px;
      width: 300px;
      margin: 30px;
    }
    .notification {
      background-color: #EEE;
      font-size: 12px;
      text-align: center;
      border: 1px solide #AAA;
      border-radius: 10px;
      -webkit-border-radius: 10px;
      -moz-border-radius: 10px;
      -ms-border-radius: 10px;
      padding: 10px;
      line-height: 20px;
    }
  `],
  providers: []
})
export class LoginComponent implements OnInit{
  loginUrl: string;
  error: string;

  constructor(private loginService: LoginService) { }

  getLoginUrl(): void {
    this.loginUrl = this.loginService.getGoogleOAuthUrl(window.location.href);
  }

  ngOnInit(): void {
    this.getLoginUrl();

    var query = Util.getQueryStrings();
    if (query['error']) {
      this.error = query['error']
    }
  }
}
