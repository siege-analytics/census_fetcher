up:
	docker-compose up -d

build:
	docker-compose stop
	docker-compose build

# 1
fetch-census:
	./fetch_census.sh

# 2
load-census:
	./load_psql.sh


clean:
	docker-compose down

shell:
	docker-compose exec postgis psql
