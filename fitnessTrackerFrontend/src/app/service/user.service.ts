import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

const BASIC_URL = 'http://localhost:8080/';

export interface WOD {
  id: number;
  name: string;
  description: string;
}

@Injectable({
  providedIn: 'root'
})
export class UserService {

  constructor(private http:HttpClient) { }

  postActivity(activityDto:any) : Observable<any> {
    return this.http.post(BASIC_URL + "api/activity", activityDto);
  }

  getActivites() : Observable<any> {
    return this.http.get(BASIC_URL + "api/activities");
  }

  postWorkout(workoutDto:any) : Observable<any> {
    return this.http.post(BASIC_URL + "api/workout", workoutDto);
  }

  getWorkouts() : Observable<any> {
    return this.http.get(BASIC_URL + "api/workouts");
  }

  postGoal(goalDto:any) : Observable<any> {
    return this.http.post(BASIC_URL + "api/goal", goalDto);
  }

  getGoals() : Observable<any> {
    return this.http.get(BASIC_URL + "api/goals");
  }

  updateGoalStatus(id:number) : Observable<any> {
    return this.http.patch(BASIC_URL + "api/goal/status/"+id, {archived: true});
  }

  getStats() : Observable<any> {
    return this.http.get(BASIC_URL + "api/stats");
  }

  getGraphStats() : Observable<any> {
    return this.http.get(BASIC_URL + "api/graphs");
  }

  getWODs(): Observable<WOD[]> {
    return this.http.get<WOD[]>(BASIC_URL + 'api/wods');
  }

  searchWODs(query: string): Observable<WOD[]> {
    return this.http.get<WOD[]>(BASIC_URL + 'api/wods', {
      params: { search: query }
    });
  }
  
}
