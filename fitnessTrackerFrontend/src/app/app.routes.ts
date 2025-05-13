import { Routes } from '@angular/router';
import { ActivityComponent } from './components/activity/activity.component';
import { WorkoutComponent } from './components/workout/workout.component';
import { GoalComponent } from './components/goal/goal.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { WodsComponent } from './components/wods/wods.component';
import { WodDetailsComponent } from './components/wod-details/wod-details.component';

export const routes: Routes = [
    
    { path: "activity", component: ActivityComponent},
    { path: "workout", component: WorkoutComponent},
    { path: "goal", component: GoalComponent},
    { path:"dashboard", component: DashboardComponent},
    { path: "wods", component: WodsComponent},
    { path: 'wod-details/:id', component: WodDetailsComponent}
];
