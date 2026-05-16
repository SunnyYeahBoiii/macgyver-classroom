import { Injectable } from '@nestjs/common';
import {
  STATIC_MATERIAL_CATALOG,
  type MaterialCatalogItem,
} from './static-material-catalog';

@Injectable()
export class MaterialsService {
  listVisionCatalog(): MaterialCatalogItem[] {
    return STATIC_MATERIAL_CATALOG;
  }
}
