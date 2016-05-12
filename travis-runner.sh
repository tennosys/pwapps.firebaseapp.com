#!/bin/bash -e
set -o pipefail

if [ "$TRAVIS_BRANCH" = "master" ] && [ "$TRAVIS_PULL_REQUEST" = "false" ]  && [ "$TRAVIS_NODE_VERSION" = "5.1" ]
then
  git config --global user.email "tennosys@gmail.com"
  git config --global user.name "tennosys"

  # Stamp index.html with the date and time of PSK's deploying
  date_value=`date`
  sed -i.tmp1 "s/This is another card./This is another card. PSK Deployed on: $date_value/" app/index.html

  deploy_firebase () {
    # Deploying to Firebase! (https://polymer-starter-kit.firebaseapp.com)
    echo Deploying to Firebase
    # Making Changes to PSK for Firebase
    sed -i.tmp 's/<!-- Chrome for Android theme color -->/<base href="\/">\'$'\n<!-- Chrome for Android theme color -->/g' app/index.html
    sed -i.tmp "s/hashbang: true/hashbang: false/" app/elements/routing.html
    cp docs/firebase.json firebase.json
    # Starting Build Process for Firebase Changes
    gulp
    # Starting Deploy Process to Firebaseapp.com Server -- polymer-starter-kit.firebaseapp.com
    firebase deploy --token "$FIREBASE_TOKEN" -m "Auto Deployed by Travis CI"
    # Undoing Changes to PSK for Firebase
    cp app/index.html.tmp app/index.html
    cp app/elements/routing.html.tmp app/elements/routing.html
    rm app/elements/routing.html.tmp
    rm app/index.html.tmp
    rm firebase.json
  }

  deploy_firebase

  # Revert to orginal index.html and delete temp file
  cp app/index.html.tmp1 app/index.html
  rm app/index.html.tmp1
elif [ "$TRAVIS_BRANCH" = "master" ] && [ "$TRAVIS_PULL_REQUEST" = "false" ]  && [ "$TRAVIS_NODE_VERSION" != "5.1" ]
then
  echo "Do Nothing, only deploy with Node 5.1"
else
  npm test
fi
