import { CommonModule, DatePipe, isPlatformBrowser  } from '@angular/common';
import { Component, ElementRef, ViewChild, Inject, PLATFORM_ID } from '@angular/core';
import { SharedModule } from '../../shared/shared.module';
import { UserService } from '../../service/user.service';
import {
  Chart,
  CategoryScale,
  LinearScale,
  LineController,
  LineElement,
  BarController,
  BarElement,
  Title,
  Tooltip,
  Legend,
  PointElement
} from 'chart.js';

Chart.register(
  CategoryScale,
  LinearScale,
  LineController,
  LineElement,
  PointElement,
  BarController,
  BarElement,
  Title,
  Tooltip,
  Legend
);
@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, SharedModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
  providers: [DatePipe]
})
export class DashboardComponent {

  statsData:any;

  workouts: any;
  activities: any;

  @ViewChild('workoutLineChart') private workoutLineChartRef:ElementRef;
  @ViewChild('activityLineChart') private activityLineChartRef:ElementRef;


  constructor(
  private userService: UserService,
  @Inject(PLATFORM_ID) private platformId: Object,
  private datePipe: DatePipe,
) {}

ngOnInit() {
  if (isPlatformBrowser(this.platformId)) {
    this.getStats();
    this.getGraphStats();
  }
}

  getGraphStats(){
    this.userService.getGraphStats().subscribe(res => {
      this.workouts = res.workouts;
      this.activities = res.activities;
      console.log(this.workouts, this.activities);
      if(this.workoutLineChartRef || this.activityLineChartRef) {
        this.createLineChart();
      }
    })
  }

  ngAfterViewInit() {
    if(this.workouts && this.activities) {
      this.createLineChart();
    }
  }

  createLineChart() {
    const workoutCtx = this.workoutLineChartRef.nativeElement.getContext('2d');
    const activityCtx = this.activityLineChartRef.nativeElement.getContext('2d');

     new Chart(workoutCtx, {
        type: 'line',
        data: {
          labels: this.workouts.map((data: {date:any;}) =>this.datePipe.transform(data.date, 'MM/dd')),
          datasets: [{
            label: 'Calories Burned',
            data: this.workouts.map((data: {caloriesBurned:any;}) => data.caloriesBurned),
            fill: false,
              borderWidth: 2,
              backgroundColor: 'rgba(80, 200, 120, 0.6)',
              borderColor: 'rgba(0, 100, 0, 1)',
          },
        {
            label: 'Duration',
            data: this.workouts.map((data: {duration:any;}) => data.duration),
            fill: false,
              borderWidth: 2,
              backgroundColor: 'rgba(120, 180, 200, 0.6)',
              borderColor: 'rgba(0, 100, 150, 1)',
          }]
        },
        options: {
          scales: {
            y: {
              beginAtZero: true
            }
          }
        }
      });
     new Chart(activityCtx, {
        type: 'line',
        data: {
          labels: this.activities.map((data: {date:any;}) =>this.datePipe.transform(data.date, 'MM/dd')),
          datasets: [{
            label: 'Calories Burned',
            data: this.activities.map((data: {caloriesBurned:any;}) => data.caloriesBurned),
            fill: false,
              borderWidth: 2,
              backgroundColor: 'rgba(255, 100, 100, 0.6)',
              borderColor: 'rgba(255, 0, 0, 1)',
          },
         {
            label: 'Steps',
            data: this.activities.map((data: {steps: any;}) => data.steps),
            fill: false,
              borderWidth: 2,
              backgroundColor: 'rgba(255, 180, 120, 0.6)',
              borderColor: 'rgba(255, 100, 0, 1)',
          },
          {
            label: 'Distance',
            data: this.activities.map((data: {distance: any;}) => data.distance),
            fill: false,
              borderWidth: 2,
              backgroundColor: 'rgba(255, 180, 120, 0.6)',
              borderColor: 'rgba(255, 100, 0, 1)',
          }
        ]
        },
        options: {
          scales: {
            y: {
              beginAtZero: true
            }
          }
        }
      });

  }

  getStats(){
    this.userService.getStats().subscribe(res => {
      this.statsData = res;
    })
  }

}
