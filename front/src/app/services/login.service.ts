import { Injectable } from '@angular/core';
import { environment } from '../../environments/environment';
import 'rxjs/add/operator/toPromise';
import { Observable } from 'rxjs/Observable';
import { Broadcaster } from './broadcaster';

import { UserService } from './user.service';
import { User } from '../models/user';

@Injectable()
export class LoginService {
  static user: User
  private googleAuthUrl = `${environment.apiRoot}/omniauth/google_redirect`;

  constructor(private userService: UserService, private broadcaster: Broadcaster) { }

  getGoogleOAuthUrl(currentUrl): string {
    return this.googleAuthUrl + '?return_url=' + encodeURIComponent(currentUrl);
  }

  getUser(): Promise<User> {
    if (LoginService.user) {
      return new Promise((resolve, reject) => {
        resolve(LoginService.user);
        return LoginService.user;
      });
    } else {
      return this.userService.getUser().then((user) => {
        LoginService.user = user;
        this.broadcaster.broadcast('login', LoginService.user);
        return LoginService.user;
      }).catch(this.handleError);
    }
  }

  on(key: string): Observable<User> {
    return this.broadcaster.on<User>(key);
  }

  private handleError(error: any): Promise<any> {
    return Promise.reject(error.message || error);
  }
}
