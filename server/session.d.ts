import session from 'express-session';
import { User } from '@prisma/client';

declare module 'express-session' {
	export interface SessionData {
		user: User
		state: string
		code_verifier: string
	}
}
