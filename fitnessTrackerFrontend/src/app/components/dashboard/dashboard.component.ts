import { CommonModule, DatePipe, isPlatformBrowser } from '@angular/common';
import {
  Component,
  ElementRef,
  ViewChild,
  Inject,
  PLATFORM_ID,
} from '@angular/core';
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
  PointElement,
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
  Legend,
);
@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, SharedModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
  providers: [DatePipe],
})
export class DashboardComponent {
  // Helper to detect mobile (for template binding)
  isMobile(): boolean {
    return window.innerWidth <= 700;
  }

  statsData: any;
  wods: any[] = [];
  wodResults: { [wodId: number]: any[] } = {};
  loadingWods = false;
  totalLoggedMinutes: number = 0;

  // Side menu state for responsive sidebar (mobile/desktop)
  sideMenuCollapsed: boolean = true;

  @ViewChild('workoutLineChart') private workoutLineChartRef: ElementRef;
  @ViewChild('activityLineChart') private activityLineChartRef: ElementRef;

  constructor(
    private userService: UserService,
    @Inject(PLATFORM_ID) private platformId: Object,
    private datePipe: DatePipe,
  ) {}

  // Open sidebar (on hover/tap)
  openSideMenu() {
    this.sideMenuCollapsed = false;
  }

  // Close sidebar (on mouseleave/touchend)
  closeSideMenu() {
    this.sideMenuCollapsed = true;
  }

  // Format seconds to mm:ss (for WOD results)
  formatTime(seconds: number): string {
    const min = Math.floor(seconds / 60)
      .toString()
      .padStart(2, '0');
    const sec = (seconds % 60).toString().padStart(2, '0');
    return `${min}:${sec}`;
  }

  ngOnInit() {
    if (isPlatformBrowser(this.platformId)) {
      this.loadWods();
    }
  }

  loadWods() {
    this.loadingWods = true;
    this.userService.getWODs().subscribe({
      next: (wods) => {
        // Only WODs with results
        const wodFetches = wods.map((wod) =>
          this.userService
            .getWodResultsByWodId(wod.id)
            .toPromise()
            .then((results) => ({ wod, results })),
        );
        Promise.all(wodFetches).then((wodResultsArr) => {
          this.wods = wodResultsArr
            .filter((x) => x.results && x.results.length > 0)
            .map((x) => x.wod);
          this.wodResults = {};
          this.totalLoggedMinutes = 0;
          wodResultsArr.forEach((x) => {
            if (x.results && x.results.length > 0) {
              // Sort results by savedAt date (newest first)
              const sortedResults = [...x.results].sort((a, b) => {
                const dateA = new Date(a.savedAt).getTime();
                const dateB = new Date(b.savedAt).getTime();
                return dateB - dateA; // Descending order (newest first)
              });
              this.wodResults[x.wod.id] = sortedResults;
              this.totalLoggedMinutes += sortedResults.reduce(
                (sum, r) => sum + Math.round((r.durationInSeconds || 0) / 60),
                0,
              );
            }
          });
          this.loadingWods = false;
        });
      },
      error: () => {
        this.loadingWods = false;
      },
    });
  }
}
