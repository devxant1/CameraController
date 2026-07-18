local ShakeState = table.freeze({
	FadingIn = 0,
	Sustained = 1,
	FadingOut = 2,
	Inactive = 3,
})

return ShakeState