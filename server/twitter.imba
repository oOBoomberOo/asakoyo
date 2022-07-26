import type { Provider } from "@prisma/client"
import { TwitterApi } from "twitter-api-v2"
import { TWITTER_APP_KEY, TWITTER_APP_SECRET, TWITTER_REDIRECT_URI } from "./env.imba"
import { prisma } from "./database"
import { InvalidProvider } from "./error"

# A helper class to handle interaction with the Twitter API.
export class Twitter
	constructor client\TwitterApi
		#client = client
	
	static provider-name = "twitter"

	# Create an instance from Database's Provider
	static def fromProvider provider\Provider
		InvalidProvider.assert provider.provider, provider-name

		let client = new TwitterApi
			appKey: TWITTER_APP_KEY
			appSecret: TWITTER_APP_SECRET
			accessToken: provider.access_token
			accessSecret: provider.refresh_token
		new Twitter client
	
	static def initiateAuth
		let client = new TwitterApi
			appKey: TWITTER_APP_KEY
			appSecret: TWITTER_APP_SECRET
		await client.generateAuthLink TWITTER_REDIRECT_URI
	
	static def fromCode { token, secret, verifier }
		let guestClient = new TwitterApi
			appKey: TWITTER_APP_KEY
			appSecret: TWITTER_APP_SECRET
			accessToken: token
			accessSecret: secret
		let { client, accessToken, accessSecret } = await guestClient.login verifier
		let profile = await client.currentUser!

		let user = await prisma.user.findFirst
			where:
				providers:
					some:
						id: profile.id_str
						provider: provider-name
		
		unless user
			user = await prisma.user.create
				data: {}

		await prisma.provider.upsert
			create:
				id: profile.id_str
				provider: provider-name
				access_token: accessToken
				refresh_token: accessSecret
				user_id: user.id
			update:
				access_token: accessToken
				refresh_token: accessSecret
				user_id: user.id
			where:
				id: profile.id_str

		{ client: new Twitter(client), user: user }
		
	def user-id
		let user = await #client.currentUser()
		user.id_str
	
	def upload-media file\(Express.Multer.File)
		await #client.v1.uploadMedia file.buffer, { mimeType: file.mimetype }
	
	def prepare-media\Promise<string[]> assets
		await Promise.all assets.map do(media)
			if typeof media === 'string'
				media
			else
				await upload-media media

	# create a tweet with the given text and array of medias
	#   if media is a file, it will be automatically uploaded to Twitter
	def tweet { status, media }
		let media_ids = await prepare-media media
		let result = await #client.v1.tweet status, { media_ids }
		console.log "Tweeted {status} at https://twitter.com/i/status/{result.id}"
		result
	
	# create a reply to a tweet
	def reply { status, media, reply_id }
		let media_ids = await prepare-media media
		await #client.v1.reply status, reply_id, { media_ids }
	
	# create a chain of tweets replying to one after another
	# accept a list of pure functions that accept an index and return a tweet object for `Twitter.tweet` or `Twitter.reply`
	def tweet-chain tweets\Function[]
		def wrapper i\Function
			Promise.resolve(i)
		
		def seq-tweet\Promise<TweetV1[]> prev\Promise<TweetV1[]>, cons\Promise<Function>, index\number
			let chain = await prev
			let f = await cons

			switch chain.length
				when 0
					let item = await tweet(f index)
					[item]
				else
					let tweet = await reply { ...f(index), reply_id: chain.at(-1).id_str }
					[...chain, tweet]
			
		let result\TweetV1[] = await tweets.map(wrapper).reduce seq-tweet, Promise.resolve([])
		return result

	def delete-tweet id\string
		await #client.v1.deleteTweet id
	
	def delete-tweets ids\string[]
		await Promise.all ids.map do(id)
			delete-tweet id
