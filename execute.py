import subprocess as sp

## start the backend file
## start the flutter app


sp.call("source /bin/activate", shell = True)
sp.call("python backend/app.py &", shell = True)
sp.call("flutter run", shell = True)