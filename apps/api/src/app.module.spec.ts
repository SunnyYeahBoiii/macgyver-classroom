import { join } from 'node:path';
import { Test } from '@nestjs/testing';

describe('AppModule configuration', () => {
  const originalCwd = process.cwd();
  const originalEnv = process.env;

  beforeEach(() => {
    jest.resetModules();
    process.chdir(join(__dirname, '..', '..'));
    process.env = { ...originalEnv };
    delete process.env.PORT;
    delete process.env.DATABASE_URL;
  });

  afterEach(() => {
    process.chdir(originalCwd);
    process.env = originalEnv;
  });

  it('loads API environment variables when started from the repository root', async () => {
    expect(process.env.PORT).toBeUndefined();
    expect(process.env.DATABASE_URL).toBeUndefined();

    const { AppModule } =
      jest.requireActual<typeof import('./app.module')>('./app.module');
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    await moduleRef.close();

    expect(process.env.PORT).toBeDefined();
    expect(process.env.DATABASE_URL).toBeDefined();
  });
});
