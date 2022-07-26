import express from 'express'
import session from 'express-session'
import morgan from 'morgan'
import index from './app/index.html'
import auth from './server/auth.imba'
import news from './server/news.imba'
import * as env from './server/env.imba'

let app = express!

app.use morgan('common')
app.use express.urlencoded { extended: true }
app.use session
	secret: env.SESSION_SECRET
	resave: false
	saveUninitialized: true
	store: new session.MemoryStore

app.use news
app.use auth

# catch-all route that returns our index.html
app.get(/.*/) do(req,res)
	# only render the html for requests that prefer an html response
	unless req.accepts(['image/*', 'html']) == 'html'
		return res.sendStatus(404)

	res.send index.body

imba.serve app.listen(process.env.PORT or 3000)