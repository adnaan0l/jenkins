FROM jenkins/jenkins:lts-jdk11
# if we want to install via apt
USER root
# # install python 3.9
RUN apt-get update && \
    apt-get install -y \
        wget \
        gnupg \
        software-properties-common \
        ca-certificates \
        curl \
        lsb-release
# install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    aws --version
# install aws sam
RUN curl -L "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip" -o "awssamcli.zip" && \
    unzip awssamcli.zip -d sam-installation && \
    ./sam-installation/install
# configure terraform repo
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list
# configure docker repo
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    focal stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && \
    apt-get install -y \
        terraform \
        git \
        python3-distutils \
        python3-apt \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-compose-plugin
# install pip manager and python packages
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.9 get-pip.py
COPY requirements.txt  .
RUN  pip3 install -r requirements.txt
# configure docker service
RUN echo 'Starting Docker'
RUN usermod -aG docker jenkins
RUN systemctl enable docker.service
RUN systemctl enable containerd.service
RUN service docker restart
# drop back to the regular jenkins user - good practice
USER jenkins