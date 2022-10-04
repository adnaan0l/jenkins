FROM jenkins/jenkins:lts-jdk11
# if we want to install via apt
USER root
# # install python 3.9
RUN apt-get update && apt-get install -y wget gnupg software-properties-common python3-distutils python3-apt
# install pip manager and python packages
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.9 get-pip.py
COPY requirements.txt  .
RUN  pip3 install -r requirements.txt
# install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip && \
    ./aws/install
# install terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list
RUN apt-get update && \
    apt-get install terraform

# drop back to the regular jenkins user - good practice
USER jenkins