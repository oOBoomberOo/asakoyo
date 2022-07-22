import express from 'express'
import session from 'express-session'
import index from './app/index.html'
import route from './server/backend'
import * as env from './server/env'

let app = express!

app.use session
	secret: env.SESSION_SECRET
	resave: false
	saveUninitialized: true
	store: new session.MemoryStore

app.use route

# catch-all route that returns our index.html
app.get(/.*/) do(req,res)
	# only render the html for requests that prefer an html response
	unless req.accepts(['image/*', 'html']) == 'html'
		return res.sendStatus(404)

	res.send index.body

imba.serve app.listen(process.env.PORT or 3000)