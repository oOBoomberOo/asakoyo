import type { Request, Response, NextFunction } from 'express'
import { AxiosError } from 'axios'
import { user-with-providers } from '../database.imba'

export def is-authenticated req\Request
	req.session.user

export def is-registered req\Request
	let id = req.session..user..id

	unless id
		return false

	let user = await user-with-providers id

	unless user
		return false
	
	return user.providers..reddit and user.providers..twitter


export def authenticated
	do(req\Request, res\Response, next\NextFunction)
		if is-authenticated req
			next!
		else
			res.status(401).send('Unauthorized')

export def authenticated-or fallback\any
	do(req\Request, res\Response, next\NextFunction)
		if await is-authenticated req
			next!
		else
			res.status(200).json fallback

export def authenticated-or-redirect url\string
	do(req\Request, res\Response, next\NextFunction)
		if is-authenticated req
			next!
		else
			res.redirect url

export def registered
	do(req\Request, res\Response, next\NextFunction)
		if await is-registered req
			next!
		else
			res.status(401).send('Unauthorized')

export def registered-or fallback\any
	do(req\Request, res\Response, next\NextFunction)
		if await is-registered req
			next!
		else
			res.status(200).json fallback

export def registered-or-redirect url
	do(req\Request, res\Response, next\NextFunction)
		if await is-registered req
			next!
		else
			res.redirect url
