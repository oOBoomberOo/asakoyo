import type { Provider } from "@prisma/client"
import snoowrap from 'snoowrap'
import { REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET, REDDIT_REDIRECT_URI, REDDIT_USER_AGENT } from "./env"
import { InvalidProvider } from "./error"
import { prisma } from "./database"

const user-agent = REDDIT_USER_AGENT

export class Reddit
	constructor client\snoowrap
		#client = client
	
	static def fromProvider provider\Provider
		InvalidProvider.assert provider.provider, "reddit"

		let client = new snoowrap
			userAgent: user-agent
			clientId: REDDIT_CLIENT_ID
			clientSecret: REDDIT_CLIENT_SECRET
			refreshToken: provider.refresh_token
		new Reddit client
	
	static default-scope = ["identity", "read", "submit", "mysubreddits"]
	static provider-name = "reddit"
	
	static def initiateAuth
		snoowrap.getAuthUrl
			clientId: REDDIT_CLIENT_ID
			scope: default-scope
			redirectUri: REDDIT_REDIRECT_URI
			permanent: true
	
	static def fromCode { code, user }
		let client = await snoowrap.fromAuthCode
			code: code
			userAgent: user-agent
			clientId: REDDIT_CLIENT_ID
			clientSecret: REDDIT_CLIENT_SECRET
			redirectUri: REDDIT_REDIRECT_URI
		let profile = client.getMe()
		
		await prisma.provider.create
			data:
				id: profile.id
				provider: provider-name
				access_token: client.accessToken
				refresh_token: client.refreshToken
				user_id: user.id
		
		new Reddit client
	
	def user-id
		#client.getMe!.id
	
	def subreddits
		#client.getSubscriptions({ limit: 256 })
	
	def upload-media file\(Express.Multer.File)
		throw Error "Not implemented"
	
	def post { title, media }
		throw Error "Not implemented"
	
	def comment { post_id, comment_id, content }
		throw Error "Not implemented"

	def delete-post id\string
		#client.getSubmission(id).delete()
	