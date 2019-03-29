#   This script isn't used in CI / CD ; it is there for manual testing if needed

#	Build docker container
sudo docker build -t vplauzon/cpu-ram-request-api:4 .

#	Publish image
sudo docker push vplauzon/cpu-ram-request-api:4

#	Test image
sudo docker run --name test-api -d -p 4000:80 vplauzon/cpu-ram-request-api:4
curl localhost:4000
#   Get into image
sudo docker run --name test-api -it vplauzon/cpu-ram-request-api:4 -p 4000:80 bash
#  Clean up after test
sudo docker stop test-api && sudo docker container prune -f