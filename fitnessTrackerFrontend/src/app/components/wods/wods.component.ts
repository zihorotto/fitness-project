import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import { NzMessageService } from 'ng-zorro-antd/message';
import { UserService } from '../../service/user.service';
import { CommonModule } from '@angular/common';
import { SharedModule } from '../../shared/shared.module';

@Component({
  selector: 'app-wods',
  standalone: true,
  imports: [CommonModule, SharedModule],
  templateUrl: './wods.component.html',
  styleUrls: ['./wods.component.scss'],
})
export class WodsComponent implements OnInit {
  wodsForm!: FormGroup;
  wods: any[] = [];
  loading = false;

  constructor(
    private fb: FormBuilder,
    private message: NzMessageService,
    private userService: UserService
  ) {}

  ngOnInit() {
    this.wodsForm = this.fb.group({
      search: [null],
    });

    this.getAllWODs();
  }

  getAllWODs() {
    this.loading = true;
    this.userService.getWODs().subscribe({
      next: (res) => {
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
}
