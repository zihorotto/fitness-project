import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { NzMessageService } from 'ng-zorro-antd/message';
import { UserService } from '../../service/user.service';
import { CommonModule } from '@angular/common';
import { SharedModule } from '../../shared/shared.module';

@Component({
  selector: 'app-goal',
  standalone: true,
  imports: [CommonModule, SharedModule],
  templateUrl: './goal.component.html',
  styleUrl: './goal.component.scss'
})
export class GoalComponent {
  gridStyle = {
      width: '100%',
      textAlign: 'center'
    };

  goalForm!: FormGroup
  goals: any;

  constructor(private fb: FormBuilder,
    private message: NzMessageService,
    private userService: UserService
  ) {}

  ngOnInit() {
    this.goalForm = this.fb.group({
      description: [null, [Validators.required]],
      startDate: [null, [Validators.required]],
      endDate: [null, [Validators.required]]

    });
    
    this.getAllGoals();
  }


  submitForm() {
    this.userService.postGoal(this.goalForm.value).subscribe(res => {
      this.message.success("Goal posted successfully", { nzDuration: 5000 });
      this.goalForm.reset();
      }, error => {
        this.message.error("Error while posting Goal", { nzDuration: 5000 });
    })
  }

  getAllGoals() {
    this.userService.getGoals().subscribe(res => {
      this.goals = res;
      console.log(this.goals);
   })
  }

  updateStatus(id: number) {
    this.userService.updateGoalStatus(id).subscribe({
      next: () => {
        this.message.success("Goal updated successfully", { nzDuration: 5000 });
        this.getAllGoals();
      },
      error: () => {
        this.message.error("Error while updating Goal", { nzDuration: 5000 });
      }
    });
  }

}
