import axios from 'axios'
import snoowrap from 'snoowrap'
import FormData from 'form-data'
import { DateTime } from 'luxon'
import { TwitterApi } from 'twitter-api-v2'
import { Twitter } from './twitter'
import { Reddit } from './reddit'

def publication-week week\string
	const formatter = "LLL dd"

	let [_, a-year, a-week] = week.match /(\d+)-W(\d+)/
	let start = DateTime.fromObject { weekYear: a-year, weekNumber: a-week }
	let end = start.plus week: 1

	"{start.toFormat formatter} - {end.toFormat formatter}"

export def publish-to-twitter client\Twitter, { files, language, week: raw-week, hashtag }
	let week = publication-week raw-week
	let assets\(Express.Multer.File[]) = files
	
	def status page
		"HoloNews {language} {week} {hashtag} ({page}/{files.length})"

	await client.tweet-chain assets.map do(file)
		do(index)
			{ status: status(index + 1), media: [file] }

export def publish-to-reddit client\Reddit, { link, language, week: raw-week, hashtag, subreddit }
	let week = publication-week raw-week
	let title = "HoloNews {language} {week} {hashtag}"
	let post_id = await client.post { title, link, subreddit }
	console.log "Posted to Reddit: https://reddit.com/r/{subreddit}/comments/{post_id}"
	return [{ id: post_id }]
