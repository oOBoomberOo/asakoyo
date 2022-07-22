import './session.d.ts'
import * as env from './env'
import * as db from './database'
import { Router } from 'express'
import { Twitter, Reddit, random-state, get-code-verifier } from './auth'
import { oauth2-callback, is-authenticated, is-definitely-authenticated } from './auth/utils'

let twitter = new Twitter
	client_id: env.TWITTER_CLIENT_ID
	client_secret: env.TWITTER_CLIENT_SECRET
	redirect_uri: env.TWITTER_REDIRECT_URI
let reddit = new Reddit
	client_id: env.REDDIT_CLIENT_ID
	client_secret: env.REDDIT_CLIENT_SECRET
	redirect_uri: env.REDDIT_REDIRECT_URI

let router = Router strict: true

router.get '/me' do(req, res)
	if req.session.user
		let user = await db.user(req.session.user.id)
		res.send user
	else
		res.send null

router.get '/auth/twitter' do(req, res)
	let state = req.session.state = random-state 32
	let verifier = req.session.code_verifier = get-code-verifier!
	let url = twitter.auth-url state, verifier
	res.redirect url

router.get '/auth/twitter/callback' do(req, res)
	let state = req.session.state
	let verifier = req.session.code_verifier

	delete req.session.state
	delete req.session.code_verifier
	# redirect to the home page if this request wasn't triggered by the Twitter OAuth flow
	unless state and verifier
		return res.redirect '/'
	oauth2-callback req, res, twitter, state, verifier

router.get '/auth/reddit', is-authenticated, do(req, res)
	let state = req.session.state = random-state 32
	let url = reddit.auth-url state
	res.redirect url

router.get '/auth/reddit/callback', is-authenticated, do(req, res)
	let state = req.session.state
	delete req.session.state
	# redirect to the home page if this request wasn't triggered by the Reddit OAuth flow
	unless state
		return res.redirect '/'
	oauth2-callback req, res, reddit, state, ''

export default router
