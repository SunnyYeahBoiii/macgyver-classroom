describe('bootstrap', () => {
  beforeEach(() => {
    jest.resetModules();
    jest.clearAllMocks();
  });

  it('reads the listen port from ConfigService', async () => {
    const configService = {
      get: jest.fn().mockReturnValue(4567),
    };
    const app = {
      get: jest.fn().mockReturnValue(configService),
      listen: jest.fn().mockResolvedValue(undefined),
    };
    const create = jest.fn().mockResolvedValue(app);

    jest.doMock('@nestjs/core', () => ({
      NestFactory: {
        create,
      },
    }));

    jest.isolateModules(() => {
      jest.requireActual('./main');
    });
    await Promise.resolve();
    await Promise.resolve();

    expect(create).toHaveBeenCalledTimes(1);
    expect(app.get).toHaveBeenCalledTimes(1);
    const getCalls = app.get.mock.calls as Array<[{ name?: string }]>;
    expect(getCalls[0]?.[0].name).toBe('ConfigService');
    expect(configService.get).toHaveBeenCalledWith('PORT', 4000);
    expect(app.listen).toHaveBeenCalledWith(4567);
  });
});
