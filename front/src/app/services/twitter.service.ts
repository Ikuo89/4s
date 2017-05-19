import { Injectable } from '@angular/core';
import 'rxjs/add/operator/toPromise';
import { Observable } from 'rxjs/Observable';
import { ApiService } from './api.service';
import { TwitterUser } from '../models/twitter_user'

@Injectable()
export class TwitterService {
  constructor(private apiService: ApiService) { }

  search(query): Promise<TwitterUser[]> {
    return this.apiService.get(`/twitter_users/search?q=${query}`)
      .then(response => response as TwitterUser[]);
  }

  addUser(twitterId: string): Promise<TwitterUser[]> {
    return this.apiService.post(`/twitter_users/`, { id: twitterId })
      .then(response => response as TwitterUser);
  }
}
