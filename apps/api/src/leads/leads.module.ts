import { Module } from '@nestjs/common';
import { AdminLeadsController } from './admin-leads.controller';
import { LeadNotificationService } from './lead-notification.service';
import { LeadsController } from './leads.controller';
import { LeadsRepository } from './leads.repository';
import { LeadsService } from './leads.service';

@Module({
  controllers: [LeadsController, AdminLeadsController],
  providers: [LeadsService, LeadNotificationService, LeadsRepository],
  exports: [LeadsService],
})
export class LeadsModule {}
