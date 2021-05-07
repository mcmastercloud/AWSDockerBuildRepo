# Use the AWS Provided python Image
FROM public.ecr.aws/lambda/python:3.8

# Update Linux Libraries
RUN yum update -y && \
	yum install -y \

# Install Unzip
RUN yum install -y unzip

# Download the Chromedriver Binary and explide it into the Chromedriver Directory.  Once this is complete, make sure that 
# ChromeDriver is in the Linux Path.
RUN mkdir /usr/local/chromedriver
RUN curl https://chromedriver.storage.googleapis.com/2.37/chromedriver_linux64.zip -o /tmp/chromedriver.zip
RUN unzip /tmp/chromedriver.zip -d /usr/local/chromedriver
# Make Chromedriver Executable
RUN chmod +x /usr/local/chromedriver/chromedriver
RUN export PATH=$PATH:/usr/local/chromedriver

# Download Headless Chrome (thanks to adieu/adieu), and unzip to the /usr/local. folder.
RUN curl -SL https://github.com/adieuadieu/serverless-chrome/releases/download/v1.0.0-37/stable-headless-chromium-amazonlinux-2017-03.zip -o /tmp/headless.zip
RUN unzip /tmp/headless.zip -d /usr/local

# Enable the Google Chrompe Repo, and install the Google Chrome Binary.  This will add all of the dependencies that the Headless
# Chrome driver downloaded above would otherwise require.
COPY chrome.repo /etc/yum.repos.d/
RUN yum install -y --enablerepo=google-chrome google-chrome-stable

# Copy an example .py file into the Lambda Task Root Folder.  This will be used as a Lambda Entry point, if this Docker image
# is used as the basis of a Lambda Function.
COPY webdriver.py ${LAMBDA_TASK_ROOT}
# Get the pipe requirements.txt file - this currently holds the spec for Selenium.
COPY requirements.txt ./
RUN pip install -r requirements.txt

# Set the Lambda Entrypoint.
CMD [ "webdriver.lambda_handler" ]

