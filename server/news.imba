import type { Request, Response } from 'express'
import type { TweetV1 } from 'twitter-api-v2'

import { Router } from 'express'
import multer from 'multer'
import { registered-or, registered } from './auth/utils'
import { Twitter } from './twitter'
import { Reddit } from './reddit'
import { Imgur } from './imgur'
import { handle-error } from './error'
import { prisma } from './database'
import * as db from './database'
import * as pb from './publication'

let upload = multer()
let router = Router()

router.get '/subreddits', registered-or([]), do(req, res)
	try
		let user = req.session.user
		let provider = await db.user-provider user.id, Reddit.provider-name
		let client = Reddit.fromProvider provider
		let result = await client.subreddits().fetchAll()

		let subreddits = result.map do(subreddit)
			subreddit.display_name

		subreddits.sort do(a, b)
			a.localeCompare(b)

		res.json subreddits
	catch err
		handle-error req, res, err

# List all publications
router.get '/publications', registered-or([]), do(req, res)
	try
		let publications = await db.publications-of req.session.user.id
		res.json publications
	catch err
		handle-error req, res, err

# Submit a new publication
router.post '/publications', registered(), upload.array('files', 20), do(req\Request, res\Response)
	console.log "POST /publications: Received", req.body

	let files\(Express.Multer.File[]) = req.files or []
	let { language, week, hashtag, subreddit } = req.body or {}

	try
		unless language and week and hashtag and subreddit
			throw Error 'invalid input'

		let user = await db.user-with-providers req.session.user.id
		let { providers } = user

		let twitter = Twitter.fromProvider providers.twitter
		let reddit = Reddit.fromProvider providers.reddit
		let imgur = Imgur.fromEnv!

		console.log "User {user.id}: Publishing {files.length} files to {subreddit} (reddit={providers.reddit.id}, twitter={providers.twitter.id})"

		let album = await imgur.create-album files
		console.log "User {user.id}: Created album https://imgur.com/a/{album.id}"

		let data = { files, language, week, hashtag, subreddit, link: "https://imgur.com/a/{album.id}" }

		let posts = await pb.publish-to-reddit reddit, data
		console.log "User {user.id}: Published to reddit"

		let tweets = await pb.publish-to-twitter twitter, data
		console.log "User {user.id}: Published to twitter"

		let publication = await prisma.publication.create
			data:
				tweets:
					create: tweets.map do(tweet)
						{ id: tweet.id_str }
				posts:
					create: posts.map do(post)
						{ id: post.id, subreddit: subreddit }
				author_id: user.id
		res.json publication
	catch err
		handle-error req, res, err

# Delete a publication
router.delete '/publications/:id', registered(), do(req, res)
	try
		let id = parseInt req.params.id
		let { id: publication_id, tweets, posts } = await db.publication-by-id id
		let { providers } = await db.user-with-providers req.session.user.id

		let twitter = Twitter.fromProvider providers.twitter
		let reddit = Reddit.fromProvider providers.reddit

		await twitter.delete-tweets tweets.map do(tweet)
			tweet.id
		await reddit.delete-posts posts.map do(post)
			post.id
		await prisma.publication.delete
			where:
				id: publication_id

		res.status(200).send()
	catch err
		handle-error req, res, err


export default router