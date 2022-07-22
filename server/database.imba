import type { User } from '@prisma/client'
import { PrismaClient } from '@prisma/client'

export let prisma = new PrismaClient

export def provider provider_id\string
	await prisma.provider.findFirst
		where:
			id: provider_id
		
export def create-provider id\string, provider\string, access_token\string, refresh_token\string, user\User
	await prisma.provider.create
		data:
			id: id
			provider: provider
			accessToken: access_token
			refreshToken: refresh_token
			userId: user.id

export def create-user
	await prisma.user.create data: {}

export def user id
	await prisma.user.findUnique
		where:
			id: id

export def user-with-providers id
	await prisma.user.findUnique
		where:
			id: id
		include:
			providers: true
			publications: true


export def publications max=256
	await prisma.publication.findMany
		take: max
		include:
			tweets: true
			posts: true
			author: true

export def publication-by-id publication_id\number
	await prisma.publication.findFirst
		where:
			id: publication_id
		include:
			tweets: true
			posts: true
			author: true
