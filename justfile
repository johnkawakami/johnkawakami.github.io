# MakeTopicWords - local development

# default recipe: show what's available
default:
	@just --list

# serve locally at http://localhost:8000/makewords.html (http is what lets the app fetch makewords_lists/*.json; opening the file straight from disk cannot)
serve port="8000":
	python3 -m http.server {{port}} --bind 127.0.0.1 --directory .
