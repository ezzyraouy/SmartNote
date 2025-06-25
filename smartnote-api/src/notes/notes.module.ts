//notes.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NotesService } from './notes.service';
import { NotesController } from './notes.controller';
import { Note } from './note.entity';
import { UsersModule } from '../users/users.module';
import { User } from 'src/users/user.entity';
import { AlgoliaModule } from '../algolia/algolia.module';
@Module({
  imports: [TypeOrmModule.forFeature([Note, User]), AlgoliaModule,UsersModule],
  controllers: [NotesController],
  providers: [NotesService],
})
export class NotesModule {}
