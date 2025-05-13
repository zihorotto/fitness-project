import { ComponentFixture, TestBed } from '@angular/core/testing';

import { WodsComponent } from './wods.component';

describe('WodsComponent', () => {
  let component: WodsComponent;
  let fixture: ComponentFixture<WodsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [WodsComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(WodsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
