#### ➡️ build and run local mlflow container ####
# create a volume for mlflow tracking in mlflow-data
# volume:
# 	mkdir -p mlflow-data && \
# 	podman volume create --opt type=none --opt device=$(PWD)/mlflow-data --opt o=bind mlflow-data
volume:
	podman volume create mlflow-data

build:
	podman build -t mlflow-container -f local.Dockerfile .

run:
	podman run -p 5000:5000 \
	-v mlflow-data:/mlflow \
	mlflow-container

run-debug:
	podman run -it -p 5000:5000 \
	-v mlflow-data:/mlflow \
	mlflow-container sh

stop:
	podman stop $(shell podman ps -q)




#### ➡️ set-up google cloud bucket ####
# list buckets
buckets:
	gsutil ls

create-bucket:
	gsutil mb \
			-l ${GCP_REGION} \
			-p ${GCP_PROJECT} \
			gs://${BUCKET_NAME}

remove-bucket:
	gsutil rm -r gs://${BUCKET_NAME}




#### ➡️ build and run google cloud mlflow container ####
############## register and authorize Gcloud Artifact Registry with docker/podman ############3
auth-docker:
	gcloud auth configure-docker ${GCP_REGION}-docker.pkg.dev

auth-podman:
	gcloud auth print-access-token | podman login -u oauth2accesstoken --password-stdin ${GAR_REGION}

gcloud-register-artifact:
	gcloud artifacts repositories create ${GAR_REPO} --repository-format=docker \
	--location=${GCP_REGION} --description="Repository for tracking taxifare experiments"


############# building and pushing to Gcloud Artifact Registry ############3
build-gcloud:
	podman build -t ${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT}/${GAR_REPO}/${GAR_IMAGE}:${VERSION} -f gcloud.Dockerfile .

build-test-gcloud:
	podman run -p 5000:5000 --env-file .env ${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT}/${GAR_REPO}/${GAR_IMAGE}:${VERSION}

push:
	podman push ${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT}/${GAR_REPO}/${GAR_IMAGE}:${VERSION}


############# deploy to Google cloud Run #################################3
deploy:
	gcloud run deploy --image ${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT}/${GAR_REPO}/${GAR_IMAGE}:${VERSION} \
	--memory ${GAR_MEMORY} --region ${GCP_REGION} --env-vars-file .env.yaml --platform managed --allow-unauthenticated


############ manage Google Cloud Run #####################################3
status:
	gcloud run services list

stop-gcloud:
	gcloud run services delete ${GAR_IMAGE}
