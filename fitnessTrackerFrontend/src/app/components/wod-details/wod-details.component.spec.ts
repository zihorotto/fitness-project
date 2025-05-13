import { ComponentFixture, TestBed } from '@angular/core/testing';

import { WodDetailsComponent } from './wod-details.component';

describe('WodDetailsComponent', () => {
  let component: WodDetailsComponent;
  let fixture: ComponentFixture<WodDetailsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [WodDetailsComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(WodDetailsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
