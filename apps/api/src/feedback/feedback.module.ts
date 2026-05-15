import { Module } from '@nestjs/common';
import { AdminFeedbackController } from './admin-feedback.controller';
import { FeedbackController } from './feedback.controller';
import { FeedbackRepository } from './feedback.repository';
import { FeedbackService } from './feedback.service';

@Module({
  controllers: [FeedbackController, AdminFeedbackController],
  providers: [FeedbackService, FeedbackRepository],
  exports: [FeedbackService],
})
export class FeedbackModule {}
