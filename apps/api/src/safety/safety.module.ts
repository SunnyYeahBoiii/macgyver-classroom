import { Module } from '@nestjs/common';
import { SafetyAdminController } from './safety-admin.controller';
import { SafetyController } from './safety.controller';
import { SafetyCheckService } from './safety-check.service';
import { SafetyRepository } from './safety.repository';
import { SafetyRulesService } from './safety-rules.service';

@Module({
  controllers: [SafetyController, SafetyAdminController],
  providers: [SafetyCheckService, SafetyRepository, SafetyRulesService],
  exports: [SafetyCheckService, SafetyRulesService],
})
export class SafetyModule {}
