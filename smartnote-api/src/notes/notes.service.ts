import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Note } from './note.entity';
import { User } from '../users/user.entity';
import { AlgoliaService } from '../algolia/algolia.service';

@Injectable()
export class NotesService {
  constructor(
    @InjectRepository(Note)
    private notesRepository: Repository<Note>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private algoliaService: AlgoliaService,
  ) {}

  async createNote(user: User, title: string, content: string): Promise<Note> {
    const note = this.notesRepository.create({ title, content, user });
    const saved = await this.notesRepository.save(note);
    await this.algoliaService.saveNote(saved); // ✅ Sync with Algolia
    return saved;
  }

  async getUserNotes(userId: number): Promise<Note[]> {
    return await this.notesRepository.find({
      where: { user: { id: userId } },
      relations: ['user'],
      order: { updatedAt: 'DESC' },
    });
  }

  async getNoteById(id: number, userId: number): Promise<Note> {
    const note = await this.notesRepository.findOne({
      where: { id, user: { id: userId } },
      relations: ['user'],
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
    if (updates.title !== undefined) note.title = updates.title;
    if (updates.content !== undefined) note.content = updates.content;
    const updated = await this.notesRepository.save(note);
    await this.algoliaService.saveNote(updated); // ✅ Sync updated note
    return updated;
  }

  async deleteNote(id: number, userId: number): Promise<void> {
    const note = await this.getNoteById(id, userId);
    await this.notesRepository.delete(id);
    await this.algoliaService.deleteNote(id); // ✅ Remove from Algolia
  }

  async searchNotes(query: string, userId: number): Promise<any[]> {
    // return await this.notesRepository
    //   .createQueryBuilder('note')
    //   .leftJoinAndSelect('note.user', 'user')
    //   .where('(note.title ILIKE :query OR note.content ILIKE :query)', {
    //     query: `%${query}%`,
    //   })
    //   .orderBy('note.updatedAt', 'DESC')
    //   .getMany();
    return await this.algoliaService.searchNotes(query, userId);
  }
}
