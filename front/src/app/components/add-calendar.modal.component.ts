import { Component, ElementRef } from '@angular/core';
import { CookieService } from 'angular2-cookie/services/cookies.service';
import { LoginService } from '../services/login.service';

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
          <section>
            <h1>1. 友達追加</h1>
            <div>
              QRコードまたはボタンから、「4S」を友達に追加してください。
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
  `],
  providers: []
})
export class AddCalendarModalComponent {
  isShow: boolean = false;
  constructor(private el: ElementRef,
              private cookieService: CookieService,
              private loginService: LoginService) { }

  open(): void {
    this.isShow = true;
    if (this.el.nativeElement.querySelector('.line-it-button')) return
    this.loginService.getUser().then(user => {
      let $lineIt = document.createElement("div");
      $lineIt.setAttribute('data-lang', 'ja')
      $lineIt.setAttribute('data-type', 'share-a')
      $lineIt.setAttribute('data-url', window.location.href + '?id=' + user.identifier)
      $lineIt.classList.add('line-it-button')
      $lineIt.style.display = 'none'
      this.el.nativeElement.querySelector('.line-share').appendChild($lineIt)
      LineIt.loadButton()
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
