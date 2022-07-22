import axios from 'axios'
import randomstring from 'randomstring'
import crypto from 'crypto'
import base64url from 'base64url'
import base64 from 'base-64'

export def url-params params\object
	let result = new URLSearchParams
	for own key, value of params
		result.append key, value
	return result

export def build-url base\string, params\URLSearchParams
	let url = new URL base
	url.search = params.toString()
	url.href

export def random-state size=128
	randomstring.generate size

export def get-code-verifier size=128
	base64url.encode random-state(size)

export def get-code-challenge verifier\string
	let digest = crypto
		.createHash('sha256')
		.update(verifier)
		.digest()
	base64url.encode digest

export class OAuth2
	endpoint\string
	provider\string

	constructor client-id, client-secret, redirect-uri
		#client-id = client-id
		#client-secret = client-secret
		#redirect-uri = redirect-uri
	
	def request route\string, token\string, options\AxiosRequestConfig<any> = {}
		options.headers ||= { Authorization: "Bearer {token}" }
		await axios.get "{endpoint}{route}", options
	def post route\string, token\string, options\AxiosRequestConfig<any> = {}
		options.headers ||= { Authorization: "Bearer {token}" }
		await axios.post "{endpoint}{route}", options

	def basic-auth-header
		base64.encode(`${#client-id}:${#client-secret}`)
	
	def auth-param state, verifier, scope\array = []
		url-params
			response_type: 'code'
			client_id: #client-id,
			redirect_uri: #redirect-uri
			scope: scope.join ' '
			state: state
			code_challenge: get-code-challenge(verifier)
			code_challenge_method: 'S256'
	def token-param code, verifier
		url-params
			grant_type: 'authorization_code'
			client_id: #client-id
			code: code
			redirect_uri: #redirect-uri
			code_verifier: verifier

	def auth-url\string state\string, verifier\string
		throw Error "OAuth2.auth-url() not implemented"
	
	def token-url\string
		throw Error "OAuth2.token-url() not implemented"
	
	def refresh-url\string
		throw Error "OAuth2.refresh-url() not implemented"
	
	def revoke-url\string
		throw Error "OAuth2.revoke-url() not implemented"
	
	def fetch-token reply-state, reply-code, client-state, client-verifier
		unless reply-state == client-state
			throw Error "Unmatched state: {reply-state} != {client-state}"
		
		let params = token-param reply-code, client-verifier
		let config =
			headers:
				Authorization: "Basic {basic-auth-header!}"

		await axios.post token-url!, params, config
	
	def refresh-token token
		let params = url-params
			grant_type: 'refresh_token'
			refresh_token: token
			client_id: #client-id
		await axios.post refresh-url!, params
	
	def identity\Promise<string> token
		throw Error "OAuth2.identity() not implemented"
	



export class Twitter < OAuth2
	endpoint = 'https://api.twitter.com'
	provider = 'twitter'

	scope = [
		'offline.access' # access to refresh token
		'tweet.write' # write tweets
		'tweet.read'
		'users.read'
	]

	constructor { client_id\string, client_secret\string, redirect_uri\string }
		super(client_id, client_secret, redirect_uri)
	
	def auth-url state, verifier
		let params = auth-param state, verifier, scope
		build-url "https://twitter.com/i/oauth2/authorize", params
	def token-url
		"https://api.twitter.com/oauth2/token"
	def refresh-url
		"https://api.twitter.com/oauth2/token"
		
	def me token\string
		let response = await request '/2/me', token
		return response.data.data
	
	def identity token\string
		let { id } = await me(token)
		id

export class Reddit < OAuth2
	endpoint = 'https://oauth.reddit.com/api'
	provider = 'reddit'

	scope = [
		'identity'
		'edit'
		'submit'
	]

	constructor { client_id\string, client_secret\string, redirect_uri\string }
		super(client_id, client_secret, redirect_uri)
	
	def auth-url state, verifier
		let params = auth-param state, verifier, scope
		params.set 'duration', 'permanent'
		build-url "https://www.reddit.com/api/v1/authorize", params
	def token-url
		"https://www.reddit.com/api/v1/access_token"
	def refresh-url
		"https://www.reddit.com/api/v1/access_token"
	
	def me token\string
		let response = await request '/v1/me', token
		return response.data
	
	def identity token
		let { id } = await me(token)
		id
