COMPOSE_ARGS=&quot; -f jenkins.yml -p jenkins&quot;

#Make sure old containers are gone
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v

#build the system
sudo docker-compose $COMPOSE_ARGS build --no-cache
sudo docker-compose $COMPOSE_ARGS up -d

#Run unit tests
sudo docker-compose $COMPOSE_ARGS run --no-deps --rm -e ENV=UNIT identidock
ERR=$?

#Run system test if unit tests passed
if [ $ERR -eq0 ]; then
  IP=$(sudo docker inspect -f {{.NetworkSettings.IPAddress}} jenkins_identidock_1)
  CODE=$(curl -sL -w &quot;%{http_code}&quot; $IP:9090/monster/bla -o /dev/null) || true
  if [ $CODE -ne 200 ]; then
    echo &quot;Site returned &quot; $CODE
    ERR=1
  fi
fi

#Pull down the system
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v

return $ERR
