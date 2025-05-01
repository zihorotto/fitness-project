import { NgModule } from '@angular/core';

import { NzButtonModule } from 'ng-zorro-antd/button'; // Button
import { NzInputModule } from 'ng-zorro-antd/input'; // Input
import { NzSelectModule } from 'ng-zorro-antd/select'; // Select
import { NzCardModule } from 'ng-zorro-antd/card'; // Card
import { NzTableModule } from 'ng-zorro-antd/table'; // Table
import { NzIconModule } from 'ng-zorro-antd/icon'; // Icon
import { NzAlertModule } from 'ng-zorro-antd/alert'; // Alert
import { NzModalModule } from 'ng-zorro-antd/modal'; // Modal
import { NzDrawerModule } from 'ng-zorro-antd/drawer'; // Drawer
import { NzPaginationModule } from 'ng-zorro-antd/pagination'; // Pagination
import { NzTabsModule } from 'ng-zorro-antd/tabs'; // Tabs
import { NzAffixModule } from 'ng-zorro-antd/affix'; // Affix
import { NzAutocompleteModule } from 'ng-zorro-antd/auto-complete'; // Autocomplete
import { NzAvatarModule } from 'ng-zorro-antd/avatar'; // Avatar
import { NzBackTopModule } from 'ng-zorro-antd/back-top'; // BackTop
import { NzBadgeModule } from 'ng-zorro-antd/badge'; // Badge
import { NzBreadCrumbModule } from 'ng-zorro-antd/breadcrumb'; // BreadCrumb
import { NzCalendarModule } from 'ng-zorro-antd/calendar'; // Calendar
import { NzCascaderModule } from 'ng-zorro-antd/cascader'; // Cascader
import { NzCheckboxModule } from 'ng-zorro-antd/checkbox'; // Checkbox
import { NzCollapseModule } from 'ng-zorro-antd/collapse'; // Collapse
import { NzDatePickerModule } from 'ng-zorro-antd/date-picker'; // DatePicker
import { NzDescriptionsModule } from 'ng-zorro-antd/descriptions'; // Descriptions
import { NzDividerModule } from 'ng-zorro-antd/divider'; // Divider
import { NzEmptyModule } from 'ng-zorro-antd/empty'; // Empty
import { NzFormModule } from 'ng-zorro-antd/form'; // Form
import { NzGridModule } from 'ng-zorro-antd/grid'; // Grid
import { NzInputNumberModule } from 'ng-zorro-antd/input-number'; // InputNumber
import { NzLayoutModule } from 'ng-zorro-antd/layout'; // Layout
import { NzListModule } from 'ng-zorro-antd/list'; // List
import { NzMentionModule } from 'ng-zorro-antd/mention'; // Mention
import { NzPopconfirmModule } from 'ng-zorro-antd/popconfirm'; // Popconfirm
import { NzPageHeaderModule } from 'ng-zorro-antd/page-header'; // PageHeader
import { NzNotificationModule } from 'ng-zorro-antd/notification'; // Notification
import { NzMenuModule } from 'ng-zorro-antd/menu'; // Menu
import { NzMessageModule } from 'ng-zorro-antd/message'; // Message
import { NzImageModule } from 'ng-zorro-antd/image'; // Image
import { NzI18nModule } from 'ng-zorro-antd/i18n'; // I18n
import { NzDropDownModule } from 'ng-zorro-antd/dropdown'; // DropDown
import { NzWaveModule } from 'ng-zorro-antd/core/wave'; // Wave
import { NzTransButtonModule } from 'ng-zorro-antd/core/trans-button'; // TransButton
import { NzNoAnimationModule } from 'ng-zorro-antd/core/no-animation'; // NoAnimation
import { NzCommentModule } from 'ng-zorro-antd/comment'; // Comment
import { NzCarouselModule } from 'ng-zorro-antd/carousel'; // Carousel
import { NzAnchorModule } from 'ng-zorro-antd/anchor'; // Anchor
import { NzPopoverModule } from 'ng-zorro-antd/popover'; // Popover
import { NzProgressModule } from 'ng-zorro-antd/progress'; // Progress
import { NzRadioModule } from 'ng-zorro-antd/radio'; // Radio
import { NzRateModule } from 'ng-zorro-antd/rate'; // Rate
import { NzResultModule } from 'ng-zorro-antd/result'; // Result
import { NzSliderModule } from 'ng-zorro-antd/slider'; // Slider
import { NzSpinModule } from 'ng-zorro-antd/spin'; // Spin
import { NzSwitchModule } from 'ng-zorro-antd/switch'; // Switch
import { NzTagModule } from 'ng-zorro-antd/tag'; // Tag
import { NzTimelineModule } from 'ng-zorro-antd/timeline'; // Timeline
import { NzTimePickerModule } from 'ng-zorro-antd/time-picker'; // TimePicker
import { NzToolTipModule } from 'ng-zorro-antd/tooltip'; // Tooltip
import { NzTransferModule} from 'ng-zorro-antd/transfer'; // Transfer
import { NzTreeModule } from 'ng-zorro-antd/tree'; // Tree
import { NzTreeSelectModule } from 'ng-zorro-antd/tree-select'; // TreeSelect
import { NzTypographyModule } from 'ng-zorro-antd/typography'; // Typography
import { NzUploadModule } from 'ng-zorro-antd/upload'; // Upload
import { NzPipesModule } from 'ng-zorro-antd/pipes'; // Pipes
import { NzResizableModule } from 'ng-zorro-antd/resizable'; // Resizable


import * as AllIcons from '@ant-design/icons-angular/icons';

const antDesignIcons = Object.values(AllIcons);
@NgModule({
    imports: [
      NzIconModule.forChild(antDesignIcons),
    ],
    exports: [
      NzButtonModule,
      NzInputModule,
      NzSelectModule,
      NzCardModule,
      NzTableModule,
      NzIconModule,
      NzAlertModule,
      NzModalModule,
      NzDrawerModule,
      NzPaginationModule,
      NzTabsModule,
      NzAffixModule,
      NzAutocompleteModule,
      NzAvatarModule,
      NzBackTopModule,
      NzBadgeModule,
      NzBreadCrumbModule,
      NzCalendarModule,
      NzCascaderModule,
      NzCheckboxModule,
      NzCollapseModule,
      NzDatePickerModule,
      NzDescriptionsModule,
      NzDividerModule,
      NzEmptyModule,
      NzFormModule,
      NzGridModule,
      NzInputNumberModule,
      NzLayoutModule,
      NzListModule,
      NzMentionModule,
      NzProgressModule,
      NzRadioModule,
      NzRateModule,
      NzResultModule,
      NzSliderModule,
      NzSpinModule,
      NzSwitchModule,
      NzTagModule,
      NzTimelineModule,
      NzTimePickerModule,
      NzToolTipModule,
      NzTreeModule,
      NzTreeSelectModule,
      NzTypographyModule,
      NzUploadModule,
      NzPipesModule,
      NzResizableModule,
      NzTransferModule,
      NzPopoverModule,
      NzMentionModule,
      NzListModule,
      NzLayoutModule,
      NzImageModule,
      NzI18nModule,
      NzDropDownModule,
      NzWaveModule,
      NzTransButtonModule,
      NzNoAnimationModule,
      NzCommentModule,
      NzCarouselModule,
      NzAnchorModule,
      NzPopconfirmModule,
      NzPageHeaderModule,
      NzNotificationModule,
      NzMenuModule,
      NzMessageModule,
    ],
  })
  export class DemoNgZorroAntdModule {}
