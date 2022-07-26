import type { User, Tweet, Post } from '@prisma/client'
import { PrismaClient } from '@prisma/client'

export let prisma = new PrismaClient

export def create-user
	await prisma.user.create data: {}

export def user-provider id\number, name\string
	await prisma.provider.findFirst
		where:
			provider: name
			user_id: id

export def user-with-providers id
	let user = await prisma.user.findUnique
		where:
			id: id
		include:
			providers: true

	unless user
		return null
	
	let providers = Object.fromEntries user.providers.map do(provider)
		[provider.provider, provider]

	return { ...user, providers }


export def publications-of author_id\number, max=256
	await prisma.publication.findMany
		take: max
		where:
			author_id: author_id
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
