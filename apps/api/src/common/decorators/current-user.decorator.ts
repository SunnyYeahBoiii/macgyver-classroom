import { createParamDecorator } from '@nestjs/common';

export const CurrentUser = createParamDecorator((): undefined => undefined);
