//notes.controller.ts
import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
  NotFoundException,
  Query
} from '@nestjs/common';
import { NotesService } from './notes.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Note } from './note.entity';
import { UsersService } from '../users/users.service';

@Controller('notes')
@UseGuards(JwtAuthGuard)
export class NotesController {
  constructor(
    private readonly notesService: NotesService,
    private readonly usersService: UsersService,
  ) {}

  @Post()
  async createNote(
    @Request() req,
    @Body() body: { title: string; content: string },
  ): Promise<Note> {
    // Fetch full user entity from DB
    const user = await this.usersService.findById(req.user.sub);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return this.notesService.createNote(user, body.title, body.content);
  }

  @Get()
  async getNotes(@Request() req): Promise<Note[]> {
    return this.notesService.getUserNotes(req.user.sub);
  }

  @Get(':id')
  async getNote(@Request() req, @Param('id') id: string): Promise<Note> {
    return this.notesService.getNoteById(parseInt(id), req.user.sub);
  }

  @Put(':id')
  async updateNote(
    @Request() req,
    @Param('id') id: string,
    @Body() body: { title?: string; content?: string },
  ): Promise<Note> {
    return this.notesService.updateNote(parseInt(id), req.user.sub, body);
  }

  @Delete(':id')
  async deleteNote(@Request() req, @Param('id') id: string): Promise<void> {
    return this.notesService.deleteNote(parseInt(id), req.user.sub);
  }
  @Get('search')
  async searchNotes(@Request() req, @Query('q') query: string) {
    return this.notesService.searchNotes(query, req.user.sub);
  }
}
