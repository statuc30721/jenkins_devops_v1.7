FROM jenkins/jenkins
USER root
RUN apt update && apt-get install -y lsb-release

RUN apt install -y unzip wget curl

RUN apt install -y awscli

RUN apt install -y sudo

RUN wget -O- https://apt.releases.hashicorp.com/gpg \
| sudo gpg --dearmor \
| sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

RUN sudo gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

RUN sudo echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
     https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
     | sudo tee /etc/apt/sources.list.d/hashicorp.list

RUN sudo apt update && sudo apt -y upgrade

RUN sudo apt install -y bash-completion

RUN sudo apt install -y terraform

RUN sudo apt install -y nodejs npm

RUN sudo curl -fsSL https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-7.0.2.4839-linux-aarch64.zip -o /tmp/sonar-scanner.zip

RUN sudo unzip /tmp/sonar-scanner.zip -d /opt/

RUN sudo mv /opt/sonar-scanner-* /opt/sonar-scanner
RUN sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
RUN rm /tmp/sonar-scanner.zip

# Switch to user jenkins.
USER jenkins

# Copy file that lists plugins to temporary directory.
COPY --chown=jenkins:jenkins ./plugins.txt /tmp/

# Install plugins from plugins.txt file.
RUN jenkins-plugin-cli --plugins -f /tmp/plugins.txt

# delete plugin file from temporary directory.
RUN rm /tmp/plugins.txt
