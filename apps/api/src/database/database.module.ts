import { Module, Global } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { DatabaseService } from './database.service';
import { DatabaseRepository } from './database.repository';

/**
 * Database Module
 * 
 * Provides database access through Prisma ORM
 * Marked as Global to be available throughout the application
 */
@Global()
@Module({
  providers: [PrismaService, DatabaseService, DatabaseRepository],
  exports: [PrismaService, DatabaseService, DatabaseRepository],
})
export class DatabaseModule {}

// Made with Bob
