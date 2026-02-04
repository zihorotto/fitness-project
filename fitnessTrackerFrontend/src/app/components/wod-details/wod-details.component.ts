// ...existing code...
// ...existing code...
// Óra számlap számok pozíciója (analóg óra)

import { Component, OnInit, OnDestroy, ChangeDetectorRef } from '@angular/core';
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
  timerStyle: 'circle' | 'digital' = 'digital'; // Set default to 'digital' for better visibility

  countdownValue: number = -1; // Set default to -1 to hide countdown initially
  countdownInterval: any; // Added to track the countdown interval
  private countdownAudio = new Audio('assets/sounds/3-seconds.mp3'); // Class-level audio object
  private recognition: any; // Added for SpeechRecognition

  ngOnDestroy(): void {
    clearInterval(this.timer);
  }

  constructor(
    private snackBar: MatSnackBar,
    private userService: UserService,
    private route: ActivatedRoute,
    private cdr: ChangeDetectorRef, // Added ChangeDetectorRef for manual change detection
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

    this.initVoiceCommands();
  }

  initDisplayTime() {
    const type = this.wod.type.replace(/\s+/g, '').toLowerCase();
    if (type === 'amrap') {
      const totalSeconds = this.wod.durationInMinutes * 60;
      this.secondsLeft = totalSeconds; // Initialize secondsLeft for countdown
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
    console.log('toggleTimer called');
    if (this.timerRunning) {
      console.log('Timer is running, stopping it.');
      clearInterval(this.timer);
      this.timerRunning = false;
      return;
    }

    if (this.elapsedSeconds > 0) {
      console.log('Resuming timer.');
      this.startTimerLogic();
      return;
    }

    if (this.countdownValue > 0 || this.countdownInterval) {
      console.warn('Countdown already in progress.');
      return;
    }

    console.log('Starting countdown.');
    this.countdownValue = 3;
    this.cdr.detectChanges(); // Trigger change detection
    this.countdownAudio.currentTime = 0;
    this.countdownAudio
      .play()
      .catch((err) => console.error('Audio play error:', err));

    this.countdownInterval = setInterval(() => {
      if (this.countdownValue > 0) {
        console.log(`Countdown: ${this.countdownValue}`);
        this.countdownValue--;
        this.cdr.detectChanges(); // Trigger change detection
      } else if (this.countdownValue === 0) {
        console.log('Go!');
        this.startTimerLogic();
        this.countdownValue = -1;
        this.cdr.detectChanges(); // Trigger change detection
      } else {
        console.log('Clearing countdown interval and hiding Go! message.');
        clearInterval(this.countdownInterval);
        this.countdownInterval = null;
        this.countdownValue = -1;
        this.cdr.detectChanges(); // Trigger change detection
      }
    }, 1000);
  }

  cancelCountdown() {
    clearInterval(this.countdownInterval);
    this.countdownValue = -1; // Hide countdown and remove 'Go!' message
    this.countdownAudio.pause(); // Stop the sound playback
    this.countdownAudio.currentTime = 0; // Reset the audio to the start
    console.log('Countdown cancelled');
  }

  startTimerLogic() {
    console.log('startTimerLogic called');
    if (this.timer) {
      clearInterval(this.timer); // Clear any existing interval
    }

    this.timerRunning = true;
    const type = this.wod.type.replace(/\s+/g, '').toLowerCase();
    const totalSeconds = this.wod.durationInMinutes * 60; // Calculate total duration in seconds

    if (type === 'amrap') {
      if (this.secondsLeft === 0) {
        this.secondsLeft = totalSeconds;
      }
      this.timer = setInterval(() => {
        this.secondsLeft--;
        this.elapsedSeconds++;
        this.displayTime = this.formatTime(this.secondsLeft);
        this.cdr.detectChanges(); // Trigger change detection
        console.log(`Timer running: ${this.displayTime}`);

        if (this.secondsLeft <= 0) {
          console.log('Duration reached. Stopping timer and saving result.');
          this.stopAndSave();
        }
      }, 1000);
    } else if (type === 'fortime') {
      this.timer = setInterval(() => {
        this.elapsedSeconds++;
        this.displayTime = this.formatTime(this.elapsedSeconds);
        this.cdr.detectChanges(); // Trigger change detection
        console.log(`Timer running: ${this.displayTime}`);

        if (this.elapsedSeconds >= totalSeconds) {
          console.log('Duration reached. Stopping timer and saving result.');
          this.stopAndSave();
        }
      }, 1000);
    } else if (type === 'emom') {
      this.timer = setInterval(() => {
        this.elapsedSeconds++;
        this.displayTime = this.formatTime(this.elapsedSeconds);
        this.cdr.detectChanges(); // Trigger change detection
        console.log(`Timer running: ${this.displayTime}`);

        if (this.elapsedSeconds % 60 === 0) {
          this.emomRound++;
          if (this.emomRound >= this.emomTotalRounds) {
            console.log(
              'EMOM rounds completed. Stopping timer and saving result.',
            );
            this.stopAndSave();
          }
        }
      }, 1000);
    } else if (type === 'tabata') {
      const totalRounds = 8;
      this.timer = setInterval(() => {
        this.secondsLeft--;
        this.elapsedSeconds++;
        this.displayTime = this.formatTime(this.secondsLeft);
        this.cdr.detectChanges(); // Trigger change detection
        console.log(`Timer running: ${this.displayTime}`);

        if (this.secondsLeft <= 0) {
          if (this.tabataPhase === 'work') {
            this.tabataPhase = 'rest';
            this.secondsLeft = 10;
          } else {
            this.tabataPhase = 'work';
            this.tabataRound++;
            this.secondsLeft = 20;
            if (this.tabataRound > totalRounds) {
              console.log(
                'Tabata rounds completed. Stopping timer and saving result.',
              );
              this.stopAndSave();
            }
          }
        }
      }, 1000);
    }
  }

  stopTimer() {
    this.timerRunning = false;
    clearInterval(this.timer);
  }

  pauseTimer() {
    this.timerRunning = false;
    clearInterval(this.timer);
    console.log('Timer paused');
    this.cdr.detectChanges(); // Trigger change detection to update the UI
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

    // Display 'Well Done!' effect
    this.displayTime = 'Done!';
    this.cdr.detectChanges(); // Trigger change detection to update the UI

    setTimeout(() => {
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
    }, 2000); // Keep 'Well Done!' visible for 2 seconds before resetting
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

  private initVoiceCommands(): void {
    const SpeechRecognition =
      (window as any).SpeechRecognition ||
      (window as any).webkitSpeechRecognition;

    if (!SpeechRecognition) {
      console.warn('SpeechRecognition is not supported in this browser.');
      return;
    }

    this.recognition = new SpeechRecognition();
    this.recognition.lang = 'en-US';
    this.recognition.continuous = true;

    this.recognition.onresult = (event: any) => {
      const transcript = event.results[event.results.length - 1][0].transcript
        .trim()
        .toLowerCase();
      console.log('Voice Command Detected:', transcript);

      if (transcript.includes('start')) {
        this.toggleTimer();
      } else if (transcript.includes('pause')) {
        this.pauseTimer();
      } else if (
        transcript.includes('stop and save') ||
        transcript.includes('stop')
      ) {
        this.stopAndSave();
      } else if (transcript.includes('continue')) {
        this.toggleTimer();
      } else {
        console.log('Unrecognized command:', transcript);
      }
    };

    this.recognition.onerror = (event: any) => {
      console.error('SpeechRecognition Error:', event.error);
    };

    this.recognition.onstart = () => {
      console.log('Speech recognition service has started.');
    };

    this.recognition.onend = () => {
      console.log('Speech recognition service disconnected.');
    };

    console.log('Voice commands initialized successfully.');
  }

  public startVoiceRecognition(): void {
    if (!this.recognition) {
      console.error('SpeechRecognition instance is not initialized.');
      return;
    }

    try {
      this.recognition.start();
      console.log('Voice recognition started.');
    } catch (error) {
      console.error('Error starting voice recognition:', error);
    }
  }

  public stopVoiceRecognition(): void {
    if (!this.recognition) {
      console.error('SpeechRecognition instance is not initialized.');
      return;
    }

    try {
      this.recognition.stop();
      console.log('Voice recognition stopped.');
    } catch (error) {
      console.error('Error stopping voice recognition:', error);
    }
  }
}
