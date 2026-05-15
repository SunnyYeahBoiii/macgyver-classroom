import { Module } from '@nestjs/common';
import { StorageRepository } from './storage.repository';
import { StorageService } from './storage.service';
import { SupabaseStorageService } from './supabase-storage.service';

@Module({
  providers: [StorageService, SupabaseStorageService, StorageRepository],
  exports: [StorageService, SupabaseStorageService],
})
export class StorageModule {}
