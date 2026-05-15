import { Injectable } from '@nestjs/common';

export interface HealthStatus {
  status: 'ok';
}

@Injectable()
export class HealthService {
  getHealth(): HealthStatus {
    return { status: 'ok' };
  }
}
