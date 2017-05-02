import { Component } from '@angular/core';
@Component({
  selector: 'app-footer',
  template: `
    <footer>2017 &copy; 4s by ih-apps</footer>
  `,
  styles: [`
    footer {
      position: fixed;
      bottom: 0px;
      margin: 20px;
      width: 100%;
      text-align: center;
      font-size: 12px;
    }

  `],
  providers: []
})
export class FooterComponent {
  constructor() { }
}
