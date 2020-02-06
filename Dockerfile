FROM python:2.7
RUN pip install flask==0.12.4
COPY app.py /app.py
COPY jeIlyfish /jeIlyfish
COPY .aws-credentials .aws-credentials
EXPOSE 5000 22
ENTRYPOINT ["python", "./app.py"]
