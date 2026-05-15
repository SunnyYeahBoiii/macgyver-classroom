import { CanActivate, Injectable } from '@nestjs/common';

@Injectable()
export class SupabaseAuthGuard implements CanActivate {
  canActivate(): boolean {
    return true;
  }
}
