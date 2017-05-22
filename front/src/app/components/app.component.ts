import { Component, OnInit } from '@angular/core';
import { CookieService } from 'angular2-cookie/services/cookies.service';
import { Router, ActivatedRoute } from '@angular/router';

import { Util } from '../util';

import { LoginService } from '../services/login.service';
import { User } from '../models/user';

@Component({
  selector: 'app-root',
  template: `
    <router-outlet></router-outlet>
  `,
  styles: [`
  `],
  providers: []
})
export class AppComponent implements OnInit{
  user: User;

  constructor(private router: Router,
              private cookieService: CookieService,
              private loginService: LoginService) { }

  ngOnInit(): void {
    var query = Util.getQueryStrings();
    if (query['token']) {
      this.cookieService.put('token', query['token']);
      history.pushState(null, null, location.pathname)
    }

    var self = this;
    this.loginService.getUser()
      .then(function (user) {
        self.router.navigate(['/calendar']);
      }, function (error) {
        history.pushState(null, null, location.pathname)
        self.router.navigate(['/login']);
      });
  }
}
