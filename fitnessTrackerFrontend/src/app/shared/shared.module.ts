import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule, withFetch } from '@angular/common/http';
import { DemoNgZorroAntdModule } from '../DemoNgZorroAntdModule';
import { RouterModule } from '@angular/router';

import { provideHttpClient } from '@angular/common/http';

@NgModule({
  providers: [
    provideHttpClient(withFetch())
  ],
  imports: [
    CommonModule,
    DemoNgZorroAntdModule,
    FormsModule,
    ReactiveFormsModule,
    RouterModule
  ],
  exports: [
    CommonModule,
    DemoNgZorroAntdModule,
    FormsModule,
    ReactiveFormsModule,
    RouterModule
  ]
})
export class SharedModule { }
