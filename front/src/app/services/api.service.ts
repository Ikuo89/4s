import { Injectable } from '@angular/core';
import { Http, Headers } from '@angular/http';
import { environment } from '../../environments/environment';
import 'rxjs/add/operator/toPromise';
import { CookieService } from 'angular2-cookie/services/cookies.service';

@Injectable()
export class ApiService {
  constructor(private http: Http, private cookieService: CookieService) { }

  private token(): string {
    return this.cookieService.get('token') || ''
  }

  private apiRoot = `${environment.apiRoot}/api`;
  get(path): Promise<any> {
    let headers = new Headers()
    headers.append('X-4S-Token', this.token())
    return this.http.get(this.apiRoot + path, { headers: headers })
      .toPromise()
      .then(response => response.json())
      .catch(this.handleError);
  }

  post(path, data): Promise<any> {
    let headers = new Headers()
    headers.append('X-4S-Token', this.token())
    return this.http.post(this.apiRoot + path, data, { headers: headers })
      .toPromise()
      .then(response => response.json())
      .catch(this.handleError);
  }

  private handleError(error: any): Promise<any> {
    console.error(error.message || error);
    return Promise.reject(error.message || error);
  }
}
