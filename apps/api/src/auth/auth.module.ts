import { Module } from '@nestjs/common';
import { AuthRepository } from './auth.repository';
import { AuthService } from './auth.service';
import { SessionContextService } from './session-context.service';
import { SupabaseAuthService } from './supabase-auth.service';

@Module({
  providers: [
    AuthService,
    SupabaseAuthService,
    SessionContextService,
    AuthRepository,
  ],
  exports: [AuthService, SupabaseAuthService, SessionContextService],
})
export class AuthModule {}
