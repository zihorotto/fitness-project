import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { NzMessageService } from 'ng-zorro-antd/message';
import { UserService, WOD } from '../../service/user.service';
import { CommonModule } from '@angular/common';
import { SharedModule } from '../../shared/shared.module';
import {
  trigger,
  state,
  style,
  transition,
  animate
} from '@angular/animations';

@Component({
  selector: 'app-wods',
  standalone: true,
  imports: [CommonModule, SharedModule],
  templateUrl: './wods.component.html',
  styleUrls: ['./wods.component.scss'],
  animations: [
    trigger('toggleHeight', [
      state('collapsed', style({ height: '0px', opacity: 0, padding: '0' })),
      state('expanded', style({ height: '*', opacity: 1, padding: '*' })),
      transition('collapsed <=> expanded', animate('300ms ease-in-out'))
    ])
  ]
})
export class WodsComponent implements OnInit {
  gridStyle = {
  width: '100%',
  textAlign: 'center'
};
  wodsForm!: FormGroup;
  wods: WOD[] = [];
  loading = false;
  hoveredWodId: number | null = null; 

  // Új WOD létrehozáshoz
  newWodForm!: FormGroup;
  creating = false;
  createSectionVisible = false; // <<< Hozzáadva

  categories = ['Strength', 'Endurance', 'Mobility', 'Cardio'];
  types = ['AMRAP', 'For Time', 'EMOM', 'Tabata'];

  constructor(
    private fb: FormBuilder,
    private message: NzMessageService,
    private userService: UserService
  ) {}

  ngOnInit() {
    this.wodsForm = this.fb.group({
      search: [null],
    });

    this.newWodForm = this.fb.group({
      name: ['', Validators.required],
      description: [''],
      category: ['', Validators.required],
      type: ['', Validators.required],
      durationInMinutes: [null, [Validators.required, Validators.min(1)]],
    });

    this.getAllWODs();
  }

  toggleCreateSection() {
    this.createSectionVisible = !this.createSectionVisible;
  }

  getAllWODs() {
    this.loading = true;
    this.userService.getWODs().subscribe({
      next: (res) => {
        console.log('getAllWODs response:', res);
        this.wods = res;
        this.loading = false;
      },
      error: () => {
        this.message.error('Error while fetching WODs', { nzDuration: 5000 });
        this.loading = false;
      },
    });
  }

  searchWODs() {
    const searchValue = this.wodsForm.get('search')?.value || '';

    if (!searchValue) {
      this.message.info('Please enter a search term.');
      return;
    }

    this.loading = true;

    this.userService.searchWODs(searchValue).subscribe({
      next: (res) => {
        this.wods = res;
        this.loading = false;
      },
      error: () => {
        this.message.error('Error while searching WODs', { nzDuration: 5000 });
        this.loading = false;
      },
    });
  }

  createWOD() {
    if (this.newWodForm.invalid) {
      this.message.error('Please fill all required fields for new WOD.');
      return;
    }

    this.creating = true;

    const newWod: Partial<WOD> = this.newWodForm.value;

    this.userService.createWOD(newWod as WOD).subscribe({
      next: (res) => {
        this.message.success('WOD created successfully!');
        this.newWodForm.reset();
        this.creating = false;
        this.getAllWODs();
      },
      error: () => {
        this.message.error('Error while creating WOD.');
        this.creating = false;
      },
    });
  }
}
