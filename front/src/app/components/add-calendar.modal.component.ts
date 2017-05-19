import { Component, ElementRef } from '@angular/core';
import { CookieService } from 'angular2-cookie/services/cookies.service';
import { LoginService } from '../services/login.service';
import { TwitterService } from '../services/twitter.service';
import { TwitterUser } from '../models/twitter_user';

var s = document.createElement("script");
s.type = "text/javascript";
s.src = "https://d.line-scdn.net/r/web/social-plugin/js/thirdparty/loader.min.js";
document.body.appendChild(s);
declare var LineIt: any;

@Component({
  selector: 'add-calendar-modal',
  template: `
    <div class="background" (click)="close()" [style.display]="isShow ? 'block' : 'none'">
      <div class="modal" (click)="cancelClose($event)">
        <div class="header">
          カレンダー追加
        </div>
        <div class="body">
          <ng-container *ngIf="state == 0">
            <table class="add-table">
              <tr>
                <th>LINEから登録する</th>
                <th>Twitterから登録する</th>
              </tr>
              <tr>
                <td>
                  <div (click)="changeState(1)">
                    <img src="/assets/image/LINE_Icon.png" alt="LINE">
                  </div>
                </td>
                <td>
                  <div (click)="changeState(2)">
                    <img src="/assets/image/Twitter_Logo_Blue.png" alt="Twitter">
                  </div>
                </td>
              </tr>
            </table>
          </ng-container>
          <ng-container *ngIf="state == 1">
            <section>
              <h1>1. 友達追加</h1>
              <div>
                QRコードから、「4S」を友達に追加してください。
              </div>
              <img src="//qr-official.line.me/L/iox8pYdRlt.png" alt="LINE-QR">
            </section>
            <section>
              <h1>2. グループトークに追加</h1>
              <div>
                「4S」を監視するグループトークに追加して、以下ボタンからつぶやいてください。
              </div>
              <div class="line-share"></div>
            </section>
          </ng-container>
          <ng-container *ngIf="state == 2">
            <section>
              <h1>監視するTwitterユーザーを検索し、選択してください。</h1>
              <div>
                <input type="text" (keyup)="onKey($event)" placeholder="ユーザー名" />
                <ul class="twitter-user-list">
                  <li *ngFor="let twitterUser of twitterUsers" (click)="selectTwitterUser(twitterUser)">
                    <img [src]="twitterUser.profileImageUrlHttps" alt="userIcon" align="top"/>
                    <span class="name">{{twitterUser.name}}</span>
                    <span class="screen_name">@{{twitterUser.screenName}}</span>
                  </li>
                </ul>
              </div>
            </section>
          </ng-container>
        </div>
        <div class="footer">
        </div>
      </div>
    </div>
  `,
  styles: [`
    .background {
      position: absolute;
      left: 0;
      top: 0;
      height: 100%;
      width: 100%;
      background-color: rgba(0, 0, 0, 0.5);
    }
    .modal {
      position: absolute;
      left: 50%;
      top: 50%;
      background-color: #FFF;
      color: #000;
      width: 800px;
      transform: 'translate(-50%, -50%);
      -ms-transform: translate(-50%, -50%);
      -webkit-transform: translate(-50%, -50%);
      -moz-transform: translate(-50%, -50%);
    }
    .modal > .header {
      padding: 20px;
      font-size: 15px;
      border-bottom: 1px solid #DDD;
    }
    .modal > .body {
      min-height: 300px;
      margin: 20px;
    }
    .modal > .footer {
      padding: 20px;
      font-size: 15px;
      border-top: 1px solid #DDD;
      text-align: right;
    }
    .body > section > h1 {
      margin: 20px 0;
    }
    .line-add-friend > div {
      display: inline-block;
      float: left;
      height: 360px;
      line-height: 360px;
    }
    .line-share {
      margin: 20px 0;
    }
    .add-table {
      width: 100%;
      height: 100%;
    }
    .add-table th {
      width: 50%;
      height: 20px;
      font-size: 20px;
    }
    .add-table td > div {
      cursor: pointer;
      text-align: center;
    }
    .add-table td > div:hover {
      opacity: 0.7;
    }
    .add-table td > div > img {
      width: 70%;
      margin: 30px;
    }
    .twitter-user-list {
      list-style: none;
      overflow-y: scroll;
      max-height: 500px;
      margin-top: 10px;
    }
    .twitter-user-list > li {
      cursor: pointer;
      line-height: 30px;
    }
    .twitter-user-list > li:hover {
      opacity: 0.7;
    }
    .twitter-user-list > li > img{
      width: 30px;
      vertical-align: top;
    }
    .twitter-user-list > li > span {
      font-size: 14px;
    }
    .twitter-user-list > li > .screen_name {
      color: #657786;
    }
  `],
  providers: []
})
export class AddCalendarModalComponent {
  isShow: boolean = false;
  state: number = 0;
  twitterUsers: TwitterUser[] = [];
  private searchTimerId: any;
  constructor(private el: ElementRef,
              private cookieService: CookieService,
              private loginService: LoginService,
              private twitterService: TwitterService) { }

  open(): void {
    this.isShow = true;
    this.state = 0;
  }

  changeState(val: number): void {
    this.state = val;
    if (this.el.nativeElement.querySelector('.line-it-button')) return
    this.loginService.getUser().then(user => {
      let timerId = setInterval(() => {
        let $lineShare = this.el.nativeElement.querySelector('.line-share')
        if ($lineShare && $lineShare.clientWidth) {
          let $lineIt = document.createElement("div");
          $lineIt.setAttribute('data-lang', 'ja')
          $lineIt.setAttribute('data-type', 'share-a')
          $lineIt.setAttribute('data-url', window.location.href + '?id=' + user.identifier)
          $lineIt.classList.add('line-it-button')
          $lineIt.style.display = 'none'
          $lineShare.appendChild($lineIt)
          LineIt.loadButton()
          clearInterval(timerId)
        }
      })
    })
  }

  onKey(e): void {
    clearTimeout(this.searchTimerId)
    this.searchTimerId = setTimeout(() => {
      this.twitterService.search(e.target.value)
        .then(users => this.twitterUsers = users)
    }, 500)
  }

  selectTwitterUser(user: TwitterUser): void {
    this.twitterService.addUser(user.twitterComUserId)
      .then(user => {
        this.close()
      })
  }

  cancelClose(e): void {
    e.preventDefault();
    e.stopPropagation();
  }

  close(): void {
    this.isShow = false;
  }
}
