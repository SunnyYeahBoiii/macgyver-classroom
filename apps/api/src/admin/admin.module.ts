import { Module } from '@nestjs/common';
import { AdminRepository } from './admin.repository';
import { AdminService } from './admin.service';
import { AuditService } from './audit.service';
import { ContentAdminController } from './content-admin.controller';
import { ReviewService } from './review.service';

@Module({
  controllers: [ContentAdminController],
  providers: [AdminService, ReviewService, AuditService, AdminRepository],
  exports: [AdminService],
})
export class AdminModule {}
