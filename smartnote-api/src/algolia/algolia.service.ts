// src/algolia/algolia.service.ts
import { Injectable } from '@nestjs/common';
import algoliasearch, { SearchClient } from 'algoliasearch';
import { ConfigService } from '@nestjs/config';
import { Note } from '../notes/note.entity';

@Injectable()
export class AlgoliaService {
  private client: SearchClient;
  private index;

  constructor(private configService: ConfigService) {
    const appId = this.configService.get<string>('ALGOLIA_APP_ID');
    const apiKey = this.configService.get<string>('ALGOLIA_ADMIN_API_KEY');
    const indexName = this.configService.get<string>('ALGOLIA_INDEX_NAME');

    if (!appId || !apiKey || !indexName) {
      throw new Error(
        'Missing Algolia configuration values in environment variables',
      );
    }

    this.client = algoliasearch(appId, apiKey);
    this.index = this.client.initIndex(indexName);
  }

  async saveNote(note: Note) {
    return this.index.saveObject({
      objectID: note.id.toString(),
      title: note.title,
      content: note.content,
      userId: note.user.id,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    });
  }

  async deleteNote(id: number) {
    return this.index.deleteObject(id.toString());
  }

  async searchNotes(query: string, userId: number) {
    const result = await this.index.search(query, {
      filters: `userId:${userId}`,
    });
    return result.hits;
  }
}
