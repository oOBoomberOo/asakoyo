import './session.d.ts'
import { Router } from 'express'
import { Twitter } from './twitter'
import { Reddit } from './reddit'
import { prisma } from './database'
import { handle-error } from './error'
import { authenticated-or-redirect, authenticated-or } from './auth/utils'

let router = Router()

router.get '/auth/twitter', do(req, res)
	let { url, oauth_token_secret } = await Twitter.initiateAuth()
	req.session.auth_secret = oauth_token_secret
	res.redirect url

router.get '/auth/twitter/callback', do(req, res)
	let { oauth_token, oauth_verifier } = req.query
	let { auth_secret } = req.session

	try
		unless (oauth_token and oauth_verifier and auth_secret) or (req.session.user)
			return res.redirect '/'
		let { user } = await Twitter.fromCode { token: oauth_token, secret: auth_secret, verifier: oauth_verifier }
		req.session.user = user
		res.redirect '/'
	catch err
		handle-error req, res, err

router.get '/auth/reddit', authenticated-or-redirect('/'), do(req, res)
	let url = Reddit.initiateAuth()
	res.redirect url

router.get '/auth/reddit/callback', authenticated-or-redirect('/'), do(req, res)
	let { code } = req.query
	let { user } = req.session

	try
		unless code and user
			return res.redirect '/'

		await Reddit.fromCode { code, user }
		res.redirect '/'
	catch err
		handle-error req, res, err

router.get '/logout', do(req, res)
	req.session.destroy do(err)
		console.error err
	res.redirect '/'

router.get '/me', authenticated-or(null), do(req, res)
	try
		let user = await prisma.user.findUnique
			where:
				id: req.session.user.id
			include:
				providers:
					select:
						id: true
						provider: true
						user_id: true
		
		let providers = Object.fromEntries user.providers.map do(provider)
			[provider.provider, provider]

		res.json { ...user, providers }
	catch err
		handle-error req, res, err

export default router