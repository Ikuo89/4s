import { Injectable } from '@angular/core';
import 'rxjs/add/operator/toPromise';

import { ApiService } from '../services/api.service';
import { User } from '../models/user';

@Injectable()
export class UserService {
  constructor(private apiService: ApiService) { }

  getUser(): Promise<User> {
    return this.apiService.get('/user')
      .then(response => response as User);
  }
}
