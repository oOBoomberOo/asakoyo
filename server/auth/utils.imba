import type { Request, Response, NextFunction } from 'express'
import * as db from '../database'
import { OAuth2 } from '../auth'

export def is-authenticated req\Request, res\Response, next\NextFunction
	if req.session.user
		next!
	else
		res.redirect '/'

export def is-definitely-authenticated req\Request, res\Response, next\NextFunction
	let user = await db.user-with-providers req.session.user.id

	# having two providers means the user has registered to both twitter and reddit
	# NOTE: Might be an issue later on if we need to support more providers
	if user..providers..length >= 2
		next!
	else
		res.redirect '/'

export def oauth2-callback req\Request, res\Response, client\OAuth2, client-state, client-verifier
	try
		let { state: reply-state, code: reply-code } = req.query
		let { data: { access_token, refresh_token }} = await client.fetch-token reply-state, reply-code, client-state, client-verifier
		let id = await client.identity access_token

		if let existing-provider = await db.provider(id)
			req.session.user = await db.user existing-provider.userId
			return res.redirect '/'
		
		let user = req.session.user
		let provider = await db.create-provider(id, client.provider, access_token, refresh_token, user)

		req.session.user = await db.user provider.userId
		res.redirect '/'
	catch err
		console.error err
		res.redirect '/failure'
