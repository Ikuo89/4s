import { NgModule }             from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { LoginComponent }   from './components/login.component';
import { MainComponent }   from './components/main.component';

const routes: Routes = [
  { path: 'login',  component: LoginComponent },
  { path: 'calendar',  component: MainComponent }
];
@NgModule({
  imports: [ RouterModule.forRoot(routes, { useHash: true }) ],
  exports: [ RouterModule ]
})
export class AppRoutingModule {}
