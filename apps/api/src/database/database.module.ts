import { Module } from '@nestjs/common';
import { DatabaseRepository } from './database.repository';
import { DatabaseService } from './database.service';

@Module({
  providers: [DatabaseService, DatabaseRepository],
  exports: [DatabaseService, DatabaseRepository],
})
export class DatabaseModule {}
