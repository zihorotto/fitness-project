import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { UserService } from '../../service/user.service';
import { WOD } from '../../service/user.service';
import { CommonModule } from '@angular/common';
import { SharedModule } from '../../shared/shared.module';

@Component({
  selector: 'app-wod-details',
  standalone: true,
  imports: [CommonModule, SharedModule, RouterModule],
  templateUrl: './wod-details.component.html',
  styleUrls: ['./wod-details.component.scss']
})
export class WodDetailsComponent implements OnInit {
  wod!: WOD;
  loading: boolean = true;

  constructor(
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
        },
        error: () => {
          this.loading = false;
          console.error('Error fetching WOD details');
        }
      });
    }
  }
}
