import dotenv from 'dotenv'

dotenv.config!

export const SESSION_SECRET = process.env.SESSION_SECRET

export const TWITTER_CLIENT_ID = process.env.TWITTER_CLIENT_ID
export const TWITTER_CLIENT_SECRET = process.env.TWITTER_CLIENT_SECRET
export const TWITTER_REDIRECT_URI = process.env.TWITTER_REDIRECT_URI

export const REDDIT_CLIENT_ID = process.env.REDDIT_CLIENT_ID
export const REDDIT_CLIENT_SECRET = process.env.REDDIT_CLIENT_SECRET
export const REDDIT_REDIRECT_URI = process.env.REDDIT_REDIRECT_URI
