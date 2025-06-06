// src/users/users.controller.ts
import { Body, Controller, Get, Post, Put, Delete, Request, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Post('register')
  async register(@Body() body: { email: string; password: string }) {
    return this.usersService.create(body.email, body.password);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  getProfile(@Request() req) {
    return this.usersService.findById(req.user.sub);
  }

  @UseGuards(JwtAuthGuard)
  @Put('update')
  async updateUser(
    @Request() req,
    @Body() body: { email?: string; password?: string } // Make fields optional
  ) {
    // Only update password if it's provided and not empty
    const passwordToUpdate = body.password?.trim() ? body.password : undefined;
    return this.usersService.update(
      req.user.sub,
      body.email,
      passwordToUpdate
    );
  }

  @UseGuards(JwtAuthGuard)
  @Delete('delete')
  async deleteUser(@Request() req) {
    await this.usersService.delete(req.user.sub);
    return { message: 'User deleted' };
  }
}