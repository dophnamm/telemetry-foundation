up:
	cd ./compose \
	&& docker compose up -d
	@echo "Prometheus: http://localhost:9090"
	@echo "Loki: http://localhost:3100"
	@echo "Tempo: http://localhost:3200"
	@echo "Grafana: http://localhost:3000"
	@echo "Application: http://localhost:3001"

down:
	cd ./compose \
	&& docker compose down

restart-prometheus:
	cd ./compose \
	&& docker compose restart prometheus
	@echo "Prometheus: http://localhost:9090"

restart-loki:
	cd ./compose \
	&& docker compose restart loki
	@echo "Loki: http://localhost:3100"

restart-tempo:
	cd ./compose \
	&& docker compose restart tempo
	@echo "Tempo: http://localhost:3200"