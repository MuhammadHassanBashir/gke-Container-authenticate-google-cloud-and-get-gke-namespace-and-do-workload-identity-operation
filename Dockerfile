FROM google/cloud-sdk:latest

WORKDIR /workspace

# Set up your Google Cloud credentials
#COPY ./credentials.json /workspace/credentials.json

#COPY ./script.sh .
COPY ./script.sh .

#COPY ./kubeconfig.tpl .
#ENV GOOGLE_APPLICATION_CREDENTIALS=/workspace/credentials.json



# Install additional tools if needed
RUN apt-get update && apt install -y curl wget apt-transport-https nano


#Installing Required Repositories
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

RUN gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
tee /etc/apt/sources.list.d/hashicorp.list

RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list


RUN apt-get update && \
    apt-get install -y net-tools \
    gnupg \
    software-properties-common \
    kubectl \
    terraform \ 
    apt-transport-https \
    helm \
    jq \
    && \
    rm -rf /var/lib/apt/lists/*
    

RUN chmod +x script.sh

ENTRYPOINT ["/bin/bash","script.sh"]
