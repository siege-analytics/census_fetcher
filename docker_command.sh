docker run --name=postgis -d -e POSTGRES_USER=dheerajchand -e POSTGRES_PASS=dessert -e POSTGRES_DBNAME=gis -e ALLOW_IP_RANGE=0.0.0.0/0 -p 54321:5432 -v pg_data:/var/lib/postgresql --restart=always kartoza/postgis
