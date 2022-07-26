import type { User, Provider, Publication, Tweet, Post } from '@prisma/client'
import * as api from '../api'
import { store , has-publications} from '../store'

tag publication-list
	css self
		d: flex
		jc: center
	
	def delete-publication id
		await api.remove-publication id
		await refresh-publications!
	
	def refresh-publications
		store.publications = await api.publications()
	
	def post n
		store.publications.at(n)..posts..at(0)
	
	def tweet n
		store.publications.at(n)..tweets..at(0)

	<self>
		if has-publications()
			<table>
				<tr>
					<th> "ID"
					<th> "Twitter"
					<th> "Reddit"
					<th> "Action"
				for publication, n of store.publications
					<tr>
						<td> "{publication.id}"
						<td> if let x = tweet n
							<a href="https://twitter.com/i/status/{x.id}"> "Tweet"
						<td> if let x = post n
							<a href="https://reddit.com/r/{x.subreddit}/comments/{x.id}"> "Reddit"
						<td>
							<button @click=(delete-publication publication.id)> "Delete"
		else
			"No publications"
