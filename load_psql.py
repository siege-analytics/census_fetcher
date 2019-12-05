import os
import subprocess
import pathlib

# Set PSQL environmental variables

os.environ['PGHOST']= "localhost"
os.environ['PGUSER'] = "dheerajchand"
os.environ['PGPASSWORD'] =""
os.environ['PGPORT']="5432"
os.environ['PGDATABASE']="scratch"
