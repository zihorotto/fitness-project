import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { UserService, WOD } from '../../service/user.service';
import { CommonModule } from '@angular/common';
import { SharedModule } from '../../shared/shared.module';

@Component({
  selector: 'app-wod-details',
  templateUrl: './wod-details.component.html',
  styleUrls: ['./wod-details.component.scss'],
  standalone: true,
  imports: [CommonModule, SharedModule],
})
export class WodDetailsComponent implements OnInit, OnDestroy {
  wod!: WOD;
  loading: boolean = true;

  timerRunning = false;
  displayTime: string = '00:00';
  reps: number = 0;
  timer!: ReturnType<typeof setInterval>;

  showReps = false;

  // EMOM
  emomRound: number = 0;
  emomTotalRounds: number = 0;

  elapsedSeconds: number = 0;
  secondsLeft: number = 0;

  // Tabata
  tabataRound: number = 1;
  tabataPhase: 'work' | 'rest' = 'work';
  tabataPhaseSeconds: number = 20;

  ngOnDestroy(): void {
    clearInterval(this.timer);
  }

  constructor(private userService: UserService, private route: ActivatedRoute) {}

  ngOnInit(): void {
    const wodId = this.route.snapshot.paramMap.get('id');
    if (wodId) {
      this.userService.getWODById(Number(wodId)).subscribe({
        next: (wod) => {
          this.wod = wod;
          this.loading = false;
          this.initDisplayTime();
        },
        error: () => {
          this.loading = false;
          console.error('Error fetching WOD details');
        }
      });
    }
  }

  initDisplayTime() {
  const type = this.wod.type.replace(/\s+/g, '').toLowerCase();
    if (type === 'amrap') {
      const totalSeconds = this.wod.durationInMinutes * 60;
      this.displayTime = this.formatTime(totalSeconds);
      this.showReps = true;
    } else if (type === 'fortime') {
      this.displayTime = '00:00';
    } else if (type === 'emom') {
      this.emomRound = 0;
      this.emomTotalRounds = this.wod.durationInMinutes;
      this.displayTime = '00:00';
    } else if (type === 'tabata') {
      this.tabataRound = 1;
      this.tabataPhase = 'work';
      this.tabataPhaseSeconds = 20;
      this.displayTime = this.formatTime(this.tabataPhaseSeconds);
    }
  }

 toggleTimer() {
  this.timerRunning = !this.timerRunning;
  const type = this.wod.type.replace(/\s+/g, '').toLowerCase();

  if (this.timerRunning) {
    if (type === 'amrap') {
      this.secondsLeft = this.wod.durationInMinutes * 60;
      this.elapsedSeconds = 0;  // még nem telt el idő
      this.timer = setInterval(() => {
        this.secondsLeft--;
        this.elapsedSeconds++;  // itt növeljük, mert telt idő is fontos
        this.displayTime = this.formatTime(this.secondsLeft);
        if (this.secondsLeft <= 0) {
          this.stopTimer();
        }
      }, 1000);
    }
    else if (type === 'fortime') {
      this.elapsedSeconds = 0;
      this.timer = setInterval(() => {
        this.elapsedSeconds++;
        this.displayTime = this.formatTime(this.elapsedSeconds);
      }, 1000);
    }
    else if (type === 'emom') {
      this.elapsedSeconds = 0;
      this.emomRound = 0;
      this.timer = setInterval(() => {
        this.elapsedSeconds++;
        this.displayTime = this.formatTime(this.elapsedSeconds);
        if (this.elapsedSeconds % 60 === 0) {
          this.emomRound++;
          if (this.emomRound >= this.emomTotalRounds) {
            this.stopTimer();
          }
        }
      }, 1000);
    }
    else if (type === 'tabata') {
      this.tabataRound = 1;
      this.tabataPhase = 'work';
      this.secondsLeft = 20;
      this.elapsedSeconds = 0;
      const totalRounds = 8;
      this.displayTime = this.formatTime(this.secondsLeft);

      this.timer = setInterval(() => {
        this.secondsLeft--;
        this.elapsedSeconds++;
        this.displayTime = this.formatTime(this.secondsLeft);

        if (this.secondsLeft <= 0) {
          if (this.tabataPhase === 'work') {
            this.tabataPhase = 'rest';
            this.secondsLeft = 10;
          } else {
            this.tabataPhase = 'work';
            this.tabataRound++;
            this.secondsLeft = 20;
            if (this.tabataRound > totalRounds) {
              this.stopTimer();
            }
          }
        }
      }, 1000);
    }
  } else {
    this.stopTimer();
  }
}

  stopTimer() {
    this.timerRunning = false;
    clearInterval(this.timer);
  }

  incrementReps() {
    this.reps++;
  }

  formatTime(seconds: number): string {
    const min = Math.floor(seconds / 60).toString().padStart(2, '0');
    const sec = (seconds % 60).toString().padStart(2, '0');
    return `${min}:${sec}`;
  }
    stopAndSave() {
    if (!this.timerRunning && this.elapsedSeconds === 0) {
      return;
    }

    this.stopTimer();

    const wodResult = {
      wodId: this.wod.id,
      durationInSeconds: this.elapsedSeconds,
      reps: this.reps,
      };
      console.log('Saving WOD Result:', {
    wodId: this.wod.id,
    durationInSeconds: this.elapsedSeconds,
    reps: this.reps
  });

    this.userService.saveWodResult(wodResult).subscribe({
      next: () => {
        alert('Workout result saved successfully!');
      },
      error: (err) => {
        console.error('Error saving workout result:', err);
        alert('Failed to save workout result.');
      }
    });
  }

}
