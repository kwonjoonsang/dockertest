FROM ubuntu:latest
LABEL authors="kjs0624"

ENTRYPOINT ["top", "-b"]# 1. 경량화된 Python 공식 이미지 사용
FROM python:3.14-slim

# 2. 컨테이너 내부 작업 디렉터리 설정
WORKDIR /code

# 3. 종속성 설치 (가상환경 venv를 복사하는 것이 아니라, requirements.txt만 복사해 새로 설치)
COPY ./requirements.txt /code/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# 4. FastAPI 앱 소스 코드만 복사
COPY ./app /code/app

# 5. 컨테이너 노출 포트 지정
EXPOSE 8000

# 6. Uvicorn 구동 명령어 설정
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]