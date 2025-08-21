import { Component, Inject, OnInit, PLATFORM_ID } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { SharedModule } from './shared/shared.module';
import { isPlatformBrowser } from '@angular/common';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, SharedModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
})
export class AppComponent implements OnInit {
  title = 'fitnessTrackerFrontend';
  sideMenuCollapsed = true;
  menuOpen = false;

  audioCountdown!: HTMLAudioElement;

  countdownValue: number = 0;
  timerValue: number = 0;
  timerInterval: any;

  constructor(@Inject(PLATFORM_ID) private platformId: Object) {}

  ngOnInit() {
    if (isPlatformBrowser(this.platformId)) {
      this.audioCountdown = new Audio('assets/sounds/3-seconds.mp3');
    }
  }

  toggleMenu() {
    this.menuOpen = !this.menuOpen;
  }

  playSound(audio: HTMLAudioElement) {
    audio.play();
  }

  playCountdown() {
    this.playSound(this.audioCountdown);
  }

  startWorkout() {
    this.countdownValue = 3;
    const countdownInterval = setInterval(() => {
      console.log(`Countdown: ${this.countdownValue}`);

      if (this.countdownValue > 0) {
        this.playCountdown();
      }

      if (this.countdownValue === 0) {
        clearInterval(countdownInterval);
        this.startTimer();
      }

      this.countdownValue--;
    }, 1000);
  }

  startTimer() {
    this.timerValue = 0;
    this.timerInterval = setInterval(() => {
      this.timerValue++;
      console.log(`Timer: ${this.timerValue}`);
    }, 1000);
  }

  stopTimer() {
    clearInterval(this.timerInterval);
  }

  handleCountdownBeforeEnd() {
    this.playCountdown();
  }
}
