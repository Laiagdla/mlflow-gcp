AR_REGION=europe-west2
VERSION=latest

service-auth:
	gcloud auth activate-service-account –key-file=".gcp-key.json"

auth-podman:
	gcloud auth print-access-token | podman login -u oauth2accesstoken --password-stdin ${GAR_REGION}

build-gcloud:
	podman build -t ${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT}/${GAR_REPO}/${GAR_IMAGE}:${VERSION} -f Dockerfile .

build-test-gcloud:
	podman run -p 5000:5000 --env-file .env ${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT}/${GAR_REPO}/${GAR_IMAGE}:${VERSION}

push:
	podman push ${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT}/${GAR_REPO}/${GAR_IMAGE}:${VERSION}


deploy:
	gcloud run deploy --image ${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT}/${GAR_REPO}/${GAR_IMAGE}:${VERSION} \
	--memory ${GAR_MEMORY} --region ${GCP_REGION} --platform managed --allow-unauthenticated \
	--set-cloudsql-instances=${GCP_PROJECT}:${GCP_REGION}:${GCP_SQL_INSTANCE}
