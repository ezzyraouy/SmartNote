// src/algolia/algolia.module.ts
import { Module } from '@nestjs/common';
import { AlgoliaService } from './algolia.service';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [ConfigModule],
  providers: [AlgoliaService],
  exports: [AlgoliaService],
})
export class AlgoliaModule {}
