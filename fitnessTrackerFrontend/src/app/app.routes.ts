import { Routes } from '@angular/router';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { WodsComponent } from './components/wods/wods.component';
import { WodDetailsComponent } from './components/wod-details/wod-details.component';

export const routes: Routes = [
    
    { path:"dashboard", component: DashboardComponent},
    { path: "wods", component: WodsComponent},
    { path: 'wod-details/:id', component: WodDetailsComponent}
];
