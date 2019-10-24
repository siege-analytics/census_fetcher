import os
import subprocess

# Set PSQL environmental variables

os.environ['PGHOST']= "localhost"
os.environ['PGUSER'] = "dheerajchand"
os.environ['PGPASSWORD'] =""
os.environ['PGPORT']="5432"
os.environ['PGDATABASE']="scratch"

# Test psql command

command = "psql -c 'SELECT POSTGIS_FULL_VERSION();'"
subprocess.call(["psql -c 'SELECT POSTGIS_FULL_VERSION();'"])
