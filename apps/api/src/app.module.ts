import { join } from 'node:path';
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AdminModule } from './admin/admin.module';
import { AiModule } from './ai/ai.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AssetsModule } from './assets/assets.module';
import { AuthModule } from './auth/auth.module';
import { CommonModule } from './common/common.module';
import { ApiConfigModule } from './config/api-config.module';
import { CurriculumModule } from './curriculum/curriculum.module';
import { DatabaseModule } from './database/database.module';
import { ExperimentsModule } from './experiments/experiments.module';
import { ExportsModule } from './exports/exports.module';
import { FeedbackModule } from './feedback/feedback.module';
import { HealthModule } from './health/health.module';
import { InventoryModule } from './inventory/inventory.module';
import { LeadsModule } from './leads/leads.module';
import { LessonsModule } from './lessons/lessons.module';
import { MaterialsModule } from './materials/materials.module';
import { OrganizationsModule } from './organizations/organizations.module';
import { SafetyModule } from './safety/safety.module';
import { StorageModule } from './storage/storage.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [
        join(__dirname, '..', '.env'),
        join(__dirname, '..', '..', '..', '.env'),
      ],
    }),
    CommonModule,
    ApiConfigModule,
    DatabaseModule,
    AuthModule,
    UsersModule,
    OrganizationsModule,
    StorageModule,
    AssetsModule,
    InventoryModule,
    MaterialsModule,
    CurriculumModule,
    ExperimentsModule,
    AiModule,
    SafetyModule,
    LessonsModule,
    ExportsModule,
    LeadsModule,
    AnalyticsModule,
    FeedbackModule,
    AdminModule,
    HealthModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
