// src/users/user.entity.ts
import { Entity, PrimaryGeneratedColumn, Column, BeforeInsert ,OneToMany  } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { Note } from '../notes/note.entity';
@Entity()
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  email: string;

  @Column()
  password: string;

  @OneToMany(() => Note, note => note.user)
  notes: Note[];
  
  @BeforeInsert()
  async hashPassword() {
    this.password = await bcrypt.hash(this.password, 10);
  }

  async comparePassword(attempt: string): Promise<boolean> {
    return await bcrypt.compare(attempt, this.password);
  }
}