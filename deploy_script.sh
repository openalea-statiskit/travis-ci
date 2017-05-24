set -ev

if [[ "$DOCKER_DEPLOY" = "true" ]]; then
  docker push statiskit/$DOCKERFILE:14.04
fi

if [[ "$ANACONDA_DEPLOY" = "true" ]]; then
  if [[ "$TRAVIS_OS_NAME" = "linux" ]]; then
    if [[ ! "$ENVIRONMENT" = "" ]]; then
      mv ../$ENVIRONMENT environment.yml
      anaconda upload environment.yml -u statiskit --force
      mv environment.yml ../$ENVIRONMENT
    fi
    #md5sum `conda build ../conda/$RECIPE -c conda-forge -c statiskit --output`
  fi
  if [[ ! "$RECIPE" = "" ]]; then
      anaconda upload `conda build ../conda/$RECIPE $ANACONDA_CHANNELS --output` -u $ANACONDA_UPLOAD --force
  fi
fi

set +ev
