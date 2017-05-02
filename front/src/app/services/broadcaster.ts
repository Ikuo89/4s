import {Subject} from 'rxjs/Subject';
import {Observable} from 'rxjs/Observable';
import 'rxjs/add/operator/filter';
import 'rxjs/add/operator/map';

interface BroadcastEvent {
  key: any;
  data?: any;
}

export class Broadcaster {
  private events: Subject<BroadcastEvent>;

  constructor() {
    this.events = new Subject<BroadcastEvent>();
  }

  broadcast(key: any, data?: any) {
    this.events.next({key, data});
  }

  on<T>(key: any): Observable<T> {
    return this.events.asObservable()
      .filter(event => event.key === key)
      .map(event => <T>event.data);
  }
}
