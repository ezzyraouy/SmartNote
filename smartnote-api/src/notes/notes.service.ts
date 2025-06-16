import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Note } from './note.entity';
import { User } from '../users/user.entity';

@Injectable()
export class NotesService {
  constructor(
    @InjectRepository(Note)
    private notesRepository: Repository<Note>,
  ) {}

  async createNote(user: User, title: string, content: string): Promise<Note> {
    const note = this.notesRepository.create({ title, content, user });
    return await this.notesRepository.save(note);
  }

  async getUserNotes(userId: number): Promise<Note[]> {
    return await this.notesRepository.find({
      where: { user: { id: userId } },
      order: { updatedAt: 'DESC' },
    });
  }

  async getNoteById(id: number, userId: number): Promise<Note> {
    const note = await this.notesRepository.findOne({
      where: { id, user: { id: userId } },
    });
    if (!note) {
      throw new NotFoundException('Note not found');
    }
    return note;
  }

  async updateNote(
    id: number,
    userId: number,
    updates: { title?: string; content?: string },
  ): Promise<Note> {
    const note = await this.getNoteById(id, userId);
    if (updates.title) note.title = updates.title;
    if (updates.content) note.content = updates.content;
    return await this.notesRepository.save(note);
  }

  async deleteNote(id: number, userId: number): Promise<void> {
    const result = await this.notesRepository.delete({
      id,
      user: { id: userId },
    });
    if (result.affected === 0) {
      throw new NotFoundException('Note not found');
    }
  }
}