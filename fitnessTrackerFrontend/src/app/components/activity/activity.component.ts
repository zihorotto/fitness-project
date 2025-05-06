import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SharedModule } from '../../shared/shared.module';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { NzMessageService } from 'ng-zorro-antd/message';
import { UserService } from '../../service/user.service';


@Component({
  selector: 'app-activity',
  standalone: true,
  imports: [CommonModule, SharedModule],
  templateUrl: './activity.component.html',
  styleUrl: './activity.component.scss'
})
export class ActivityComponent {

  gridStyle = {
    width: '100%',
    textAlign: 'center'
  };

  activityForm!: FormGroup
  activities: any;

  constructor(private fb: FormBuilder,
    private message: NzMessageService,
    private userService: UserService
  ) {}

  ngOnInit() {
    this.activityForm = this.fb.group({
      caloriesBurned: [null, [Validators.required]],
      steps: [null, [Validators.required]],
      distance: [null, [Validators.required]],
      date: [null, [Validators.required]]
    });
    
    this.getAllActivities();
  }


  submitForm() {
    this.userService.postActivity(this.activityForm.value).subscribe(res => {
      this.message.success("Activity posted successfully", { nzDuration: 5000 });
      this.activityForm.reset();
      }, error => {
        this.message.error("Error while posting Activity", { nzDuration: 5000 });
    })
  }

  getAllActivities() {
    this.userService.getActivites().subscribe(res => {
      this.activities = res;
   })
  }
}