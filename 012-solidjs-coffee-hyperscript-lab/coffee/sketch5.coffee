import {r4r, effect, signal, log, div} from "/js/utils.js"


r4r =>
	[name, setName] = signal "John"
	effect => console.log "Hi #{name()}"
	setName "Julia"
	#setName "Janice"
	div {},



# Greeting = (props) =>
# 	div {},
# 		"Hi "
# 		props.name

# r4r =>
# 	[name, setName] = signal "Josephine"
# 	[visible, setVisible] = signal true

# 	div
# 		onClick: => setName "Geraldine"
# 		if visible() then Greeting {name}
