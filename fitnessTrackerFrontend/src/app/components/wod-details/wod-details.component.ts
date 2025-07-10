// ...existing code...
// ...existing code...
// Óra számlap számok pozíciója (analóg óra)

import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import {
  UserService,
  WOD,
  WodResultResponseDto,
} from '../../service/user.service';
import { CommonModule } from '@angular/common';
import { SharedModule } from '../../shared/shared.module';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';

@Component({
  selector: 'app-wod-details',
  templateUrl: './wod-details.component.html',
  styleUrls: ['./wod-details.component.scss'],
  standalone: true,
  imports: [CommonModule, SharedModule, MatSnackBarModule],
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

  previousResults: WodResultResponseDto[] = [];
  // Timer style toggle
  timerStyle: 'circle' | 'digital' = 'circle';

  ngOnDestroy(): void {
    clearInterval(this.timer);
  }

  constructor(
    private snackBar: MatSnackBar,
    private userService: UserService,
    private route: ActivatedRoute
  ) {}

  ngOnInit(): void {
    const wodId = this.route.snapshot.paramMap.get('id');
    if (wodId) {
      this.userService.getWODById(Number(wodId)).subscribe({
        next: (wod) => {
          this.wod = wod;
          this.loading = false;
          this.initDisplayTime();
          this.getWodResults(wod.id);
        },
        error: () => {
          this.loading = false;
          console.error('Error fetching WOD details');
        },
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
        this.elapsedSeconds = 0; // még nem telt el idő
        this.timer = setInterval(() => {
          this.secondsLeft--;
          this.elapsedSeconds++; // itt növeljük, mert telt idő is fontos
          this.displayTime = this.formatTime(this.secondsLeft);
          if (this.secondsLeft <= 0) {
            this.stopTimer();
          }
        }, 1000);
      } else if (type === 'fortime') {
        this.elapsedSeconds = 0;
        this.timer = setInterval(() => {
          this.elapsedSeconds++;
          this.displayTime = this.formatTime(this.elapsedSeconds);
        }, 1000);
      } else if (type === 'emom') {
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
      } else if (type === 'tabata') {
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
    const min = Math.floor(seconds / 60)
      .toString()
      .padStart(2, '0');
    const sec = (seconds % 60).toString().padStart(2, '0');
    return `${min}:${sec}`;
  }

  // Kör progress bar dashoffset számítás
  getCircleDashOffset(): number {
    // A kör kerülete: 2 * pi * r, r = 54, kerület = 339.292
    const CIRCUMFERENCE = 339.292;
    if (!this.wod) return CIRCUMFERENCE;
    const type = this.wod.type?.toLowerCase();
    if (type === 'amrap') {
      const total = this.wod.durationInMinutes * 60;
      const left = Math.max(total - this.elapsedSeconds, 0);
      return CIRCUMFERENCE * (1 - left / total);
    } else if (type === 'fortime') {
      // ForTime: progress bar a durationInMinutes-hez viszonyítva
      const total = this.wod.durationInMinutes * 60;
      const elapsed = Math.min(this.elapsedSeconds, total);
      return CIRCUMFERENCE * (elapsed / total);
    } else if (type === 'emom') {
      const total = this.wod.durationInMinutes * 60;
      return CIRCUMFERENCE * (this.elapsedSeconds / total);
    } else if (type === 'tabata') {
      const total = 8 * 30; // 8 kör, 20+10 mp
      return CIRCUMFERENCE * (this.elapsedSeconds / total);
    }
    return 0;
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
      reps: this.reps,
    });

    this.userService.saveWodResult(wodResult).subscribe({
      next: () => {
        this.snackBar.open('Workout result saved successfully!', 'Bezár', {
          duration: 3000, // 3 másodperc és eltűnik
          horizontalPosition: 'right',
          verticalPosition: 'top',
        });
        this.getWodResults(this.wod.id);
        this.resetTimerState();
      },
      error: (err) => {
        this.snackBar.open('Failed to save workout result.', 'Bezár', {
          duration: 3000,
          horizontalPosition: 'right',
          verticalPosition: 'top',
        });
      },
    });
  }

  // Reset timer and related state to initial values for the current WOD type
  resetTimerState() {
    this.timerRunning = false;
    this.reps = 0;
    this.elapsedSeconds = 0;
    this.secondsLeft = 0;
    this.emomRound = 0;
    this.tabataRound = 1;
    this.tabataPhase = 'work';
    this.tabataPhaseSeconds = 20;
    this.initDisplayTime();
  }

  // Timer style toggle method
  toggleTimerStyle() {
    this.timerStyle = this.timerStyle === 'circle' ? 'digital' : 'circle';
  }

  getWodResults(wodId: number) {
    this.userService.getWodResultsByWodId(wodId).subscribe({
      next: (results) => {
        this.previousResults = results;
        console.log('WOD results:', results);
      },
      error: (err) => {
        console.error('Error fetching WOD results:', err);
      },
    });
  }
}
