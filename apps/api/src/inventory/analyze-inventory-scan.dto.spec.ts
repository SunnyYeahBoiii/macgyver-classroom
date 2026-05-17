import 'reflect-metadata';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { AnalyzeInventoryScanDto } from './dto/analyze-inventory-scan.dto';

const validImage = {
  mimeType: 'image/jpeg',
  dataBase64: Buffer.from('fake-image').toString('base64'),
};

const validateDto = (body: unknown) =>
  validate(plainToInstance(AnalyzeInventoryScanDto, body), {
    forbidUnknownValues: false,
    whitelist: true,
  });

describe('AnalyzeInventoryScanDto', () => {
  it('rejects unsupported image MIME types', async () => {
    const errors = await validateDto({
      images: [{ ...validImage, mimeType: 'image/gif' }],
    });

    expect(errors).not.toHaveLength(0);
  });

  it('rejects invalid base64 before scan analysis runs', async () => {
    const errors = await validateDto({
      images: [{ ...validImage, dataBase64: 'not-base64' }],
    });

    expect(errors).not.toHaveLength(0);
  });
});
