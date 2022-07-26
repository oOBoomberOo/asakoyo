export const store = {
	user: undefined
	publications: []
	subreddits: []
}

export def has-publications
	store.publications.length > 0

export def has-subreddits
	store.subreddits.length > 0

export def logged-in
	!fetching() and store.user

export def fetching
	store.user === undefined