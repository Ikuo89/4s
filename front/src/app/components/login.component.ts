import { Component, OnInit } from '@angular/core';

import { LoginService } from '../services/login.service';

@Component({
  template: `
    <div class="main">
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
  `],
  providers: []
})
export class LoginComponent implements OnInit{
  loginUrl: string;

  constructor(private loginService: LoginService) { }

  getLoginUrl(): void {
    this.loginUrl = this.loginService.getGoogleOAuthUrl(window.location.href);
  }

  ngOnInit(): void {
    this.getLoginUrl();
  }
}
